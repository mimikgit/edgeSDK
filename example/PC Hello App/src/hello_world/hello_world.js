import fs from 'fs';
import WebSocket from 'ws';
import JsonRPC from 'simple-jsonrpc-js';
import { remote } from 'electron';

const { app } = remote;

const EDGE_SDK_IP = '127.0.0.1'; // '172.22.2.23'; // Assume the edge SDK is running locally
const EDGE_SDK_PORT = 8083; // Currently the edge SDK default port is 8083

const LOCAL_URL = `http://${EDGE_SDK_IP}:${EDGE_SDK_PORT}`; // "http://127.0.0.1:8083"
const LOCAL_EDGE_WS_URL = `ws://${EDGE_SDK_IP}:${EDGE_SDK_PORT}/ws/edge-service-api/v1`;

// Gets the token from .mcmUserToken file
function getToken() {
  const token = JSON.parse(sessionStorage.getItem('token'));
  return token.access_token;
}

// return a text for greeting
export function greet() {
  return 'Hello mimik!';
}

// Generic GET method using fetch (https://developer.mozilla.org/en-US/docs/Web/API/Fetch_API)
// If you are more comfortable with XMLHttpRequest you can substitute any of the fetch calls with
// XMLHttpRequest or any other method to call REST APIs
function fetchGET(Url) {
  // Generating header
  const authHeader = new Headers({
    Authorization: `Bearer ${getToken()}`,
  });
  // Call to the Url with get method and the Authorization header
  return fetch(Url, {
    method: 'get',
    headers: authHeader,
  })
    .then(response => response.json())
    .then((response) => {
    // console.log(JSON.stringify(response));
      const data = response;
      return { data };
    })
    .catch((error) => {
      console.log(error);
    });
}

// A call to POST specifically yo upload a file
function fetchUPLOAD(fileName, buffer, Url) {
  const form = new FormData();
  form.append('image', new Blob([
    buffer,
  ], { type: 'application/tar' }), fileName);
  const authHeader = new Headers({
    Authorization: `Bearer ${getToken()}`,
  });
  return fetch(Url, {
    method: 'post',
    headers: authHeader,
    body: form,
  })
    .then(response => response.json())
    .then((response) => {
    // console.log(JSON.stringify(response));
      const { data } = response;
      return { data };
    })
    .catch((error) => {
      console.log(error);
    });
}

// Call to POST method with body
function fetchPOST(containerData, Url) {
  const authHeader = new Headers({
    'Content-Type': 'application/json',
    Authorization: `Bearer ${getToken()}`,
  });
  return fetch(Url, {
    method: 'post',
    headers: authHeader,
    body: containerData,
  })
    .then(response => response.json())
    .then((response) => {
    // console.log(JSON.stringify(response));
      const { data } = response;
      return { data };
    })
    .catch((error) => {
      console.log(error);
    });
}

function isObject(obj) {
  return (typeof obj === 'object' && obj !== null);
}

function StatusError(message) {
  return message;
}

function wsResponse(data) {
  const result = {};
  result.data = {};
  if (isObject(data)) {
    result.state = 'OK';
    result.data = data;
    // result.AccountMatch = data.accountId === userId;
    result.Empty = !(data && data.accountId !== '');
    return result;
  }
  result.state = 'NOTOK';
  throw StatusError(result);
}

function wsError(error) {
  if (error && error.state) {
    return error;
  }
  const result = {};
  result.state = 'ERROR';
  result.error = error;
  return result;
}

export function accountAssociation(cb) {
  const token = JSON.parse(sessionStorage.getItem('token'));
  const ws = new WebSocket(LOCAL_EDGE_WS_URL);
  const jrpc = new JsonRPC();
  ws.jrpc = jrpc;
  ws.jrpc.toStream = (_msg) => {
    ws.send(_msg);
  };

  ws.on('open', () => {
    // console.log('associateAccount socket open ');
    jrpc.call('associateAccount', [token.access_token]).then((result) => {
      // console.log('associateAccount result: ', result);
      const data = wsResponse({ accountId: result });
      cb(data);
      setImmediate(() => {
        ws.onmessage = undefined;
        ws.close();
      });
    }).catch((e) => {
      console.log('catch error:', e);
      setImmediate(() => {
        ws.onmessage = undefined;
        ws.close();
      });
      cb(wsError(e));
    });
  });

  ws.on('message', (msgData) => {
    // const msg = JSON.parse(msgData);
    // console.log('associateAccount socket message: ', msg);
    jrpc.messageHandler(msgData);
  });

  ws.on('error', (err) => {
    // console.log('edge ws onerror', err);
    cb(wsError(err));
  });

  ws.on('close', () => {
    // console.log('edge ws close');
  });
}

