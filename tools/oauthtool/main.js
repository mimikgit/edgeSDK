const electron = require('electron');
const { session } = require('electron');
const ejse = require('ejs-electron');

// Module to control application life.
const app = electron.app;
const protocol = electron.protocol;
// Module to create native browser window.
const BrowserWindow = electron.BrowserWindow;

const path = require('path');
const URL = require('url');
const queryString = require('query-string');

const rp = require('request-promise');
const crypto = require('crypto');

// Keep a global reference of the window object, if you don't, the window will
// be closed automatically when the JavaScript object is garbage collected.
let mainWindow;

////////////////////////////////////////////////

const OAUTH_DOMAIN = 'https://mid.mimik360.com';
const SCOPES = [
       'edge:mcm',
       'write:me', 
       'read:users',
       'read:friendList',
       'delete:friend',        
       'read:requestFriendList',
       'read:friendRequestList',
       'add:requestFriend',
       'delete:requestFriend',
       'update:friendRequest',
       'delete:friendRequest',
       'update:me',
       'create:app',
       'delete:app',
       'edge:mcm',
       'read:me',
       'edge:clusters',
       'edge:account:associate',
       'openid', ]; // 'edge:account:unassociate'

ejse.data('oauthDomain', OAUTH_DOMAIN);
ejse.data('oauthScope', SCOPES.map(u => encodeURIComponent(u)).join('+'));

///////////////////////////////////////////////

function base64URLEncode(str) {
  return str.toString('base64')
      .replace(/\+/g, '-')
      .replace(/\//g, '_')
      .replace(/=/g, '');
}

var verifier = base64URLEncode(crypto.randomBytes(32));

function sha256(buffer) {
  return crypto.createHash('sha256').update(buffer).digest();
}

function createWindow () {
  // Create the browser window.

  protocol.registerHttpProtocol('com.mimik', (request, callback) => {
    const url = request.url.substr(12);
    const query = queryString.parse(url.replace('authorization_code?', ''));

    console.log(`url: ${url}`);
    console.log(`code: ${query.code}, state: ${query.state}`);

    if (!query.code) {
      const loginUrl = URL.format({
        pathname: path.join(__dirname, 'index.ejs'),
        protocol: 'file:',
        slashes: true,
        hash: `error-${JSON.stringify(query)}`,
      });

      mainWindow.loadURL(loginUrl);
    }

    var options = {
      method: 'POST',
      uri: `${OAUTH_DOMAIN}/token`,
      form: {
        grant_type: 'authorization_code',
        code: query.code,
        redirect_uri: 'com.mimik://authorization_code',
        client_id: query.state === '123xya' ? 'test' : 'test2',
        code_verifier: 'SqRg3wQWke2YSwMydkdilNHURfmmnt-Vlbvf8s2Ri58'
      }
    };
    rp(options)
      .then((parsedBody) => {
        const token = JSON.parse(parsedBody);
        console.log(`rp: ${JSON.stringify(token, null, 2)}`);
        session.defaultSession.cookies.get({}, (error, cookies) => {
          console.log(error, cookies)
        })

        const loginUrl = URL.format({
          pathname: path.join(__dirname, 'index.ejs'),
          protocol: 'file:',
          slashes: true,
          hash: parsedBody,
        });

        mainWindow.loadURL(loginUrl);
        // callback({path: path.normalize(`${__dirname}/login.html`)});
      })
      .catch((err) => {
        console.log(`${err}`);
        callback({path: path.normalize(`${__dirname}/error.html`)});
      });

  }, (error) => {
    if (error) console.error('Failed to register protocol');
  })

  mainWindow = new BrowserWindow({width: 800, height: 600});

  // and load the index.html of the app.
  mainWindow.loadURL(URL.format({
    pathname: path.join(__dirname, 'index.ejs'),
    protocol: 'file:',
    slashes: true
  }));

  // Open the DevTools.
  // mainWindow.webContents.openDevTools()

  // Emitted when the window is closed.
  mainWindow.on('closed', function () {
    // Dereference the window object, usually you would store windows
    // in an array if your app supports multi windows, this is the time
    // when you should delete the corresponding element.
    mainWindow = null
  });
}

// This method will be called when Electron has finished
// initialization and is ready to create browser windows.
// Some APIs can only be used after this event occurs.
app.on('ready', createWindow);

// Quit when all windows are closed.
app.on('window-all-closed', function () {
  // On OS X it is common for applications and their menu bar
  // to stay active until the user quits explicitly with Cmd + Q
  if (process.platform !== 'darwin') {
    app.quit();
  }
});

app.on('activate', function () {
  // On OS X it's common to re-create a window in the app when the
  // dock icon is clicked and there are no other windows open.
  if (mainWindow === null) {
    createWindow();
  }
});

// In this file you can include the rest of your app's specific main process
// code. You can also put them in separate files and require them here.
