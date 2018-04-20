---
layout: docs
title: How to install mBeam microservice
category: microservices
order: 02
---

# Objectives

This example covers how to install and deploy the mBeam microservice to the edgeSDK runtime. The mimik team created this microservice for mimik access to enabled a file streaming use case with the following functionality:

1. Provide a queue of links to shared media on the target device

2. Beam content from one target device to another

* [Docker Community Edition][https://www.docker.com/community-edition#/download] for your target development platform(s)
- [https://www.npmjs.com/](NPM) v5.7.1
- [https://nodejs.org](NodeJS) v 8.9.4
* edgeSDK is installed and [running](https://github.com/mimikgit/edgeSDK/wiki/Installation-Guide) on your target development platform

1. Clone the mBeam project from GitHub somewhere accessible on your home directory. This guide will start from the Downloads folder

```cd ~/Downloads```

```git clone https://github.com/mimikgit/mBeam.git```

2. Navigate to following folder under example directory copy example microservice to your edgeSDK installation directory

```mkdir -p /opt/mimik/edge/microservices/mBeam/ && cp -a mBeam/. /opt/mimik/edge/microservices/mBeam/```

## The Repository Folders

    - src/     the raw materials for the "Hello World" example
    - build/   the compiled javascript (after running build scripts)
    - deploy/  image file for the container

## Build example microservice

1. Navigate to  the example/microservice directory
```cd /opt/mimik/edge/microservices/mBeam```

2. Install dependencies:

```npm install```

3. Next run build script

```npm run-script build```

4. Verify that index.js is copied under build directory

5. Change owner group of the build script in the deploy directory

``` sudo chmod a+x deploy/build.sh```

<!-- would it be necessary or nice to have command capture out put of e.g: ls -la | grep ... -->

6. Run build script to create an image for the container under deploy directory

```cd deploy/ && ./build.sh```

7. Verify that example.tar mimik container image created as example.tar under deploy directory

<!-- would it be necessary or nice to have command capture out put of e.g: ls -la | grep ... -->

## Start edgeSDK

1. In new terminal window, change from current directory to opt/mimik/edge

```cd /opt/mimik/edge```

2. Start edgeSDK

```./edge```

## Run example microservice

1. In a different terminal window copy the bearer token from /opt/mimik/edge directory (Tip: paste the output of this command as you will need it soon!)

```cat .mcmUserToken ```


2.  Navigate to the where the example-v1.tar file

```cd /opt/mimik/edge/microservices/mBeam/deploy```

3. Install the beam-v1.tar image on edgeSDK mCM container using bearer token 

```curl -i -H 'Authorization: Bearer **replaceWithYourToken**' -F "image=@beam-v1.tar" http://localhost:8083/mcm/v1/images```


4. Initialize beam microservice in edgeSDK mCM contatiner using bearer token

``` curl -i -H 'Authorization: Bearer **replaceWithYourToken**' -d '{"name": "example-v1", "image": "beam-v1", "env": {"BEAM": "http://127.0.0.1:8083/beam/v1","MCM.BASE_API_PATH": "/beam/v1", "MCM.WEBSOCKET_SUPPORT": "false", "MFD": "https://mfd-eu.mimik360.com/mFD/v1", "MPO": "https://mpo.mimik360.com/mPO/v1", "uMDS": "http://127.0.0.1:8083/mds/v1"} }' http://localhost:8083/mcm/v1/containers``` 

5. Verify that mBeam microservice registered and works properly by calling following curl commands:

```curl -i http://localhost:8083/beam/v1/play_queue```

![curl response](https://github.com/mimikgit/edgeSDK/blob/master/docs/pictures/mBeam_response_play_queue.png)

The screen log shows that this method returns an empty objected called "data". View our [SwaggerHub](https://app.swaggerhub.com/apis/mimik/mBeam) definition for more information how different mBeam calls work.
<!--  do we need to cover the different methods offered on swaggerhub? -->

## Recommended guides

* [How to install and run mDrive microservice](https://github.com/mimikgit/mDrive)
* [mimik serverless JavaScript programming API](https://github.com/mimikgit/edgeSDK/wiki/How-to-use-mimik-serverless-JavaScript-programming-API)