export function getMe(cb) {
  const token = JSON.parse(sessionStorage.getItem('token'));
  const ws = new WebSocket(LOCAL_EDGE_WS_URL);
  const jrpc = new JsonRPC();
  ws.jrpc = jrpc;
  ws.jrpc.toStream = (_msg) => {
    ws.send(_msg);
  };

  ws.on('open', () => {
    // console.log('getMe socket open');
    jrpc.call('getMe', [token.access_token]).then((result) => {
      // console.log('getMe result: ', result);
      const data = wsResponse(result);
      cb(data);
      setImmediate(() => {
        ws.onmessage = undefined;
        ws.close();
      });
    }).catch((e) => {
      console.log('catch error:', e);
      setImmediate(() => {
        ws.onmessage = undefined;
        ws.close();
      });
      cb(wsError(e));
    });
  });

  ws.on('message', (msgData) => {
    // const msg = JSON.parse(msgData);
    // console.log('getMe socket message: ', msg);
    jrpc.messageHandler(msgData);
  });

  ws.on('error', (err) => {
    // console.log('edge ws onerror', err);
    cb(wsError(err));
  });

  ws.on('close', () => {
    // console.log('edge ws close');
  });
}

export function undoAccountAssociation(cb) {
  const token = JSON.parse(sessionStorage.getItem('token'));

  const ws = new WebSocket(LOCAL_EDGE_WS_URL);
  const jrpc = new JsonRPC();
  ws.jrpc = jrpc;
  ws.jrpc.toStream = (_msg) => {
    ws.send(_msg);
  };

  ws.on('open', () => {
    // console.log('unassociateAccount socket open');
    jrpc.call('unassociateAccount', [token.access_token]).then((result) => {
      // console.log('unassociateAccount result: ', result);
      const data = wsResponse({ accountId: result });
      cb(data);
      setImmediate(() => {
        ws.onmessage = undefined;
        ws.close();
      });
    }).catch((e) => {
      // console.log('catch error:', e);
      setImmediate(() => {
        ws.onmessage = undefined;
        ws.close();
      });
      cb(wsError(e));
    });
  });

  ws.on('message', (msgData) => {
    // const msg = JSON.parse(msgData);
    // console.log('unassociateAccount socket message: ', msg);
    jrpc.messageHandler(msgData);
  });

  ws.on('error', (err) => {
    // console.log('edge ws onerror', err);
    cb(wsError(err));
  });

  ws.on('close', () => {
    // console.log('edge ws close');
  });
}

// Get the list of images return response via call back
export function getImageState(cb) {
  const fetchData = fetchGET(`${LOCAL_URL}/mcm/v1/images`);
  fetchData.then((data) => {
    // console.log(data);
    cb(data.data);
  });
}

// Get the list of containers return response via call back
export function getContainerState(cb) {
  const fetchData = fetchGET(`${LOCAL_URL}/mcm/v1/containers`);
  fetchData.then((data) => {
    // console.log(data);
    cb(data.data);
  });
}

// Add an image and return response via call back
export function addImage(cb) {
  // you can hard code the path to the folder containing the  example-v1.tar file bellow
  let containersPath = '';
  if (containersPath === '') {
    const appData = app.getPath('home');
    const appExe = app.getPath('exe').replace('/MimikSampleApp', '');
    switch (process.platform) {
      case 'win32':
        containersPath = `${appData}\\appData\\Local\\Programs\\mimik-sample-app\\containers\\`;
        break;
      case 'darwin':
        containersPath = '/Applications/mimik Sample App.app/Contents/containers/';
        break;
      default:
        containersPath = `${appExe}/containers/`;
    }
  }
  const fileName = 'example-v1.tar';
  const buffer = fs.readFileSync(`${containersPath}/${fileName}`);
  const url = `${LOCAL_URL}/mcm/v1/images`;
  const fetchData = fetchUPLOAD(fileName, buffer, url);
  fetchData.then((data) => {
    // console.log(data.data);
    cb(data.data);
  });
}

// Add a container and return response via call back
export function addContainer(cb) {
  const containerData = '{"name": "example-v1", "image": "example-v1", "env": {"MCM.BASE_API_PATH": "/example/v1", "MCM.WEBSOCKET_SUPPORT": "false", "uMDS": "http://127.0.0.1:8083/mds/v1"}}';
  const url = `${LOCAL_URL}/mcm/v1/containers`;
  const fetchData = fetchPOST(containerData, url);
  fetchData.then((data) => {
    // console.log(data.data);
    cb(data.data);
  });
}

// Get the list of devices return response via call back
export function getDevices(cb) {
  const fetchData = fetchGET(`${LOCAL_URL}/example/v1/drives?type=nearby`);
  fetchData.then((data) => {
    // console.log(data);
    cb(data.data);
  });
}

// Call the hello method and return response via call back
export function sayHello(Url, cb) {
  const fetchData = fetchGET(Url);
  fetchData.then((data) => {
    // console.log(data);
    cb(data);
  });
}
