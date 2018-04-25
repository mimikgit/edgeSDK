# Objectives

This repository contains a example application built with Electron to help you understand how to package the edgeSDK and send commands through microservices on macOS, Linux, or Windows.

## Prerequisites

You will need the following software installed on your system.

- [https://www.npmjs.com/](NPM) v5.7.1
- [https://nodejs.org](NodeJS) v 8.9.4
- [Latest release](https://github.com/mimikgit/edgeSDK/releases/latest) of mimik edgeSDK for your target development platform
- [mimik Developer Account](http://developers-dev.mimikdev.com/dev/)

## Installation

From the command line clone the edgeSDK project from GitHub somewhere accessible on your user home directory. This guide will start from the Downloads folder

```cd ~/Downloads```

Switch to the folder where the example app resides.

```git clone https://github.com/mimikgit/edgeSDK.git```

```cd example/PC\ Hello\ App/```

Install the node dependencies by running the following command:

```npm install```

## Start edgeSDK

Refer to the platform specific guides for installing the edgeSDK service on [macOS](https://developers.mimik.com/docs/1.2.0/installation/macos.html), [Windows](https://developers.mimik.com/docs/1.2.0/installation/windows.html), or [Linux](https://developers.mimik.com/docs/1.2.0/installation/linux-ubuntu.html).

On macOS and Windows, the edgeSDK service is started by double clicking the package you receive from completing the installation guide.

To start the service on Linux, in a new terminal window change directory to your edgeSDK installation path

```cd /opt/mimik/edge```

Then edgeSDK with the following command.

```./edge```

## Example microservice

You also need the location of the [example-v1.tar](/docs/1.2.0/microservices/how-to-deploy-example-microservice.html) container image.

If you cloned the [edgeSDK GitHub](https://github.com/mimikgit/edgeSDK) repo, you can use the "npm run package" command and the code will ascertain the correct location.

Otherwise open the src/hello_world/hello_world.js file, go to line 285, and hard code the path to the folder containing the example-v1.tar file in the addImage function by assigning the path to the containersPath variable.

## Account Association

Login to [mimik Developer Portal](http://developers-dev.mimikdev.com/dev) and create a new native app

Modify the following constants in the src/background.js file using the App ID and Redirect URI provided for your app in the mimik Developer Portal:

```const APP_ID```

```const REDIRECT_PROTOCOL```

```const REDIRECT_URI```


Enter the following command to build the example app in a development environment:

```npm start```

To package the app for your specific OS run the following command:

```npm run package```

To test and package run the following command:

```npm run release```

The above two commands would produce one of the following installation files in the dist folder based on the OS that source is hosted on:

- For macOS: mimik Sample App--mac.dmg
- For Windows: mimik Sample App Setup .exe
- For Linux: mimik-sample-app--x86_64.AppImage

The source code is commented inline for further details.

## Summary

Below is the message sequence between example app, microservice and edgeSDK:

![app registration](/assets/images/documentation/Hello App registration.png)

1. First the example app associates edgeSDK with accountID
1. Developer registers its sample app to mimik developer portal and receives the account information and account key
1. In the sample app, it uses registered account key to associate sample app with edgeSDK 
1. App verifies that edgeSDK associated with the correct account info.

After  the following message flow is used to retrieve account cluster nodes:

![account cluster](/assets/images/documentation/example microservice account cluster.png)

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

- [mimik serverless JavaScript programming API](https://developers.mimik.com/docs/1.2.0/resources/how-to-use-mimik-serverless-javascript-programming-api.html)