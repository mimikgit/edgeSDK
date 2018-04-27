---
layout: docs
title: How to install mBeam microservice
category: microservices
order: 02
---

## Objectives

This guide covers how to install and deploy the mBeam microservice to the edgeSDK runtime. The mimik team created this microservice for mimik access to enabled a file streaming use case with the following functionality:

1. Provide a queue of links to shared media on the target device

2. Beam content from one target device to another

## Prerequisite

You will need the following software installed on your system.

- [Docker Community Edition](https://www.docker.com/community-edition#/download) for your target development platform(s)
- [https://www.npmjs.com/](NPM) v5.7.1
- [https://nodejs.org](NodeJS) v8.9.4
- edgeSDK is installed on your target development platform and and associated to your developer account

## Instructions

Clone the mBeam project from GitHub somewhere accessible on your home directory. This guide will start from the Downloads folder

```bash 
cd ~/Downloads
```

```bash 
git clone https://github.com/mimikgit/mBeam.git
```

Copy the beam microservice to your edgeSDK installation directory

```bash 
sudo cp -a mBeam/. /opt/mimik/edge/microservices/mBeam/
```

## The Repository Folders

    - src/     the raw materials for the "Hello World" beam
    - build/   the compiled javascript (after running build scripts)
    - deploy/  image file for the container

## Build beam microservice

Navigate to  the beam/microservice directory

```bash 
cd /opt/mimik/edge/microservices/mBeam
```

Install dependencies:

```bash 
npm install
```

Next run build script

```bash 
npm run-script build
```

Verify that index.js is copied under build directory

Change owner group of the build script in the deploy directory

```bash 
sudo chmod a+x deploy/build.sh
```

<!-- would it be necessary or nice to have command capture out put of e.g: ls -la | grep ... -->

Run build script to create an image for the container under deploy directory

```bash 
cd deploy/ && ./build.sh
```

Verify that beam-v1.tar mimik container image created as beam-v1.tar under deploy directory

<!-- would it be necessary or nice to have command capture out put of e.g: ls -la | grep ... -->

## Start edgeSDK

In new terminal window, change from current directory to opt/mimik/edge

```bash 
cd /opt/mimik/edge
```

Start edgeSDK

```bash 
./edge
```

## Run mBeam microservice

Navigate to the where the beam-v1.tar file

```bash 
cd /opt/mimik/edge/microservices/mBeam/deploy
```

Install the beam-v1.tar image using the following command. **Note:*-Replace 'yourAccessTokenHere' with the "access_token" object created during account association for your target platform.

```bash 
curl -i -H 'Authorization: Bearer yourAccessTokenHere' -F  "image=@beam-v1.tar" http://localhost:8083/mcm/v1/images
```

Initialize beam microservice

```bash 
curl -i -H 'Authorization: Bearer yourAccessTokenhere' -d '{"name": "beam-v1", "image": "beam-v1", "env": {"BEAM": "http://127.0.0.1:8083/beam/v1","MCM.BASE_API_PATH": "/beam/v1", "MCM.WEBSOCKET_SUPPORT": "false", "MFD": "https://mfd.mimik360.com/mFD/v1", "MPO": "https://mpo.mimik360.com/mPO/v1", "uMDS": "http://127.0.0.1:8083/mds/v1"} }' http://localhost:8083/mcm/v1/containers
```

Verify that mBeam microservice registered and works properly by calling following curl commands:

```bash 
curl -i http://localhost:8083/beam/v1/play_queue
```
The screen log shows that this method returns an empty objected called "data". View our [SwaggerHub](https://app.swaggerhub.com/apis/mimik/mBeam) definition for more information how different mBeam calls work.

## Recommended guides

- [How to install and run mDrive microservice](/docs/1.2.0/microservices/how-to-deploy-mdrive-microservice.html)
- [mimik serverless JavaScript programming API](/docs/1.2.0/resources/how-to-use-mimik-serverless-javascript-programming-api.html)