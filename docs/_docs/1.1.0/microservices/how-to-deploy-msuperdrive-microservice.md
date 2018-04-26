---
layout: docs
title: How to install mSuperdrive microservice
category: microservices
order: 04
---

## Objectives

This guide covers how to install and deploy the mSuperdrive microservice to the edgeSDK runtime. The mimik team created this microservice for mimik access to enabled a file streaming use case with the following functionality:

1. Create a catalog of content on the edge device

2. Allow other devices to discover and stream the share content when the devices are connected to each other via account, link local WiFi, or proximity clusters.

## Prerequisites

- [Docker Community Edition](https://www.docker.com/community-edition#/download) for your target development platform(s)
- [NPM](https://www.npmjs.com/) v5.7.1
- [NodeJS](https://nodejs.org) v 8.9.4
- edgeSDK is installed on your target development platform and and associated to your developer account

## Instructions

Download the latest release of the mDrive microservice. This guide will start from the Downloads folder.

```cd ~/Downloads ```

```https://github.com/mimikgit/mSuperdrive/releases/latest```

Extract the package and copy the superdrive tar file to your edgeSDK installation directory

```sudo tar -xvzf superdrive-v1.tar.gz -C /opt/mimik/edge/microservices```

## Start edgeSDK

In new terminal window, change from current directory to opt/mimik/edge

```cd /opt/mimik/edge```

Start edgeSDK

```./edge```

## Run mSuperdrive microservice

Navigate to the where the superdrive-v1.tar file

```cd /opt/mimik/edge/microservices/mSuperdrive/```

Install the superdrive-v1.tar image using the following command.

**Note:** Replace 'yourAccessTokenHere' with the "access_token" object created during account association for your target platform.

```curl -i -H 'Authorization: Bearer yourAccessTokenHere' -F  "image=@superdrive-v1.tar" http://localhost:8083/mcm/v1/images```

Initialize superdrive microservice

```curl -i -H 'Authorization: Bearer yourAccessTokenHere' -d '{"name": "superdrive-v1", "image": "superdrive-v1", "env": {"superdrive": "http://127.0.0.1:8083/superdrive/v1","MCM.BASE_API_PATH": "/superdrive/v1", "MCM.WEBSOCKET_SUPPORT": "false", "MFD": "https://mfd.mimik360.com/mFD/v1", "MPO": "https://mpo.mimik360.com/mPO/v1", "uMDS": "http://127.0.0.1:8083/mds/v1"} }' http://localhost:8083/mcm/v1/containers```

Verify that mSuperdrive microservice registered and works properly by calling following curl commands:

```curl  -i -H 'Authorization: Bearer yourAccessTokenHere' "http://localhost:8083/superdrive/v1/drives?type=nearby&userAccessToken='useThisStringAsTokenAsStringWhenTesting'"
```

The screen log shows that this method returns an empty objected called "data". View our [SwaggerHub](https://app.swaggerhub.com/apis/mimik/mSuperdrive) definition for more information how different mSuperdrive calls work.

## Recommended guides

- [mimik serverless JavaScript programming API](/docs/1.1.0/resources/how-to-use-mimik-serverless-javascript-programming-api.html)