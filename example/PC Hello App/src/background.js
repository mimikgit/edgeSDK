// This is main process of Electron, started as first thing when your
// app starts. It runs through entire life of your application.
// It doesn't have any windows which you can see on screen, but we can open
// window from here.

import path from 'path';
import url from 'url';
import crypto from 'crypto';
import queryString from 'query-string';
import rp from 'request-promise';
import WebSocket from 'ws';
import JsonRPC from 'simple-jsonrpc-js';
import { app, Menu, ipcMain, protocol } from 'electron';
// Special module holding environment variables which you declared
// in config/env_xxx.json file.
import env from 'env';
import { devMenuTemplate } from './menu/dev_menu_template';
import { editMenuTemplate } from './menu/edit_menu_template';
import createWindow from './helpers/window';
import { appId, redirectProtocol } from './helpers/constants';

let mainWindow;
let authWindow;
let token;

const MID_URI = 'https://mid.mimik360.com'; // 'https://mid-dev.mimikdev.com';

const EDGE_SDK_IP = '127.0.0.1'; // '172.22.2.23'; // Assume the edge SDK is running locally
const EDGE_SDK_PORT = 8083; // Currently the edge SDK default port is 8083
const LOCAL_EDGE_WS_URL = `ws://${EDGE_SDK_IP}:${EDGE_SDK_PORT}/ws/edge-service-api/v1`;

// Information to be filled in from mimik developer portal
// This is the app id of your app as it was generated on mimik developer portal
const APP_ID = appId;
// this would be the protocol section of the redirect uri
// from mimik developer portal (i.e. com.example)
const REDIRECT_PROTOCOL = redirectProtocol;
const REDIRECT_URI = `${REDIRECT_PROTOCOL}://oauth2callback`; // Adjust the URI to reflect the path you have entered in the mimik developer portal

