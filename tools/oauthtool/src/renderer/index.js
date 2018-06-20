import { ipcRenderer, } from 'electron';

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
  
ipcRenderer.on('protocol-reply', (event, arg) => {
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
  
ipcRenderer.on('oauth-login-reply', (event, arg) => {
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