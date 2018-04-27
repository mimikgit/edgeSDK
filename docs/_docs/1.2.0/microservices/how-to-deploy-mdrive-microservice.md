---
layout: docs
title: How to install mDrive microservice
category: microservices
order: 03
---

## Objectives

This guide covers how to install and deploy the mDrive microservice to the edgeSDK runtime. The mimik team created this microservice for mimik access to enabled a file streaming use case with the following functionality:

1. Create a catalog of content on the edge device

2. Allow other devices to discover and stream the share content when the devices are connected to each other via account, link local WiFi, or proximity clusters.

## Prerequisites

- [Docker Community Edition](https://www.docker.com/community-edition#/download) for your target development platform(s)
- [NPM](https://www.npmjs.com/) v5.7.1
- [NodeJS](https://nodejs.org) v 8.9.4
- edgeSDK is installed on your target development platform and and associated to your developer account

Download the latest release of the mDrive microservice. This guide will start from the Downloads folder.

## Instructions

```bash 
cd ~/Downloads
```

```bash 
https://github.com/mimikgit/mDrive/releases/latest
```

Extract the package and copy the drive tar file to your edgeSDK installation directory

```bash 
sudo tar -xvzf drive-v1.tar.gz -C /opt/mimik/edge/microservices/
```

## Start edgeSDK

In new terminal window, change from current directory to opt/mimik/edge

```bash 
cd /opt/mimik/edge
```

Start edgeSDK

```bash 
./edge
```

## Run mDrive microservice

Navigate to the where the drive-v1.tar file

```bash 
cd /opt/mimik/edge/microservices/mDrive/
```

Install the drive-v1.tar image using the following command.

- **Note:** Replace 'yourAccessTokenHere' with the "access_token" object created during account association for your target platform.

```bash 
curl -i -H 'Authorization: Bearer yourAccessTokenHere' -F  "image=@drive-v1.tar" http://localhost:8083/mcm/v1/images
```

Initialize drive microservice

```bash 
curl -i -H 'Authorization: Bearer yourAccessTokenHere' -d '{"name": "drive-v1", "image": "drive-v1", "env": {"drive": "http://127.0.0.1:8083/drive/v1","MCM.BASE_API_PATH": "/drive/v1", "MCM.WEBSOCKET_SUPPORT": "false", "MFD": "https://mfd.mimik360.com/mFD/v1", "MPO": "https://mpo.mimik360.com/mPO/v1", "uMDS": "http://127.0.0.1:8083/mds/v1"} }' http://localhost:8083/mcm/v1/containers
```

Verify that mDrive microservice registered and works properly by calling following curl commands:

```bash 
curl -i http://localhost:8083/drive/v1/files
```

The screen log shows that this method returns an empty objected called "data". View our [SwaggerHub](https://app.swaggerhub.com/apis/mimik/mDrive) definition for more information how different mDrive calls work.

## Recommended guides

- [How to install and run mSuperdrive microservice](/docs/1.2.0/microservices/how-to-deploy-msuperdrive-microservice.html)
- [mimik serverless JavaScript programming API](/docs/1.2.0/resources/how-to-use-mimik-serverless-javascript-programming-api.html)