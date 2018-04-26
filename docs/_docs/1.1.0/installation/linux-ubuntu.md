---
layout: docs
title: How to install edgeSDK on Ubuntu
type: installation
order: 04
---

## Objectives

These instructions will walk you through how to run the edgeSDK on Linux Ubuntu 16.04 LTS.

## Hardware Requirements

This guide assumes that:

- You are running Linux Ubuntu 16.04 LTS
- You have internet connectivity
- You have root permissions

## Prerequisite

You will need the following software installed on your system.

- [Docker Community Edition](https://www.docker.com/community-edition#/download) for your target development platform(s)
- [NPM](https://www.npmjs.com/) v5.7.1
- [NodeJS](https://nodejs.org) v 8.9.4

## Instructions

Open a new terminal window. This guide will start from the user Downloads directory

```cd ~/Downloads```

Next clone the edgeSDK GitHub repository

```git clone https://github.com/mimikgit/edgeSDK.git```

Download the latest Linux package from the edgeSDK release page into the Downloads directory

```https://github.com/mimikgit/edgeSDK/releases/latest```

<!-- todo - oneliner with curl, wget to download from api.github.com/repo* -->

Create opt/mimik/edge directory structure

```sudo mkdir -p /opt/mimik/edge```

Change directory permissions of the directory created in the last step and verify change is applied

```sudo chmod a+w -R /opt/mimik/edge | ls -ld /opt/mimik/edge```

Unzip then copy mimik edge package to the directory created in the last step

```unzip ~/Downloads/edge_linux.zip -d ~/Downloads/edge_linux && sudo cp -a ~/Downloads/edge_linux/. /opt/mimik/edge/  && ls -la /opt/mimik/edge```

Next copy the edgeSDK license configuration to the edgeSDK installation directory

```sudo cp -a ~/Downloads/edgeSDK/tools/mimikEdge.lic /opt/mimik/edge/ ```

Change from current directory to opt/mimik/edge

```cd /opt/mimik/edge/```

Add execute permission to the edge file

```sudo chmod a+x ./edge | ls -ls ./edge```

Start edgeSDK

```./edge```

When the edgeSDK starts on this machine, a series of screen output show the status the status of this particular node. For instance the following message shows that the current machine is acting as a regular node

![](/assets/images/documentation/edgeSDk%20Success%20Start.jpg)

Or the following message shows that a "Super-node" has been found in the cluster:

![](/assets/images/documentation/super_node_edgeSDK%20success.png)

You can also use the curl command as below in a new terminal and be able to see the  screen log show below:

```curl -i http://localhost:8083/mds/v1/nodes```

![](/assets/images/documentation/curl_response_install_edgeSDK_encrypted.png)

In the first couple of lines of the log, you see the access method e.g. Get, Post, Delete etc. As you see this log is a JSON file that shows the encrypted information about the current node.

## Account association

Use the [account association](/docs/1.1.0/getting-started/account-association.html) guide link your Developer Account to your edgeSDK allowing you to discover and make calls to devices belonging to the account cluster 

Download the example application  [PC example app](https://github.com/mimikgit/edgeSDK/example/PC%20Hello%20App) and use the [documentation](/docs/1.1.0/example-apps/how-to-run-edgesdk-example-app-on-linux-ubuntu.html)  for a quick end to end demo of this process.

## Recommended guides

- [How to deploy a microservice to the edgeSDK](/docs/1.1.0/microservices/how-to-deploy-example-microservice.html)
- [How to run edgeSDK example app on Linux Ubuntu 16.04](/docs/1.1.0/example-apps/how-to-run-edgesdk-example-app-on-linux-ubuntu.html)