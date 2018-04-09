import Router from 'router';
import queryString from 'query-string';
import Action from 'action-js';
import parseUrl from 'parseurl';
import GetNearbyDrives from './usecase/get-nearby-drives';
import GetMyDrives from './usecase/get-my-drives';
import ApiError from './helper/api-error';

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

  const getMyDrives = new GetMyDrives(getNearByDrives, MPO, http,
    edge, authorization, userToken);

  return ({
    ...context,
    getNearByDrives,
    getMyDrives,
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
  const { getNearByDrives, getMyDrives } = req.mimikContext;

  const query = queryString.parse(req._parsedUrl.query);
  const type = (query && query.type) || 'nearby';

  let action;
  if (!(query && query.userAccessToken)) {
    action = new Action(cb => cb(new ApiError(403, 'userAccessToken must not be null')));
  } else {
    switch (type) {
      case 'nearby':
        action = getNearByDrives.buildAction();
        break;
      case 'account':
        action = getMyDrives.buildAction();
        break;

      default:
        action = new Action(cb => cb(new Error(`"${type}" type is not supported`)));
        break;
    }
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
