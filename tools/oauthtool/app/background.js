/******/ (function(modules) { // webpackBootstrap
/******/ 	// The module cache
/******/ 	var installedModules = {};
/******/
/******/ 	// The require function
/******/ 	function __webpack_require__(moduleId) {
/******/
/******/ 		// Check if module is in cache
/******/ 		if(installedModules[moduleId]) {
/******/ 			return installedModules[moduleId].exports;
/******/ 		}
/******/ 		// Create a new module (and put it into the cache)
/******/ 		var module = installedModules[moduleId] = {
/******/ 			i: moduleId,
/******/ 			l: false,
/******/ 			exports: {}
/******/ 		};
/******/
/******/ 		// Execute the module function
/******/ 		modules[moduleId].call(module.exports, module, module.exports, __webpack_require__);
/******/
/******/ 		// Flag the module as loaded
/******/ 		module.l = true;
/******/
/******/ 		// Return the exports of the module
/******/ 		return module.exports;
/******/ 	}
/******/
/******/
/******/ 	// expose the modules object (__webpack_modules__)
/******/ 	__webpack_require__.m = modules;
/******/
/******/ 	// expose the module cache
/******/ 	__webpack_require__.c = installedModules;
/******/
/******/ 	// define getter function for harmony exports
/******/ 	__webpack_require__.d = function(exports, name, getter) {
/******/ 		if(!__webpack_require__.o(exports, name)) {
/******/ 			Object.defineProperty(exports, name, {
/******/ 				configurable: false,
/******/ 				enumerable: true,
/******/ 				get: getter
/******/ 			});
/******/ 		}
/******/ 	};
/******/
/******/ 	// getDefaultExport function for compatibility with non-harmony modules
/******/ 	__webpack_require__.n = function(module) {
/******/ 		var getter = module && module.__esModule ?
/******/ 			function getDefault() { return module['default']; } :
/******/ 			function getModuleExports() { return module; };
/******/ 		__webpack_require__.d(getter, 'a', getter);
/******/ 		return getter;
/******/ 	};
/******/
/******/ 	// Object.prototype.hasOwnProperty.call
/******/ 	__webpack_require__.o = function(object, property) { return Object.prototype.hasOwnProperty.call(object, property); };
/******/
/******/ 	// __webpack_public_path__
/******/ 	__webpack_require__.p = "";
/******/
/******/ 	// Load entry module and return exports
/******/ 	return __webpack_require__(__webpack_require__.s = 2);
/******/ })
/************************************************************************/
/******/ ([
/* 0 */
/***/ (function(module, exports) {

module.exports = require("electron");

/***/ }),
/* 1 */
/***/ (function(module, exports) {

module.exports = require("url");

/***/ }),
/* 2 */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
Object.defineProperty(__webpack_exports__, "__esModule", { value: true });
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0_electron__ = __webpack_require__(0);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0_electron___default = __webpack_require__.n(__WEBPACK_IMPORTED_MODULE_0_electron__);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_1_path__ = __webpack_require__(3);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_1_path___default = __webpack_require__.n(__WEBPACK_IMPORTED_MODULE_1_path__);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_2_url__ = __webpack_require__(1);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_2_url___default = __webpack_require__.n(__WEBPACK_IMPORTED_MODULE_2_url__);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_3_crypto__ = __webpack_require__(4);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_3_crypto___default = __webpack_require__.n(__WEBPACK_IMPORTED_MODULE_3_crypto__);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_4_query_string__ = __webpack_require__(5);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_4_query_string___default = __webpack_require__.n(__WEBPACK_IMPORTED_MODULE_4_query_string__);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_5_request_promise__ = __webpack_require__(6);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_5_request_promise___default = __webpack_require__.n(__WEBPACK_IMPORTED_MODULE_5_request_promise__);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_6_env__ = __webpack_require__(7);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_6_env___default = __webpack_require__.n(__WEBPACK_IMPORTED_MODULE_6_env__);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_7__menu_dev_menu_template__ = __webpack_require__(8);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_8__menu_edit_menu_template__ = __webpack_require__(9);













// global reference to mainWindow (necessary to prevent window from being garbage collected)
let mainWindow;
let authWindow;
let devClientId;
let devRidirectUri;

////////////////////////////////////////////////

const OAUTH_DOMAIN = 'https://mid.mimik360.com';
const SCOPES = [
//  'write:me', 
//  'read:users',
//  'read:friendList',
//  'delete:friend',        
//  'read:requestFriendList',
//  'read:friendRequestList',
//  'add:requestFriend',
//  'delete:requestFriend',
//  'update:friendRequest',
//  'delete:friendRequest',
//  'update:me',
//  'create:app',
//  'delete:app',
// 'read:me',
'edge:mcm', 'edge:clusters', 'edge:account:associate', 'openid'];

const RESET_SCOPES = ['openid', 'edge:account:unassociate'];

///////////////////////////////////////////////

function base64URLEncode(str) {
  return str.toString('base64').replace(/\+/g, '-').replace(/\//g, '_').replace(/=/g, '');
}

const verifier = base64URLEncode(__WEBPACK_IMPORTED_MODULE_3_crypto___default.a.randomBytes(32));

function sha256(buffer) {
  return __WEBPACK_IMPORTED_MODULE_3_crypto___default.a.createHash('sha256').update(buffer).digest();
}

function getProtocol(url) {
  if (typeof url === 'undefined' || url === null || url === '') {
    return null;
  }

  const regex = /^(.+):\/\/(([^:/?#]*)(?::([0-9]+))?)([/]{0,1}[^?#]*)(\?[^#]*|)(#.*|)$/;
  const match = url.match(regex);
  const data = match && {
    url,
    protocol: match[1],
    host: match[2],
    hostname: match[3],
    port: match[4],
    pathname: match[5],
    search: match[6],
    hash: match[7]
  };
  if (data.protocol) {
    return data.protocol;
  }
  return null;
}

const setApplicationMenu = () => {
  const menus = [__WEBPACK_IMPORTED_MODULE_8__menu_edit_menu_template__["a" /* editMenuTemplate */]];
  if (__WEBPACK_IMPORTED_MODULE_6_env___default.a.name !== 'production') {
    menus.push(__WEBPACK_IMPORTED_MODULE_7__menu_dev_menu_template__["a" /* devMenuTemplate */]);
  }
  __WEBPACK_IMPORTED_MODULE_0_electron__["Menu"].setApplicationMenu(__WEBPACK_IMPORTED_MODULE_0_electron__["Menu"].buildFromTemplate(menus));
};

function createMainWindow() {
  mainWindow = new __WEBPACK_IMPORTED_MODULE_0_electron__["BrowserWindow"]({
    width: 1000,
    height: 600,
    webPreferences: {
      nativeWindowOpen: true
    }
  });

  __WEBPACK_IMPORTED_MODULE_0_electron__["protocol"].registerHttpProtocol('openid', (request, callback) => {
    const _url = request.url.substr('openid://'.length);
    const query = __WEBPACK_IMPORTED_MODULE_4_query_string___default.a.parse(_url.replace('callback?', ''));

    console.log(`QUERY: ${JSON.stringify(query)}`);

    devClientId = query.client_id;
    devRidirectUri = query.redirect_uri;

    // ejse.data('clientId', devClientId);

    if (query.protocol) {
      const redirectProtocol = getProtocol(devRidirectUri);
      console.log(`redirectProtocol ${redirectProtocol}`);

      if (redirectProtocol) {
        __WEBPACK_IMPORTED_MODULE_0_electron__["protocol"].registerHttpProtocol(redirectProtocol, (request, callback) => {
          const url = request.url.substr(12);
          // const query = queryString.parse(url.replace('authorization_code?', ''));
          const query = __WEBPACK_IMPORTED_MODULE_4_query_string___default.a.parseUrl(request.url);

          console.log(`url: ${url} ----- ${JSON.stringify(query)}`);
          console.log(`code: ${query.query.code}, state: ${query.query.state}`);

          authWindow.removeAllListeners('done');
          setImmediate(() => {
            authWindow.close();
          });

          if (!query.query.code) {

            // const loginUrl = `file://${__dirname}/app.html`;

            // mainWindow.loadURL(loginUrl);

            setTimeout(() => {
              mainWindow.webContents.send('oauth-login-reply', { status: false, message: query.query, devClientId, devRidirectUri });
            }, 150);
          } else {
            var options = {
              method: 'POST',
              uri: `${OAUTH_DOMAIN}/token`,
              form: {
                grant_type: 'authorization_code',
                code: query.query.code,
                redirect_uri: devRidirectUri,
                client_id: devClientId,
                code_verifier: 'SqRg3wQWke2YSwMydkdilNHURfmmnt-Vlbvf8s2Ri58'
              }
            };

            __WEBPACK_IMPORTED_MODULE_5_request_promise___default()(options).then(parsedBody => {
              const token = JSON.parse(parsedBody);

              console.log(`rp: ${JSON.stringify(token, null, 2)}`);
              __WEBPACK_IMPORTED_MODULE_0_electron__["session"].defaultSession.cookies.get({}, (error, cookies) => {
                console.log(error, cookies);
              });

              // const loginUrl = `file://${__dirname}/app.html`;

              // mainWindow.loadURL(loginUrl);

              if (token.id_token) {
                token.id_token = null;
              }

              setTimeout(() => {
                mainWindow.webContents.send('oauth-login-reply', { status: true, token, devClientId, devRidirectUri });
              }, 150);
            }).catch(err => {
              console.log(`${err}`);
              // callback({path: path.normalize(`${__dirname}/error.html`)});
              // const loginUrl = `file://${__dirname}/app.html`;

              // mainWindow.loadURL(loginUrl);

              setTimeout(() => {
                mainWindow.webContents.send('oauth-login-reply', { status: false, message: err, devClientId, devRidirectUri });
              }, 150);
            });
          }
        }, error => {
          if (error) {
            console.error(`Failed to register protocol: ${redirectProtocol}`);
            mainWindow.webContents.send('protocol-reply', { status: false, message: { error: 'Setup Redirect', error_description: 'Failed to register protocol' } });
          } else {
            console.error(`Registered protocol: ${redirectProtocol}`);
            mainWindow.webContents.send('protocol-reply', { status: true, data: 'Setup Redirect done.' });
          }
        });
      }
    } else {
      const oauthScope = query.reset ? RESET_SCOPES.map(u => encodeURIComponent(u)).join('+') : SCOPES.map(u => encodeURIComponent(u)).join('+');

      const redirect = encodeURIComponent(devRidirectUri);
      const url = `${OAUTH_DOMAIN}/auth?redirect_uri=${redirect}&scope=${oauthScope}&client_id=${devClientId}&state=xyz&response_type=code&code_challenge=czD7gtNh2SowYqxpN5OSf5a6wIiszEZ9AvRHGvwIJS4&code_challenge_method=S256`;

      // mainWindow.loadURL(url);

      authWindow = new __WEBPACK_IMPORTED_MODULE_0_electron__["BrowserWindow"]({
        parent: mainWindow,
        modal: true,
        width: 1000,
        height: 600,
        webPreferences: {
          nodeIntegration: false
        }
      });

      authWindow.loadURL(url);
      if (__WEBPACK_IMPORTED_MODULE_6_env___default.a.name === 'development') {
        authWindow.openDevTools();
      }
      authWindow.show();
    }
  });

  mainWindow.loadURL(`file://${__dirname}/app.html`);

  if (__WEBPACK_IMPORTED_MODULE_6_env___default.a.name === 'development') {
    mainWindow.openDevTools();
  }

  mainWindow.on('closed', () => {
    mainWindow = null;
  });

  mainWindow.webContents.on('devtools-opened', () => {
    mainWindow.focus();
    setImmediate(() => {
      mainWindow.focus();
    });
  });
}

// quit application when all windows are closed
__WEBPACK_IMPORTED_MODULE_0_electron__["app"].on('window-all-closed', () => {
  // on macOS it is common for applications to stay open until the user explicitly quits
  if (process.platform !== 'darwin') {
    __WEBPACK_IMPORTED_MODULE_0_electron__["app"].quit();
  }
});

__WEBPACK_IMPORTED_MODULE_0_electron__["app"].on('activate', () => {
  // on macOS it is common to re-create a window even after all windows have been closed
  if (mainWindow === null) {
    createMainWindow();
  }
});

// create main BrowserWindow when electron is ready
__WEBPACK_IMPORTED_MODULE_0_electron__["app"].on('ready', () => {
  setApplicationMenu();
  createMainWindow();
});

/***/ }),
/* 3 */
/***/ (function(module, exports) {

module.exports = require("path");

/***/ }),
/* 4 */
/***/ (function(module, exports) {

module.exports = require("crypto");

/***/ }),
/* 5 */
/***/ (function(module, exports) {

module.exports = require("query-string");

/***/ }),
/* 6 */
/***/ (function(module, exports) {

module.exports = require("request-promise");

/***/ }),
/* 7 */
/***/ (function(module, exports) {

module.exports = {"name":"production","description":"Add here any environment specific stuff you like."}

/***/ }),
/* 8 */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0_electron__ = __webpack_require__(0);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0_electron___default = __webpack_require__.n(__WEBPACK_IMPORTED_MODULE_0_electron__);


const devMenuTemplate = {
  label: "Development",
  submenu: [{
    label: "Reload",
    accelerator: "CmdOrCtrl+R",
    click: () => {
      __WEBPACK_IMPORTED_MODULE_0_electron__["BrowserWindow"].getFocusedWindow().webContents.reloadIgnoringCache();
    }
  }, {
    label: "Toggle DevTools",
    accelerator: "Alt+CmdOrCtrl+I",
    click: () => {
      __WEBPACK_IMPORTED_MODULE_0_electron__["BrowserWindow"].getFocusedWindow().toggleDevTools();
    }
  }, {
    label: "Quit",
    accelerator: "CmdOrCtrl+Q",
    click: () => {
      __WEBPACK_IMPORTED_MODULE_0_electron__["app"].quit();
    }
  }]
};
/* harmony export (immutable) */ __webpack_exports__["a"] = devMenuTemplate;


/***/ }),
/* 9 */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
const editMenuTemplate = {
  label: "Edit",
  submenu: [{ label: "Undo", accelerator: "CmdOrCtrl+Z", selector: "undo:" }, { label: "Redo", accelerator: "Shift+CmdOrCtrl+Z", selector: "redo:" }, { type: "separator" }, { label: "Cut", accelerator: "CmdOrCtrl+X", selector: "cut:" }, { label: "Copy", accelerator: "CmdOrCtrl+C", selector: "copy:" }, { label: "Paste", accelerator: "CmdOrCtrl+V", selector: "paste:" }, { label: "Select All", accelerator: "CmdOrCtrl+A", selector: "selectAll:" }]
};
/* harmony export (immutable) */ __webpack_exports__["a"] = editMenuTemplate;


/***/ })
/******/ ]);
//# sourceMappingURL=background.js.map