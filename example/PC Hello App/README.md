# Objectives

This repository contains a example application built with Electron to help you understand how to package the edgeSDK and send commands through microservices on macOS, Linux, or Windows.

## Prerequisites

You will need the following software installed on your system.

- [https://www.npmjs.com/](NPM) v5.7.1
- [https://nodejs.org](NodeJS) v 8.9.4
- [Latest release](https://github.com/mimikgit/edgeSDK/releases/latest) of mimik edgeSDK for your target development platform
- [mimik Developer Account](https://developers.mimik360.com/dev/)

## Installation

From the command line clone the edgeSDK project from GitHub somewhere accessible on your user home directory. This guide will start from the Downloads folder

```
cd ~/Downloads
```

Switch to the folder where the example app resides.

```
git clone https://github.com/mimikgit/edgeSDK.git
```

```
cd example/PC\ Hello\ App/
```

Install the node dependencies by running the following command:


```
npm install
```
## Start edgeSDK

Refer to the platform specific guides for installing the edgeSDK service on [macOS](https://developer.mimik.com/docs/installation/macos), [Windows](https://developer.mimik.com/docs/installation/windows), or [Linux](https://developer.mimik.com/docs/installation/linux).

On macOS and Windows, the edgeSDK service is started by double clicking the package you receive from completing the installation guide.

To start the service on Linux, in a new terminal window change directory to your edgeSDK installation path

```
cd /opt/mimik/edge
```
Then edgeSDK with the following command.

```
./edge
```

## Example microservice

Follow the [example microservice](https://developer.mimik.com/docs/microservices/deploy) installation guide and verify that the container image has been created. Once verified, the PC example app is able to detect this default installation path without needing to modify the source code.

``` bash
ls ../microsrevice/deploy

example-v1.tar
```

You may also open the src/hello_world/hello_world.js file, go to line 285, and hard code the path to the folder containing the example-v1.tar file in the addImage function by assigning the path to the containersPath variable.

## Account Association

Login to [mimik Developer Portal](https://developers.mimik360.com) and create a new native app

Modify the following constants in the src/background.js file using the App ID and Redirect URI provided for your app in the mimik Developer Portal:

```javascript
const APP_ID

const REDIRECT_PROTOCOL

const REDIRECT_URI
```

Enter the following command to build the example app in a development environment:

```bash
npm start
```

To package the app for your specific OS run the following command:

```bash
npm run package
```

To test and package run the following command:

```bash
npm run release
```

The above two commands would produce one of the following installation files in the dist folder based on the OS that source is hosted on:

- For macOS: mimik Sample App--mac.dmg
- For Windows: mimik Sample App Setup .exe
- For Linux: mimik-sample-app--x86_64.AppImage

The source code is commented inline for further details.

## Summary

Below is the message sequence between example app, microservice and edgeSDK:

1. First the example app associates edgeSDK with accountID
1. Developer registers its sample app to mimik developer portal and receives the account information and account key
1. In the sample app, it uses registered account key to associate sample app with edgeSDK 
1. App verifies that edgeSDK associated with the correct account info.

After  the following message flow is used to retrieve account cluster nodes:

1. Sample app first calls account service from example microservice to retrieve account cluster nodes from the BES using the authorization key of associated account
1. mPO requests the nodes information  including BEP references of account cluster nodes.
1. mDS gets the account key and returns cluster nodes information.
1. mPO returns nodes and profile information of cluster account
1. example microservices also calls nearby service from edgeSDK to get linked local nodes,
1. if available, example microservice uses the local addresses of account cluster nodes to communicate with them
1. example microservice return account cluster nodes ( BEP or local address)  and then sample example displays info on the app screen.
1. User selects one of the nodes and then sample app calls hello method with select node's' url to get a message from this node.
1. Show the hello world response

## Recommended guides

- [mimik serverless JavaScript programming API](https://developer.mimik.com/docs/api-guides/apis)
