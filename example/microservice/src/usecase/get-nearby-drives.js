import Action from 'action-js';
import NodesMapper from '../helper/nodes-mapper';
import { extractToken } from '../helper/authorization-helper';

export default class GetNearbyDrives {
  constructor(localMds, http, authorization, edge) {
    this.localMds = localMds;
    this.http = http;
    this.edge = edge;
    this.authorization = authorization;
  }

  buildAction() {
    const { localMds, http, authorization, edge } = this;
    const accessToken = extractToken(authorization);

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
      const linkLocal = (nodes &&
        Array.isArray(nodes.localLinkNetwork.nodes) &&
        nodes.localLinkNetwork) ||
        new Error('failed to search for devices');
      return linkLocal;
    })
    .next(linkLocal => NodesMapper.transformMdsNodes(linkLocal.nodes));
  }
}
