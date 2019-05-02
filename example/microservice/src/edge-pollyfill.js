export function extractTokenFromReq(req) {
  const { authorization } = req;
  return (authorization && authorization.length && authorization.split(' ')[1]);
}

export function addAuthorizationHeader(token) {
  return `Bearer ${token}`;
}

export function extendEdgeContext(context) {
  const { httpPort } = context.info;

  const localMds = `http://localhost:${httpPort}/mds/v1`;

  const decryptNodesJson = (encryptedJson, decryptType, accessToken, successCb, errorCb) => {
    context.edge.decryptEncryptedNodesJson({
      type: decryptType,
      data: encryptedJson,
      token: accessToken,
      success: (response) => {
        try {
          const r = JSON.parse(response.data);
          successCb(r);
        } catch (e) {
          errorCb(e);
        }
      },
      error: err => errorCb(new Error(err.message)),
    });
  };

  const clusterDiscovery = (clusterType, accessToken, successCb, errorCb) => {
    if (clusterType !== 'linkLocal' && clusterType !== 'proximity' && clusterType !== 'account') {
      errorCb(new Error('unknown cluster type'));
      return;
    }

    context.http.request(({
      url: `${localMds}/nodes?clusters=${clusterType}`,
      success: (result) => {
        const nodes = JSON.parse(result.data);
        const encryptedJson = JSON.stringify(nodes.data);

        decryptNodesJson(encryptedJson, 'local', accessToken, (cluster) => {
          if (clusterType !== 'account') {
            successCb(cluster);
            return;
          }

          const cipheredNodes = cluster && cluster.account && cluster.account.cipheredNodes;
          if (!cipheredNodes) {
            errorCb(new Error('invalid account cluster json'));
            return;
          }

          const encryptedAccountJson = JSON.stringify(cipheredNodes);
          decryptNodesJson(encryptedAccountJson, 'account', accessToken,
            (accountNodes) => {
              const accountCluster = Object.assign({}, cluster.account);
              accountCluster.cipheredNodes = undefined;
              accountCluster.nodes = accountNodes;
              successCb(accountCluster);
            }, errorCb);
        }, errorCb);
      },
      error: err => errorCb(new Error(err.message)),
    }));
  };

  const getRequestBepHmacCode = (accessToken, nodeId, successCb, errorCb) => {
    const NOW = Math.floor(Date.now() / 1000);
    const ONE_DAY = 24 * 60 * 60;
    const FIVE_MIN = 5 * 60;
    const expiry = (NOW + ONE_DAY + FIVE_MIN).toString();

    context.http.request({
      type: 'POST',
      url: `http://localhost:${httpPort}/jsonrpc/v1`,
      data: JSON.stringify({
        id: 1,
        jsonrpc: '2.0',
        method: 'getEdgeHmacCode',
        params: [accessToken, expiry, nodeId, 'jsapi://requestBep'],
      }),
      success: (response) => {
        const json = response.data;
        const r = JSON.parse(json);

        if (!r.result) {
          errorCb(new Error('invalid jsonrpc response'));
          return;
        }

        successCb(r.result.edgeHmacCode);
      },
      error: err => errorCb(new Error(err.message)),
    });
  };

  const systemInfo = (accessToken, successCb, errorCb) => context.http.request(({
    type: 'POST',
    url: `http://localhost:${httpPort}/jsonrpc/v1`,
    data: JSON.stringify({
      id: 1,
      jsonrpc: '2.0',
      method: 'getMe',
      params: [accessToken],
    }),
    success: (response) => {
      const json = response.data;
      const r = JSON.parse(json);
      successCb(r.result);
    },
    error: err => errorCb(new Error(err.message)),
  }));

  const edge = Object.assign(context.edge, {
    clusterDiscovery,
    systemInfo,
    getRequestBepHmacCode,
  });

  return Object.assign(context, {
    edge,
  });
}
