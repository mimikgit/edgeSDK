import './stylesheets/main.css';

import { greet,
  getImageState,
  getContainerState,
  addImage,
  addContainer,
  getDevices,
  sayHello } from './hello_world/hello_world';


// Function to get the list of available images and find if example.tar has been added
function getImageButtonState() {
  // Get the list of images
  getImageState((res) => {
    // Handle the call back by filtering the response to find an image with id of example
    const match = res.data.filter(item => item.id === 'example-v1');
    // If image is found we can disable the button
    document.querySelector('#add-image').disabled = match.length > 0;
  });
}

// Function to get the list of available containers and find if example-v1 has been added
function getContainerButtonState() {
  // Get teh list of containers
  getContainerState((res) => {
    // Handle the call back by filtering the response to find a container with id of example-v1
    const match = res.data.filter(item => item.id === 'example-v1');
    // If container is found we can disable the add container button
    document.querySelector('#add-container').disabled = match.length > 0;
    // If container is found we can enable the get devices button
    document.querySelector('#get-devices').disabled = match.length === 0;
  });
}

// Setting the styling for the app
document.querySelector('#app').style.display = 'block';
// Getting the content for greet
document.querySelector('#greet').innerHTML = greet();
// Calling the getImageButtonState function on startup
getImageButtonState();
// Calling the getContainerButtonState function on startup
getContainerButtonState();
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
// Setting up the onclick event for get-devices button
document.querySelector('#get-devices').onclick = () => {
  // Find devicelist
  const deviceList = document.querySelector('#devicelist');
  // clear the device list content
  deviceList.innerHTML = '...';
  // Attempt to get the list of devices
  getDevices((res) => {
    // Handle the callback
    // clear the device list content
    deviceList.innerHTML = '';
    console.log(res.data);
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
        sayHello(`${item.url}/example/v1/hello`, (result) => {
          // Handle the call back
          console.log(result.data);
          // Display the response from the API call to the given device
          document.querySelector(`#resp${index}`).innerHTML = result.data.JSONMessage;
        });
      };
      return false;
    });
  });
  return false;
};
