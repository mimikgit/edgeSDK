import Router from 'router';
import queryString from 'query-string';
import Action from 'action-js';
import parseUrl from 'parseurl';
import GetProximityDrives from './usecase/get-proximity-drives';
import GetNearbyDrives from './usecase/get-nearby-drives';
import GetMyDrives from './usecase/get-my-drives';
import ApiError from './helper/api-error';
import FindNodeByNodeId from './usecase/find-node-by-node-id';
import { extendEdgeContext } from './edge-pollyfill';
import requestRemoteBep from './helper/remote-bep';

const app = Router({
  mergeParams: true,
});

function toJson(obj) {
  return JSON.stringify(obj, null, 2);
}

function mimikInject(context, req) {
  const { uMDS } = context.env;
  const mimikContext = extendEdgeContext(context);

  const edge = mimikContext.edge;
  const serviceType = context.info.serviceType;
  const authorization = req.authorization;
  parseUrl(req);

  const getNearByDrives = new GetNearbyDrives(authorization, edge, serviceType);
  const getProximityDrives = new GetProximityDrives(authorization, edge, serviceType);

  const getMyDrives = new GetMyDrives(getNearByDrives, uMDS,
    edge, authorization, serviceType);

  const findNode = new FindNodeByNodeId(getNearByDrives, getMyDrives,
    getProximityDrives);

  return ({
    ...context,
    getNearByDrives,
    getProximityDrives,
    getMyDrives,
    findNode,
  });
}

mimikModule.exports = (context, req, res) => {
  req.mimikContext = mimikInject(context, req);
  res.writeError = (apiError) => {
    res.statusCode = apiError.code;
    const json = JSON.stringify({
      code: apiError.code,
      message: apiError.message,
    });

    res.end(json);
  };

  app(req, res, (e) => {
    const err = (e && new ApiError(400, e.message)) ||
      new ApiError(404, 'not found');
    res.writeError(err);
  });
};

app.get('/drives', (req, res) => {
  const { getNearByDrives, getProximityDrives, getMyDrives } = req.mimikContext;

  const query = queryString.parse(req._parsedUrl.query);
  const type = (query && query.type) || 'network';

  let action;
  switch (type) {
    case 'network':
      action = getNearByDrives.buildAction();
      break;
    case 'account':
      action = getMyDrives.buildAction();
      break;
    case 'nearby':
      action = getProximityDrives.buildAction();
      break;
    default:
      action = new Action(cb => cb(new Error(`"${type}" type is not supported`)));
      break;
  }
  action
    .next((data) => {
      const dataList = { type, data };

      return toJson(dataList);
    })
    .next(json => res.end(json))
    .guard((err) => {
      console.log(`example ==> ${err.message}`);
      res.writeError(new ApiError(400, err.message));
    })
    .go();
});

app.get('/hello', (req, res) => {
  const json = toJson({
    JSONMessage: 'Hello WORLD!!!',
  });
  res.end(json);
});

const requestBep = (edge, hmac) => new Action(
  (cb) => {
    edge.requestBep({
      code: hmac,
      success: (result) => {
        cb({
          href: result.data,
        });
      },
      error: (err) => {
        cb(new Error(err.message));
      },
    });
  });

app.get('/nodes/:nodeId', (req, res) => {
  const { nodeId } = req.params;
  const { findNode } = req.mimikContext;

  findNode.buildAction(nodeId)
    .next((drive) => {
      if (drive.url) {
        res.end(toJson(drive));
        return 0;
      }

      return requestRemoteBep(req, drive)
        .next(url => Object.assign({}, drive, {
          url: url.href,
        }))
        .next(d => res.end(toJson(d)));
    })
    .guard(e => res.writeError(new ApiError(400, e)))
    .go();
});

app.get('/bep', (req, res) => {
  const { edge } = req.mimikContext;

  const query = queryString.parse(req._parsedUrl.query);
  const { hmac } = query;

  if (!hmac) {
    res.writeError(new ApiError(403, 'hmac is missing'));
    return;
  }

  requestBep(edge, hmac)
    .next(bep => res.end(toJson(bep)))
    .guard(e => res.writeError(new ApiError(400, e)))
    .go();
});
