# mimik sample app

## Prerequisites

* Nodejs (tested with version 8.9.4)
* mimik Edge with container management

## Getting started

from the command line switch to the folder where the sample app resides. Install the node dependencies by running the following command:
```
npm install
```
Once that is completed make sure that mimik Edge is running.

Now you would have to make one or two changes to the code before continuing.

Get the container management token from .mcmUserToken file and place it in the getToken function of the hello_world.js file.

You also need the location of the example-v1.tar container image. If you install this sample locally from the package you create, the code will ascertain the correct location.

You can also hard code the path to the folder containing the  example-v1.tar file in the addImage function by assigning the path to the containersPath

To run the code in a development environment use the following command:
```
npm start
```
To package the app for your specific OS run the following command:
```
npm package
```
Or to test and package run the following command:
```
npm release
```
The above two commands would produce one of the following installation files in the dist folder based on the OS that source is hosted on:

* For macOS: mimik Sample App-1.0.0-mac.dmg
* For Windows: mimik Sample App Setup 1.0.0.exe
* For Linux: mimik-sample-app-1.0.0-x86_64.AppImage

The source code is commented inline for further details.