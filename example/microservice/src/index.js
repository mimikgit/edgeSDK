import Router from 'router';
import queryString from 'query-string';
import Action from 'action-js';
import parseUrl from 'parseurl';
import GetProximityDrives from './usecase/get-proximity-drives';
import GetNearbyDrives from './usecase/get-nearby-drives';
import GetMyDrives from './usecase/get-my-drives';
import ApiError from './helper/api-error';
import FindNodeByNodeId from './usecase/find-node-by-node-id';

const app = Router({
  mergeParams: true,
});

function toJson(obj) {
  return JSON.stringify(obj, null, 2);
}

function mimikInject(context, req) {
  const { MPO, uMDS } = context.env;
  const edge = context.edge;
  const http = context.http;
  const authorization = req.authorization;
  parseUrl(req);
  const query = queryString.parse(req._parsedUrl.query);
  const userToken = (query && query.userAccessToken) || '';

  const getNearByDrives = new GetNearbyDrives(uMDS, http, authorization, edge);
  const getProximityDrives = new GetProximityDrives(uMDS, http, authorization, edge);

  const getMyDrives = new GetMyDrives(getNearByDrives, MPO, uMDS, http,
    edge, authorization, userToken);

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

  const userAccessToken = query && query.userAccessToken;
  const errorAction = new Action(cb => cb(new ApiError(403, 'userAccessToken must not be null')));

  let action;
  switch (type) {
    case 'network':
      action = getNearByDrives.buildAction();
      break;
    case 'account':
      if (getMyDrives.mpo && !userAccessToken) {
        action = errorAction;
      } else {
        action = getMyDrives.buildAction();
      }
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
const requestBep = edge => new Action(
  (cb) => {
    edge.requestBep({
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
const requestRemoteBep = (drive, http) => new Action(
  (cb) => {
    const sepHeader = `\r\nx-mimik-port: ${drive.routing.port}\r\nx-mimik-routing: ${drive.routing.id}`;
    http.request(({
      url: `${drive.routing.url}/superdrive/v1/bep`,
      authorization: sepHeader,
      success: (result) => {
        cb(JSON.parse(result.data));
      },
      error: (err) => {
        console.log(`sep error: ${err.message}`);
        cb(new Error(err.message));
      },
    }));
  });

app.get('/nodes/:nodeId', (req, res) => {
  const { nodeId } = req.params;
  const { findNode } = req.mimikContext;
  const query = queryString.parse(req._parsedUrl.query);
  if (!(query && query.userAccessToken)) {
    res.writeError(new ApiError(403, 'userAccessToken must not be null'));
    return;
  }

  findNode.buildAction(nodeId)
    .next((drive) => {
      if (drive.url) {
        res.end(toJson(drive));
        return 0;
      }

      const { http } = req.mimikContext;
      return requestRemoteBep(drive, http)
        .next(url => Object.assign({}, drive, {
          url: url.href,
        }))
        .next(d => res.end(toJson(d)));
    })
    // .next(drive => res.end(toJson(drive)))
    .guard(e => res.writeError(new ApiError(400, e)))
    .go();
});

app.get('/bep', (req, res) => {
  const { edge } = req.mimikContext;

  requestBep(edge)
    .next(bep => res.end(toJson(bep)))
    .guard(e => res.writeError(new ApiError(400, e)))
    .go();
});
