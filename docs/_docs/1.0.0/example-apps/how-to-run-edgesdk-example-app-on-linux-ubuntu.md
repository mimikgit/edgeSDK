---
layout: docs
title: How to run edgeSDK example app on Ubuntu
type: example apps
order: 04
---

# Objectives

These instructions contain a example application for Linux environments to help you understand how to package the edgeSDK and send commands through microservices.

Here you can see the message sequence between app, microservice and edgeSDK:

![message sequence](https://github.com/mimikgit/edgeSDK/blob/master/docs/pictures/sample_app_message_sequence.png)

1. Sample app first calls nearby service from example microservice to retrieve linked local nodes from the edge and displays them on the app screen.
2. User selects one of the nodes and then sample app calls hello method with select node's' url to get a message from this node.
3. Display message on screen to the user.

## Pre-requisite

You will need the following software installed on your system.

- [https://www.npmjs.com/](NPM) v5.7.1
- [https://nodejs.org](NodeJS) v 8.9.4
- [Latest release](https://github.com/mimikgit/edgeSDK/releases/latest) of mimik edgeSDK for your target development platform

## Installation

1. From the command line clone the edgeSDK project from GitHub somewhere accessible on your user home directory. This guide will start from the Downloads folder

```cd ~/Downloads```

2. Switch to the folder where the example app resides.

```git clone https://github.com/mimikgit/edgeSDK.git```

```cd example/PC\ Hello\ App/```


3. Install the node dependencies by running the following command:

```npm install```

## Start edgeSDK

4. In new terminal window change from current directory to opt/mimik/edge

```cd /opt/mimik/edge```

5. Start edgeSDK

```./edge```

6. In a different terminal window get the container management token in the /opt/mimik/edge directory from .mcmUserToken file

```cat /opt/mimik/edge/.mcmUserToken```

7. Place it in the getToken function of the src/hello_world/hello_world.js file.

8. You also need the location of the example-v1.tar container image. If you install this example locally from the package you create, the code will ascertain the correct location.

9. You can also hard code the path to the folder containing the  example-v1.tar file in the addImage function by assigning the path to the containersPath

10. To run the code in a development environment use the following command:

```npm start```

11. To package the app for your specific OS run the following command:

```npm pack```

12. to test and package run the following command:
```npm release```

The above two commands would produce one of the following installation files in the dist folder based on the OS that source is hosted on:

* For macOS: mimik Sample App-1.0.0-mac.dmg
* For Windows: mimik Sample App Setup 1.0.0.exe
* For Linux: mimik-sample-app-1.0.0-x86_64.AppImage

The source code is commented inline for further details.

## Recommended guides

* [mimik serverless JavaScript programming API](https://github.com/mimikgit/edgeSDK/wiki/How-to-use-mimik-serverless-JavaScript-programming-API)