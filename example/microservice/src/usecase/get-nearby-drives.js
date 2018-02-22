import Action from 'action-js';
import NodesMapper from '../helper/nodes-mapper';

export default class GetNearbyDrives {
  constructor(localMds, http, edge) {
    this.localMds = localMds;
    this.http = http;
    this.edge = edge;
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
            cb(new Error(err.message));
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
      const linkLocal = (nodes && nodes.localLinkNetwork) || {
        nodes: [],
      };

      return linkLocal;
    })
    .next((linkLocal) => {
      if (Array.isArray(linkLocal.nodes)) {
        return NodesMapper.transformMdsNodes(linkLocal.nodes);
      }

      return [];
    });
  }
}
