import Action from 'action-js';

import NodesMapper from '../helper/nodes-mapper';
import { extractToken } from '../helper/authorization-helper';

export default class GetNearbyDrives {
  constructor(authorization, edge, serviceType) {
    this.edge = edge;
    this.authorization = authorization;
    this.serviceType = serviceType;
  }

  buildAction() {
    const { authorization, edge, serviceType } = this;
    const accessToken = extractToken(authorization);

    return new Action(
      (cb) => {
        edge.clusterDiscovery('linkLocal', accessToken, nodes => cb(nodes), err => cb(err));
      })
    .next((nodes) => {
      const linkLocal = (nodes &&
        Array.isArray(nodes.localLinkNetwork.nodes) &&
        nodes.localLinkNetwork) ||
        new Error('failed to search for devices');
      return linkLocal;
    })
    .next(linkLocal => NodesMapper.transformMdsNodes(linkLocal.nodes, null, serviceType));
  }
}
