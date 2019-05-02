import Action from 'action-js';

import NodesMapper from '../helper/nodes-mapper';
import { extractToken } from '../helper/authorization-helper';

export default class GetProximityDrives {
  constructor(authorization, edge, serviceType) {
    this.edge = edge;
    this.authorization = authorization;
    this.serviceType = serviceType;
  }

  buildAction() {
    const { authorization, edge, serviceType } = this;
    const accessToken = extractToken(authorization);

    const request = new Action(
      (cb) => {
        edge.clusterDiscovery('proximity', accessToken, nodes => cb(nodes), err => cb(err));
      });

    return request
      .next((nodes) => {
        const proximity = (nodes &&
          Array.isArray(nodes.proximity.nodes) &&
          nodes.proximity) ||
          new Error('failed to search for devices');
        return proximity;
      })
      .next(proximity => NodesMapper.transformMdsNodes(proximity.nodes, null, serviceType));
  }
}
