---
layout: docs
title: How to install example microservice
type: microservices
type: microservices
order: 01
---

## Objectives

This guide contains simple "Hello World" microservice to help you understand how to deploy a microservice to the edgeSDK runtime and call methods to discover nodes in a link local and account clusters.

## Prerequisite

You will need the following software installed on your system.

- [Docker Community Edition](https://www.docker.com/community-edition#/download) for your target development platform(s)
- [NPM](https://www.npmjs.com/) v5.7.1
- [NodeJS](https://nodejs.org) v 8.9.4
- edgeSDK is installed on your target development platform and and associated to your developer account

## Instructions

Clone the edgeSDK project from GitHub somewhere accessible on your home directory. This guide will start from the Downloads folder

```cd ~/Downloads```

```git clone https://github.com/mimikgit/edgeSDK.git```

Copy the example microservice to your edgeSDK installation directory

```sudo mkdir /opt/mimik/edge/microservices/ && sudo mkdir /opt/mimik/edge/microservices/example```

```sudo cp -a edgeSDK/example/microservice/. /opt/mimik/edge/microservices/example```

## The Repository Folders

    - src/     the raw materials for the "Hello World" example
    - build/   the compiled javascript (after running build scripts)
    - deploy/  image file for the container

## Build example microservice

Navigate to the example/microservice directory

```cd /opt/mimik/edge/microservices/example```

Install dependencies:

```npm install```

Next run build script

```npm run-script build```

Verify that index.js is copied under build directory

<!-- would it be necessary or nice to have command capture out put of e.g: ls -la | grep ... -->

Add execute permission to the build script found in the deploy directory

``` sudo chmod a+x deploy/build.sh```

<!-- would it be necessary or nice to have command capture out put of e.g: ls -la | grep ... -->

Run build script to create an image for the container under deploy directory

```cd deploy/ && ./build.sh```

Verify that example-v1.tar mimik container image created as example.tar in the current directory

<!-- would it be necessary or nice to have command capture out put of e.g: ls -la | grep ... -->

## Start edgeSDK

In new terminal window, change from current directory to opt/mimik/edge

```cd /opt/mimik/edge```

Start edgeSDK

```./edge```

## Initialize example microservice

Navigate to the where the example-v1.tar was created

```cd /opt/mimik/edge/microservices/example/deploy```

Install the example-v1.tar image using the following command. **Note:*-Replace 'yourAccessTokenHere' with the "access_token" object created during account association for your target platform.

```curl -i -H 'Authorization: Bearer yourAccessTokenHere' -F "image=@example-v1.tar" http://localhost:8083/mcm/v1/images```

Initialize example microservice

```curl -i -H 'Authorization: Bearer yourAccessTokenHere' -d '{"name": "example-v1", "image": "example-v1", "env": {"BEAM": "http://127.0.0.1:8083/beam/v1","MCM.BASE_API_PATH": "/example/v1", "MCM.WEBSOCKET_SUPPORT": "false", "MFD": "https://mfd.mimik360.com/mFD/v1", "MPO": "https://mpo.mimik360.com/mPO/v1", "uMDS": "http://127.0.0.1:8083/mds/v1"} }' http://localhost:8083/mcm/v1/containers```

## Discover nodes in link local cluster

Call Hello and nearby endpoints from microservice

![hello and nearby response](/assets/images/documentation/sample_app_message_sequence.png)


```curl -i -H 'Authorization: Bearer yourAccessTokenHere' http://localhost:8083/example/v1/drives?type=nearby```

```curl -i -H 'Authorization: Bearer yourAccessTokenHere' http://(nearby device IP in linkedLocalNetwork):8083/example/v1/hello ```


## Discover nodes in account cluster

Sample app uses example microservice to find account cluster nodes and then call "Hello World" methods provided by these nodes. The content of "Hello World" JSON object could be changed based on the presentation that we will have on app.

Call Hello and get account cluster nodes from microservice

```curl -i -H 'Authorization: Bearer yourAccessTokenHere' http://localhost:8083/example/v1/drives?type=account```

## Recommended guides

- [How to run edgeSDK example app on Linux Ubuntu 16.04](/docs/1.2.0/example-apps/how-to-run-edgesdk-example-app-on-Linux-Ubuntu.html)
- [How to install and run mBeam microservice](/docs/1.2.0/microservices/how-to-deploy-mbeam-microservice.html)
- [mimik serverless JavaScript programming API](/docs/1.2.0/resources/how-to-use-mimik-serverless-javascript-programming-api.html)