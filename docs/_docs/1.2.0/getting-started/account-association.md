---
layout: docs
title: Account Association
type: getting-started
order: 02
---

## Objectives

This installation guide will cover how to install the Oauthtool application. Use this tool if you want to quickly test out the edgeSDK functionality without needing to implement any methods to associate your account with the edgeSDK runtime. *Note:* The access token generated with this tool should not be used in your production environments.

Refer to the hello_world/hello_world.js source code of [PC Example App](https://github.com/mimikgit/edgeSDK/tree/master/example/PC%20Hello%20App) for inspiration on how to implement the account association functionality in your applications.

## Prerequisites

- [Docker Community Edition](https://www.docker.com/community-edition#/download) for your target development platform(s)
- [NPM](https://www.npmjs.com/) v5.7.1
- [NodeJS](https://nodejs.org) v 8.9.4
- edgeSDK is installed and running on your target development platform
- [mimik Developer Account](/docs/1.2.0/getting-started/creating-a-developer-account.html)

## Instructions

Use your computer to clone or download the edgeSDK GitHub repository. This guide will start from the user Downloads folder


```bash
cd ~/Downloads/

git clone https://github.com/mimikgit/edgeSDK.git

cd edgeSDK/tools/oauthtool
```

Install dependencies and start the application

```bash
npm install
npm start
```

In the Client ID text field enter the Application ID for your application shown in the mimik Developer Portal and tap **Get Edge Token** 

Allow the authorization message when prompted. Keep the new Access Token somewhere you can easily reference as it is needed for the next steps.

## Start edgeSDK

In new terminal window, start the edgeSDK from the  path specified in the installation guide for your preferred development platform.

```bash
cd /opt/mimik/edge
./edge
```

## jsonRPC

Next navigate to the edgeSDK/tools/jsonrpctool directory

```bash
cd tools/jsonrpctools
```

Install packages

```bash
npm install
```

Set your edgeSDK access token as an environment variable. Copy your Access Token  from the oauthtool screen and paste into following command

```bash
export ACCESS_TOKEN="yourAccessToken"
```

Associate edgeSDK with your account

```bash
node associateAccount.js
```

Verify that edgeSDK associated with your account.

```bash
node getMe.js
```

Keep your access token somewhere safe but easy to reference for the next steps.

## Recommended guides

- [How to deploy a microservice to the edgeSDK](/docs/1.2.0/microservices/how-to-deploy-example-microservice.html)
- [How to run edgeSDK example app on Linux Ubuntu 16.04](/docs/121.0/example-apps/how-to-run-edgesdk-example-app-on-linux-ubuntu.html)
