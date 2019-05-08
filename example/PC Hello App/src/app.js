
import { ipcRenderer } from 'electron';
import './stylesheets/main.css';

import {
  greet,
  getImageState,
  getContainerState,
  accountAssociation,
  getMe,
  undoAccountAssociation,
  addImage,
  addContainer,
  getNetworkDevices,
  getNearbyDevices,
  sayHello,
  findNodeAndSayHello,
} from './hello_world/hello_world';
import { appId } from './helpers/constants';


function showMessage(msg) {
  document.querySelector('.message').style.display = 'flex';
  document.querySelector('.message').innerHTML = msg;
  setTimeout(() => {
    document.querySelector('.message').style.display = 'none';
    document.querySelector('.message').innerHTML = '';
  }, 3500);
}

// Function to get the list of available images and find if example.tar has been added
function getImageButtonState() {
  // Get the list of images
  getImageState((res) => {
    // Handle the call back by filtering the response to find an image with id of example
    const match = res.data.filter(item => item.id === `${appId}-example-v1`);
    // If image is found we can disable the button
    document.querySelector('#add-image').disabled = match.length > 0;
  });
}

// Function to get the list of available containers and find if example-v1 has been added
function getContainerButtonState() {
  // Get the list of containers
  getContainerState((res) => {
    // Handle the call back by filtering the response to find a container with id of example-v1
    const match = res.filter(item => item.id === `${appId}-example-v1`);
    // If container is found we can disable the add container button
    document.querySelector('#add-container').disabled = match.length > 0;
    // If container is found we can enable the get devices buttons
    document.querySelector('#get-network-devices').disabled = match.length === 0;
    document.querySelector('#get-nearby-devices').disabled = match.length === 0;
  });
}

function getAssociationState() {
  getMe((data) => {
    // console.log(`getMe: ${JSON.stringify(data)}`);
    if (data && data.data && data.data.accountId) {
      document.querySelector('#associate').disabled = true;
      document.querySelector('#unassociate').disabled = false;
      // Calling the getImageButtonState
      getImageButtonState();
      // Calling the getContainerButtonState
      getContainerButtonState();
    } else {
      document.querySelector('#associate').disabled = false;
      document.querySelector('#unassociate').disabled = true;
      document.querySelector('#add-image').disabled = true;
      document.querySelector('#add-container').disabled = true;
      document.querySelector('#get-network-devices').disabled = true;
      document.querySelector('#get-nearby-devices').disabled = true;
    }
  });
}

// Setting the styling for the app
document.querySelector('#app').style.display = 'block';
// Getting the content for greet
document.querySelector('#greet').innerHTML = greet();

document.querySelector('#login').onclick = () => {
  ipcRenderer.send('oauth-login', 'login');
  return false;
};

ipcRenderer.on('oauth-login-reply', (event, arg) => {
  // console.log('oauth-login-reply', arg);
  if (arg.status === true) {
    document.querySelector('#login').disabled = true;
    if (arg.data) {
      sessionStorage.setItem('token', JSON.stringify(arg.data));
      getAssociationState();
    }
  } else {
    showMessage(arg.message);
  }
});

// Setting up the onclick event for associate button
document.querySelector('#associate').onclick = () => {
  // Calling accountAssociation function in the hello_world.js
  accountAssociation(() => {
    // console.log(`accountAssociation: ${JSON.stringify(data)}`);
    // Check the state again after the callback
    getAssociationState();
    return false;
  });
  return false;
};

// Setting up the onclick event for unassociate button
document.querySelector('#unassociate').onclick = () => {
  ipcRenderer.send('oauth-unassociate', 'unassociate');
  return false;
};

ipcRenderer.on('oauth-unassociate-reply', (event, arg) => {
  // console.log('oauth-unassociate-reply', arg);
  if (arg.status === true) {
    // document.querySelector('#login').disabled = true;
    if (arg.data) {
      sessionStorage.setItem('token', JSON.stringify(arg.data));
    }
    // Calling accountAssociation function in the hello_world.js
    undoAccountAssociation(() => {
      // console.log(`undoAccountAssociation: ${JSON.stringify(data)}`);
      document.querySelector('#devicelist').innerHTML = '';
      document.querySelector('#login').disabled = false;
      document.querySelector('#associate').disabled = true;
      document.querySelector('#unassociate').disabled = true;
      document.querySelector('#get-network-devices').disabled = true;
      document.querySelector('#get-nearby-devices').disabled = true;
      sessionStorage.removeItem('token');
    });
  } else {
    showMessage(arg.message);
  }
});

