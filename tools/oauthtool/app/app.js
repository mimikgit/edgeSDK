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
/******/ 	return __webpack_require__(__webpack_require__.s = 10);
/******/ })
/************************************************************************/
/******/ ({

/***/ 0:
/***/ (function(module, exports) {

module.exports = require("electron");

/***/ }),

/***/ 10:
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
Object.defineProperty(__webpack_exports__, "__esModule", { value: true });
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0_electron__ = __webpack_require__(0);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0_electron___default = __webpack_require__.n(__WEBPACK_IMPORTED_MODULE_0_electron__);


const app = document.querySelector('#app');

function showMessage(msg) {
    document.querySelector('.message').style.display = 'flex';
    document.querySelector('.message').innerText = msg;
}

function init() {
    app.style.display = 'block';
}

init();

document.querySelector('#btnRedirect').onclick = () => {
    const clientId = document.querySelector('#clientId');
    const redirectUri = document.querySelector('#redirectUri');
    console.log(`${clientId.value} ### ${redirectUri.value}`);

    const url = "openid://callback?protocol=true&client_id=" + clientId.value + "&redirect_uri=" + redirectUri.value;
    window.location.assign(url);
};

document.querySelector('#btnEdgeToken').onclick = () => {
    const clientId = document.querySelector('#clientId');
    const redirectUri = document.querySelector('#redirectUri');
    console.log(`${clientId.value} ### ${redirectUri.value}`);

    const url = "openid://callback?client_id=" + clientId.value + "&redirect_uri=" + redirectUri.value;
    window.location.assign(url);
};

document.querySelector('#btnResetEdgeToken').onclick = () => {
    const clientId = document.querySelector('#clientId');
    const redirectUri = document.querySelector('#redirectUri');
    console.log(`${clientId.value} ### ${redirectUri.value}`);

    const url = "openid://callback?reset=true&client_id=" + clientId.value + "&redirect_uri=" + redirectUri.value;
    window.location.assign(url);
};

__WEBPACK_IMPORTED_MODULE_0_electron__["ipcRenderer"].on('protocol-reply', (event, arg) => {
    console.log('protocol-reply', arg);
    showMessage('');
    if (arg.status === true) {
        if (arg.data) {
            document.querySelector('#btnRedirect').disabled = true;
            document.querySelector('#btnEdgeToken').disabled = false;
            document.querySelector('#btnResetEdgeToken').disabled = false;
        }
    } else {
        const msg = `${arg.message.error} - ${arg.message.error_description}`;
        showMessage(msg);
    }
});

__WEBPACK_IMPORTED_MODULE_0_electron__["ipcRenderer"].on('oauth-login-reply', (event, arg) => {
    console.log('oauth-login-reply', arg);
    document.querySelector('#btnRedirect').disabled = true;
    document.querySelector('#btnEdgeToken').disabled = false;
    document.querySelector('#btnResetEdgeToken').disabled = false;
    showMessage('');
    if (arg.devClientId) {
        document.querySelector('#clientId').value = arg.devClientId;
    }
    if (arg.devRidirectUri) {
        document.querySelector('#redirectUri').value = arg.devRidirectUri;
    }
    if (arg.status === true) {
        if (arg.token) {
            console.log(`Token: ${JSON.stringify(arg.token)}`);
            const accessToken = document.querySelector('#accessToken');
            accessToken.innerText = JSON.stringify(arg.token);
        }
    } else {
        const msg = `${arg.message.error} - ${arg.message.error_description}`;
        showMessage(msg);
    }
});

/***/ })

/******/ });
//# sourceMappingURL=app.js.map