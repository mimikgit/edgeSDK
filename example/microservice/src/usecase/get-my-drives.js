import Action from 'action-js';
import keyBy from 'lodash/keyBy';
import mergeWith from 'lodash/mergeWith';
import values from 'lodash/values';

import NodesMapper from '../helper/nodes-mapper';
import { extractToken } from '../helper/authorization-helper';

export default class GetMyDrives {
  constructor(getNearByDrives, localMds, http, edge, authorization) {
    this.getNearByDrives = getNearByDrives;
    this.localMds = localMds;
    this.http = http;
    this.edge = edge;
    this.authorization = authorization;
  }

  static transform(data, edge, authorization) {
    const accountNodes = data.include.devices.data.account;
    const encryptedNodes = accountNodes.cipheredNodes;
    const accessToken = extractToken(authorization);

    // console.log(`authorization: ${authorization}, accessToken: ${accessToken}`);
    if (!accessToken) {
      return new Error('invalid access token format');
    }

    // console.log(`accountNodes: ${JSON.stringify(accountNodes, null, 2)}`);
    // return GetMyDrives.transformMdsNodes(nodes, data.data.avatar);
    return new Action(
      (cb) => {
        const encryptedJson = JSON.stringify(encryptedNodes);
        // console.log(`encryptedJson: ${encryptedJson}`);

        edge.decryptEncryptedNodesJson({
          type: 'account',
          token: accessToken,
          data: encryptedJson,
          success: (result) => {
            cb(result.data);
          },
          error: (err) => {
            cb(new Error(err.message));
          },
        });
      }).next((json) => {
        try {
          const decryptedNodes = JSON.parse(json);
          return decryptedNodes;
        } catch (e) {
          return new Error(e.message);
        }
      }).next((nodes) => {
        const obj = {
          accountId: data.data.id,
          devices: NodesMapper.transformMdsNodes(nodes, data.data.avatar),
        };

        return obj;
      });
  }

  getMpoDevices() {
    const { http, authorization, localMds, edge } = this;
    const accessToken = extractToken(authorization);

    return new Action(
      (cb) => {
        http.request(({
          url: `${localMds}/nodes?clusters=account`,
          success: (result) => {
            cb(result.data);
          },
          error: (err) => {
            cb(new Error(err.message));
          },
        }));
      },
    ).next((json) => {
      try {
        const nodes = JSON.parse(json);
        return JSON.stringify(nodes.data);
      } catch (e) {
        return new Error(e.message);
      }
    }).next(encryptedJson => new Action(
      (cb) => {
        edge.decryptEncryptedNodesJson({
          type: 'local',
          token: accessToken,
          data: encryptedJson,
          success: (result) => {
            cb(result.data);
          },
          error: (err) => {
            cb(new Error(err.message));
          },
        });
      }))
      .next((json) => {
        try {
          const nodes = JSON.parse(json);
          console.log(JSON.stringify(nodes, null, 2));
          return nodes;
        } catch (e) {
          return new Error(e.message);
        }
      })
      .next((nodes) => {
        const data = {
          data: {
            id: nodes.account.accountId,
          },
          include: {
            devices: {
              data: {
                account: nodes.account,
              },
            },
          },
        };

        return GetMyDrives.transform(data, edge, authorization);
      });
  }

  buildAction(_nearbyAction) {
    const account = this.getMpoDevices();
    const nearby = _nearbyAction || this.getNearByDrives.buildAction();

    return Action.parallel([nearby, account], true)
      .next((datas) => {
        const n = datas[0];
        const a = datas[1].devices;
        const accountId = datas[1].accountId;

        const nodes1 = keyBy(n.filter(node => node.accountId === accountId), 'id');
        const nodes2 = keyBy(a, 'id');
        return values(mergeWith(nodes1, nodes2, oldVal => oldVal));
        // return _(n)
        //   .filter(node => node.accountId === accountId)
        //   .keyBy('id')
        //   .mergeWith(_.keyBy(a, 'id'), oldVal => oldVal)
        //   .values();
      });
  }
}