// Setting up the onclick event for add-image button
document.querySelector('#add-image').onclick = () => {
  // Calling addImage function in the hello_world.js
  addImage(() => {
    // Check the state again after the callback
    getImageButtonState();
    return false;
  });
  return false;
};
// Setting up the onclick event for add-container button
document.querySelector('#add-container').onclick = () => {
  // Calling addContainer function in the hello_world.js
  addContainer(() => {
    // Check the state again after the callback
    getContainerButtonState();
    return false;
  });
  return false;
};
// Setting up the onclick event for get-network-devices button
document.querySelector('#get-network-devices').onclick = () => {
  // Find devicelist
  const deviceList = document.querySelector('#devicelist');
  // clear the device list content
  deviceList.innerHTML = '...';
  // Attempt to get the list of devices
  getNetworkDevices((res) => {
    // Handle the callback
    // clear the device list content
    deviceList.innerHTML = '';
    // console.log(res.data);
    // Use map to iterate each device in the list
    res.data.map((item, index) => {
      // Create a new div element
      const newDiv = document.createElement('div');
      // Create a new text node with the device name
      const deviceName = document.createTextNode(item.name);
      // Create a new button
      const btn = document.createElement('BUTTON');
      // Create a label for the button
      const label = document.createTextNode('Say hello!');
      // Set an id attribute corresponding to the device id
      btn.setAttribute('id', `btn${index}`);
      // Append the label to the button
      btn.appendChild(label);
      // Create a div element to display the response from the other device
      const deviceResponse = document.createElement('div');
      // Set an id attribute corresponding to the device id prepended with "resp"
      // to avoid duplication
      deviceResponse.setAttribute('id', `resp${index}`);
      // Append deviceName text node to the newDiv
      newDiv.appendChild(deviceName);
      // Append the button to the newDiv
      newDiv.appendChild(btn);
      // Append the response div to the newDiv
      newDiv.appendChild(deviceResponse);
      // Append the newDiv to the device list
      deviceList.appendChild(newDiv);
      // Create an on click event handler for the button that was just created
      document.querySelector(`#btn${index}`).onclick = () => {
        // Call the hello API on the given device
        sayHello(`${item.url}/${appId}/example/v1/hello`, (result) => {
          // Handle the call back
          // console.log(result);
          // Display the response from the API call to the given device
          document.querySelector(`#resp${index}`).innerHTML = result.JSONMessage;
        });
      };
      return false;
    });
  });
  return false;
};

// Setting up the onclick event for get-nearby-devices button
document.querySelector('#get-nearby-devices').onclick = () => {
  // Find devicelist
  const deviceList = document.querySelector('#devicelist');
  // clear the device list content
  deviceList.innerHTML = '...';
  // Attempt to get the list of devices
  getNearbyDevices((res) => {
    // Handle the callback
    // clear the device list content
    deviceList.innerHTML = '';
    // console.log(res.data);
    // Use map to iterate each device in the list
    res.data.map((item, index) => {
      // Create a new div element
      const newDiv = document.createElement('div');
      // Create a new text node with the device name
      const deviceName = document.createTextNode(item.name);
      // Create a new button
      const btn = document.createElement('BUTTON');
      // Create a label for the button
      const label = document.createTextNode('Say hello!');
      // Set an id attribute corresponding to the device id
      btn.setAttribute('id', `btn${index}`);
      // Append the label to the button
      btn.appendChild(label);
      // Create a div element to display the response from the other device
      const deviceResponse = document.createElement('div');
      // Set an id attribute corresponding to the device id prepended with "resp"
      // to avoid duplication
      deviceResponse.setAttribute('id', `resp${index}`);
      // Append deviceName text node to the newDiv
      newDiv.appendChild(deviceName);
      // Append the button to the newDiv
      newDiv.appendChild(btn);
      // Append the response div to the newDiv
      newDiv.appendChild(deviceResponse);
      // Append the newDiv to the device list
      deviceList.appendChild(newDiv);
      // Create an on click event handler for the button that was just created
      document.querySelector(`#btn${index}`).onclick = () => {
        // Call the findNode And SayHello APIs on the given device
        findNodeAndSayHello(item.id, (result) => {
          // Handle the call back
          // console.log(result);
          // Handle styling for response
          if (result && result.error) {
            document.querySelector(`#resp${index}`).style.color = '#900';
          } else {
            document.querySelector(`#resp${index}`).style.color = '#000';
          }
          // Display the response from the API call to the given device
          document.querySelector(`#resp${index}`).innerHTML = result.JSONMessage;
        });
      };
      return false;
    });
  });
  return false;
};
