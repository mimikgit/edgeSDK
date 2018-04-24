---
layout: docs
title: How to install example microservice
type: microservices
type: microservices
order: 01
---

# Objectives

This example contains simple "Hello World" microservice to help you understand how to deploy a microservice to the edgeSDK runtime.

## Pre-requisite

You will need the following software installed on your system.

- [Docker Community Edition](https://www.docker.com/community-edition#/download) for your target development platform(s)
- [https://www.npmjs.com/](NPM) v5.7.1
- [https://nodejs.org](NodeJS) v 8.9.4
- edgeSDK is installed and [running](https://github.com/mimikgit/edgeSDK/wiki/Installation-Guide) on your target development platform

1. Clone the edgeSDK project from GitHub somewhere accessible on your home directory. This guide will start from the Downloads folder

```cd ~/Downloads```

```git clone https://github.com/mimikgit/edgeSDK.git```

2. Navigate to following folder under example directory and copy the example microservice to your edgeSDK installation directory

```sudo mkdir -p /opt/mimik/edge/microservices/example mBeam && cp -a edgeSDK/example/microservice/. /opt/mimik/edge/microservices/example```

## The Repository Folders

    - src/     the raw materials for the "Hello World" example
    - build/   the compiled javascript (after running build scripts)
    - deploy/  image file for the container

## Build example microservice

1. Navigate to the example/microservice directory

```cd /opt/mimik/edge/microservices/example```

2. Install dependencies:

```npm install```

3. Next run build script

```npm run-script build```

4. Verify that index.js is copied under build directory

<!-- would it be necessary or nice to have command capture out put of e.g: ls -la | grep ... -->

5. Add execute permission to the build script found in the deploy directory

``` sudo chmod a+x deploy/build.sh```

<!-- would it be necessary or nice to have command capture out put of e.g: ls -la | grep ... -->

6. Run build script to create an image for the container under deploy directory

```cd deploy/ && ./build.sh```

7. Verify that example.tar mimik container image created as example.tar in the current directory

<!-- would it be necessary or nice to have command capture out put of e.g: ls -la | grep ... -->

## Start edgeSDK

1. In new terminal window, change from current directory to opt/mimik/edge

```cd /opt/mimik/edge```

2. Start edgeSDK

```./edge```

## Run example microservice

1. In a different terminal window copy the bearer token (Tip: Paste the output of this command somewhere you can easily access as you will need it soon!)

```cat /opt/mimik/edge/.mcmUserToken```

2.  Navigate to the where the example-v1.tar was created

```cd /opt/mimik/edge/microservices/example/deploy```

3. Install the example.tar image on edgeSDK mCM container using bearer token

```curl -i -H 'Authorization: Bearer **replaceWithYourToken**' -F "image=@example-v1.tar" http://localhost:8083/mcm/v1/images```


4. Initialize the example microservice in edgeSDK mCM container

``` curl -i -H 'Authorization: Bearer **replaceWithYourToken**' -d '{"name": "example-v1", "image": "example-v1", "env": {"BEAM": "http://127.0.0.1:8083/beam/v1","MCM.BASE_API_PATH": "/example/v1", "MCM.WEBSOCKET_SUPPORT": "false", "MFD": "https://mfd-eu.mimik360.com/mFD/v1", "MPO": "https://mpo.mimik360.com/mPO/v1", "uMDS": "http://127.0.0.1:8083/mds/v1"} }' http://localhost:8083/mcm/v1/containers``` 

5. Verify that "Hello World" example microservice registered and works properly by calling following curl commands:

```curl -i http://localhost:8083/example/v1/hello```

![curl response](https://github.com/mimikgit/edgeSDK/blob/master/docs/pictures/curl_response_install_edgeSDK_encrypted.png)

## Recommended guides

- [How to run edgeSDK example app on Linux Ubuntu 16.04](https://github.com/mimikgit/edgeSDK/wiki/How-to-run-edgeSDK-example-app-on-Linux-Ubuntu)
- [How to install and run mBeam microservice](https://github.com/mimikgit/mBeam)
- [mimik serverless JavaScript programming API](https://github.com/mimikgit/edgeSDK/wiki/How-to-use-mimik-serverless-JavaScript-programming-API)