function base64URLEncode(str) {
  return str.toString('base64')
    .replace(/\+/g, '-')
    .replace(/\//g, '_')
    .replace(/=/g, '');
}

const verifier = base64URLEncode(crypto.randomBytes(32));

function sha256(buffer) {
  return crypto.createHash('sha256').update(buffer).digest();
}

const challenge = base64URLEncode(sha256(verifier));

const redirect = encodeURIComponent(REDIRECT_URI);
const scope = 'openid edge:mcm edge:clusters edge:account:associate';
const unassociateScope = 'openid edge:account:unassociate';
const clientId = APP_ID;
const state =
      Math.random()
        .toString(36)
        .substring(2, 15) +
      Math.random()
        .toString(36)
        .substring(2, 15);

const audience = 'generic-edge';

// console.log(`v: ${verifier} / c: ${challenge}`);

const setApplicationMenu = () => {
  const menus = [editMenuTemplate];
  if (env.name !== 'production') {
    menus.push(devMenuTemplate);
  }
  Menu.setApplicationMenu(Menu.buildFromTemplate(menus));
};

// Save userData in separate folders for each environment.
// Thanks to this you can use production and development versions of the app
// on same machine like those are two separate apps.
if (env.name !== 'production') {
  const userDataPath = app.getPath('userData');
  app.setPath('userData', `${userDataPath} (${env.name})`);
}

app.on('ready', () => {
  setApplicationMenu();

  mainWindow = createWindow('main', {
    width: 1000,
    height: 600,
  });

  mainWindow.loadURL(url.format({
    pathname: path.join(__dirname, 'app.html'),
    protocol: 'file:',
    slashes: true,
  }));

  if (env.name === 'development') {
    mainWindow.openDevTools();
  }

  protocol.registerFileProtocol(REDIRECT_PROTOCOL, (request) => {
    const query = queryString.parseUrl(request.url);
    // console.log(`request url: ${request.url} \nquery string: ${JSON.stringify(query)}`);
    if (query && query.query && query.query.error) {
      authWindow.removeAllListeners('error');
      setImmediate(() => {
        authWindow.close();
      });
      mainWindow.webContents.send('oauth-login-reply', { status: false, message: query.query.error });
    } else {
      authWindow.removeAllListeners('done');
      setImmediate(() => {
        authWindow.close();
      });

      // console.log(`oauthcallback: ${code} : ${state}`);

      const options = {
        method: 'POST',
        uri: `${MID_URI}/token`,
        form: {
          grant_type: 'authorization_code',
          code: query.query.code,
          redirect_uri: REDIRECT_URI,
          code_verifier: verifier,
          client_id: clientId,
        },
      };

      rp(options)
        .then((parsedBody) => {
          token = JSON.parse(parsedBody);
          // const idData = jwt.decode(tokenJson.id_token);
          // console.log(`token: ${parsedBody} `);
          if (token && token.access_token && token.access_token.length > 0) {
            if (token.scope.indexOf('unassociate') >= 0) {
              mainWindow.webContents.send('oauth-unassociate-reply', { status: true, message: '', data: token });
            } else {
              mainWindow.webContents.send('oauth-login-reply', { status: true, message: 'Your are now logged in.', data: token });
            }
          }
        })
        .catch((error) => {
          console.error(JSON.stringify(error));
          mainWindow.webContents.send('oauth-login-reply', { status: false, message: error });
        });
    }
  });

  function getEdgeIdTokenCB(cb) {
    const ws = new WebSocket(LOCAL_EDGE_WS_URL);
    const jrpc = new JsonRPC();
    ws.jrpc = jrpc;
    ws.jrpc.toStream = (_msg) => {
      ws.send(_msg);
    };

    ws.on('open', () => {
      jrpc.call('getEdgeIdToken', null).then((result) => {
        cb(result);
        setImmediate(() => {
          ws.onmessage = undefined;
          ws.close();
        });
      }).catch((e) => {
        setImmediate(() => {
          ws.onmessage = undefined;
          ws.close();
        });
        cb(e);
      });
    });

    ws.on('message', (msgData) => {
      // const msg = JSON.parse(msgData);
      // debug('getMe socket message: ', msg);
      jrpc.messageHandler(msgData);
    });

    ws.on('error', (err) => {
      cb(err);
    });

    ws.on('close', () => {
      console.log('edge ws close');
    });
  }

  ipcMain.on('oauth-login', (event, arg) => {
    console.log(arg); // prints "login"
    // console.log(`AuthUrl: ${authUrl}`);

    getEdgeIdTokenCB((getEdgeIdTokenResult) => {
      if (getEdgeIdTokenResult && getEdgeIdTokenResult.id_token) {
        authWindow = createWindow('auth', {
          parent: mainWindow,
          modal: true,
          width: 1000,
          height: 600,
          webPreferences: {
            nodeIntegration: false,
          },
        });

        const authUrl = `${MID_URI}/auth?audience=${audience}&scope=${scope}&response_type=code&`
        + `client_id=${clientId}&code_challenge=${challenge}&code_challenge_method=S256&`
        + `edge_id_token=${getEdgeIdTokenResult.id_token}&redirect_uri=${redirect}&state=${state}`;

        authWindow.loadURL(authUrl);
        if (env.name === 'development') {
          authWindow.openDevTools();
        }
        authWindow.show();
      }
    });
  });

  ipcMain.on('oauth-unassociate', (event, arg) => {
    console.log(arg); // prints "unassociate"
    // console.log(`AuthUrl: ${authUrl}`);

    getEdgeIdTokenCB((getEdgeIdTokenResult) => {
      if (getEdgeIdTokenResult && getEdgeIdTokenResult.id_token) {
        authWindow = createWindow('auth', {
          parent: mainWindow,
          modal: true,
          width: 1000,
          height: 600,
          webPreferences: {
            nodeIntegration: false,
          },
        });
        const authUnassociateUrl = `${MID_URI}/auth?audience=${audience}&scope=${unassociateScope}&response_type=code&`
        + `client_id=${clientId}&code_challenge=${challenge}&code_challenge_method=S256&`
        + `edge_id_token=${getEdgeIdTokenResult.id_token}&redirect_uri=${redirect}&state=${state}`;


        authWindow.loadURL(authUnassociateUrl);
        if (env.name === 'development') {
          authWindow.openDevTools();
        }
        authWindow.show();
      }
    });
  });
});

app.on('window-all-closed', () => {
  app.quit();
});
