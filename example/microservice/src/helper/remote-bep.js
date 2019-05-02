import Action from 'action-js';
import { extractTokenFromReq } from '../edge-pollyfill';

const getHmacCodeByReq = (req, nodeId) => new Action((cb) => {
  const { edge } = req.mimikContext;
  const accessToken = extractTokenFromReq(req);
  edge.getRequestBepHmacCode(accessToken, nodeId,
    hmacCode => cb(hmacCode),
    e => cb(e));
});

function getRemoteBep(apiPath, drive, http, hmac) {
  return new Action((cb) => {
    const sepHeader = `\r\nx-mimik-port: ${drive.routing.port}\r\nx-mimik-routing: ${drive.routing.id}`;
    http.request(({
      url: `${drive.routing.url}${apiPath}/bep?hmac=${hmac}`,
      authorization: sepHeader,
      success: (result) => {
        console.log(`bep result: ${result}`);
        cb(JSON.parse(result.data));
      },
      error: (err) => {
        console.log(`sep error: ${err.message}`);
        cb(new Error(err.message));
      },
    }));
  });
}

export default function requestRemoteBep(req, drive) {
  const { http, info } = req.mimikContext;
  const apiPath = info.apiRoot;

  const nodeId = drive.id;
  return getHmacCodeByReq(req, nodeId)
    .next(hmac => getRemoteBep(apiPath, drive, http, hmac));
}
