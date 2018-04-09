import find from 'lodash/find';

export default class NodesMapper {
  static getRouting(node) {
    const route = {
      nodeId: node.id,
      localLinkNetworkId: node.localLinkNetworkId,
    };

    const json = JSON.stringify(route);

    const proxy = find(node.addresses, addr => addr.type === 'proxy');
    return {
      id: Duktape.enc('base64', json),
      port: proxy && proxy.routingPort,
      url: proxy && proxy.url && proxy.url.href,
    };
  }

  static getUrl(node) {
    const pub = find(node.addresses, addr => addr.type === 'public');
    const proxy = find(node.addresses, addr => addr.type === 'proxy');
    const local = find(node.addresses, addr => addr.type === 'local');

    if (pub && pub.url && pub.url.href && pub.url.href.startsWith('https://')) {
      return pub.url.href;
    }

    if (proxy) {
      return undefined;
    }

    return local.url.href;
  }

  static transformMdsNodes(nodes, avatarData) {
    try {
      const copy = [];
      nodes.forEach((node) => {
        const example = find(node.services, srv => srv.serviceType === 'example-v1');
        if (example) {
          const name = find(node.attributes, att => att.name === 'name');
          const os = find(node.characteristics, att => att.name === 'os');
          copy.push({
            id: node.nodeId || node.id, // adapting v2 and v1
            accountId: node.accountId || node.account.id, // adapting v2 and v1
            name: name && name.value,
            routing: NodesMapper.getRouting(node),
            os: os && os.value,
            avatar: avatarData,
            url: NodesMapper.getUrl(node), // node.addresses[0].url.href,
          });
        }
      });

      return copy;
    } catch (e) {
      return new Error(e.message);
    }
  }
}
