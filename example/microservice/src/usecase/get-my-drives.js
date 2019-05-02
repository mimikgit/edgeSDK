import Action from 'action-js';
import keyBy from 'lodash/keyBy';
import mergeWith from 'lodash/mergeWith';
import values from 'lodash/values';

import NodesMapper from '../helper/nodes-mapper';
import { extractToken } from '../helper/authorization-helper';

export default class GetMyDrives {
  constructor(getNearByDrives, mpo, edge, authorization, serviceType) {
    this.getNearByDrives = getNearByDrives;
    this.mpo = mpo;
    this.edge = edge;
    this.authorization = authorization;
    this.serviceType = serviceType;
  }

  static transform(data, serviceType) {
    const obj = {
      accountId: data.accountId,
      devices: NodesMapper.transformMdsNodes(data.nodes, null, serviceType),
    };

    return Action.wrap(obj);
  }

  getMpoDevices() {
    const { authorization, edge, serviceType } = this;
    const accessToken = extractToken(authorization);

    return new Action(
      (cb) => {
        edge.clusterDiscovery('account', accessToken, nodes => cb(nodes), err => cb(err));
      })
      .next(nodes => GetMyDrives.transform(nodes, serviceType));
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
      });
  }
}
