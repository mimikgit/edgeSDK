---
layout: docs
title: Account Association
type: getting-started
order: 02
---

## Objectives

Use this guide to associate your account to the edgeSDK runtime installed on your development environment or test devices. This guide provides step by step instructions on using the helper tools for this process, oauthtool and jsonrpctool.

Download one of our example apps if you want to quickly try the edgeSDK without the grueling step by step instructions.

## Prerequisites

- [Docker Community Edition](https://www.docker.com/community-edition#/download) for your target development platform(s)
- [NPM](https://www.npmjs.com/) v5.7.1
- [NodeJS](https://nodejs.org) v 8.9.4
- edgeSDK is installed on your target development platform
- [mimik Developer Account](/docs/1.2.0/getting-started/creating-a-developer-account.html)

## Instructions

Use your computer to clone or download the edgeSDK GitHub repository.


```bash
git clone https://github.com/mimikgit/edgeSDK.git
```

Next use the [OAuthflow application](https://github.com/mimikgit/edgeSDK/tools/oauthtool) to get the required EDGE_ACCESS_TOKEN and USER_ACCESS_TOKEN  ( Note: Use appID and SECRET displayed on  Developer Portal for your app )

Create your test application as a native type from mimik Developer Portal

Go to oauthtool directory

```bash
cd tools/oauthtool
```

Install dependencies

```bash
npm install
```

Set your clientID using the Application ID displayed in mimik Developer Portal for your application

```bash
export CLIENT_ID="addYourIDHere"
```

Set your REDIRECTURI using the redirect uri entered in mimik Developer Portal for your application

```bash
export REDIRECT_URI="addYourURIHere"
```

Run the app

```bash
npm start
```

<div class="alert alert-warning" role="alert">
<strong>Heads up!</strong> The oauthtool is built on top of the <a href="https://github.com/electron/electron-quick-start">Electron quick start app </a> may not start  SSH. We recommend to use this tool on device that has a display that you can physically access, like the computer you are using to SSH in with!
</div>

Click on Allow button to authorize the application

Copy and use <span id="accessToken">"access_token"</span> and "id_token" from the screen for microservice installation and account association 

Go to "jsonrpctool" directory

```bash
cd tools/jsonrpctools
```

Install packages

```bash
npm install
```

Set your edgeSDK access token as an environment variable. Copy access_token string from the oauthtool screen and paste into following command

```bash
export ACCESS_TOKEN="access_token"
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
