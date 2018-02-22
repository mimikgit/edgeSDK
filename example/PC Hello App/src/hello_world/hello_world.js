import fs from 'fs';
import { remote } from 'electron';

const { app } = remote;

const LOCAL_URL = 'http://localhost:8083';

// Gets the token from .mcmUserToken file
function getToken() {
  return 'GET The actual token from the .mcmUserToken file';
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
