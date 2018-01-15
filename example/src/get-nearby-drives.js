import Action from 'action-js';
import _ from 'lodash';

export default class GetNearbyDrives {
  constructor(localMds, http, edge) {
    this.localMds = localMds;
    this.http = http;
    this.edge = edge;
  }

  static transformLocalMdsNodes(json) {
    try {
      const nodes = JSON.parse(json);
      const linkLocal = nodes.localLinkNetwork;

      const copy = [];

      if (Array.isArray(linkLocal.nodes)) {
        linkLocal.nodes.forEach((node) => {
          const example = _.find(node.services, srv => srv.serviceType === 'example-v1');
          if (example && example.serviceId) {
            const name = _.find(node.attributes, att => att.name === 'name');
            const os = _.find(node.characteristics, att => att.name === 'os');
            copy.push({
              id: node.nodeId || node.id, // adapting v2 and v1
              accountId: node.accountId || node.account.id, // adapting v2 and v1
              name: name && name.value,
              os: os && os.value,
              url: node.addresses[0].url.href,
            });
          }
        });
      }

      return copy;
    } catch (e) {
      return new Error(e);
    }
  }

  buildAction() {
    const { localMds, http, edge } = this;
    return new Action(
      (cb) => {
        http.request(({
          url: `${localMds}/nodes?clusters=linkLocal`,
          success: (result) => {
            cb(result.data);
          },
          error: (err) => {
            cb(new Error(err));
          },
        }));
      },
    )
    .next((json) => {
      try {
        const nodes = JSON.parse(json);
        return JSON.stringify(nodes.data);
      } catch (e) {
        return new Error('not a valid json');
      }
    })
    .next(encryptedJson => new Action(
      (cb) => {
        edge.decryptEncryptedNodesJson({
          type: 'local',
          data: encryptedJson,
          success: (result) => {
            cb(result.data);
          },
          error: (err) => {
            cb(new Error(err));
          },
        });
      }))
    .next(json => GetNearbyDrives.transformLocalMdsNodes(json));
  }
}
