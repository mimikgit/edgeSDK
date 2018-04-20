---
layout: docs
title: How to run edgeSDK on Ubuntu
type: edgeSDK
order: 04
---

# Objectives

These instructions will walk you through getting the edgeSDK running on Ubuntu Linux 16.04 LTS.

## Hardware Requirements

This guide assumes that:

- You are running Ubuntu Linux 16.04 LTS
- You have internet connectivity
- You have root permissions

## Pre-requisite

You will need the following software installed on your system.

- [Docker Community Edition](https://www.docker.com/community-edition#/download) for your target development platform(s)
- [https://www.npmjs.com/](NPM) v5.7.1
- [https://nodejs.org](NodeJS) v 8.9.4

## Download license

A license file is required to create your mimik user token used to authenticate your account through out the system.

- Create account at [https://mimikgit.github.io/devportal/](https://mimikgit.github.io/devportal/) to receive edgeSDK license file
- Open your email inbox and follow instructions inside the message from mimik to confirm your account
- Copy the license file from an invitation email to the download folder of your platform
- Download the [latest](https://github.com/mimikgit/edgeSDK/releases/latest)  version of edgeSDK for linux

## Instructions

1. From a terminal window navigate to the root directory of your development environment (we assume a new terminal window start from your user home directory

```cd /```

2. Create opt/mimik/edge directory structure

```sudo mkdir -p /opt/mimik/edge```

3. Change directory permissions of the directory created in the last step and verify change is applied.

```sudo chmod a+w -R /opt/mimik/edge | ls -ld /opt/mimik/edge```

4. Unzip then copy mimik edge package and license in the opt/mimik/edge and verify (note: we assume that the edge package is located in your user home directory)

```cd ~/Downloads && unzip edge_linux.zip && cp mimikEdge.lic edge /opt/mimik/edge/  && ls -la /opt/mimik/edge```

- NOTE: must have [licence file](#create-license) before doing this step

5. Change from current directory to opt/mimik/edge

```cd /opt/mimik/edge/```

6. Add executre permission to the edge file

``` sudo chmod a+x ./edge | ls -ls ./edge ```

7. Start edgeSDK

```./edge```

8. When the edgeSDK starts on this machine, a series of screen output show the status the status of this particular node. For instance the following message shows that the current machine is acting as a regular node

![](https://github.com/mimikgit/edgeSDK/blob/master/docs/pictures/edgeSDk%20Success%20Start.jpg)

Or the following message shows that a "Super-node" has been found in the cluster:

![](https://github.com/mimikgit/edgeSDK/blob/master/docs/pictures/super_node_edgeSDK%20success.png)

9. You can also use the curl command as below in a new terminal and be able to see the  screen log show below:

```curl -i http://localhost:8083/mds/v1/nodes```

![](https://github.com/mimikgit/edgeSDK/blob/master/docs/pictures/curl_response_install_edgeSDK_encrypted.png)

In the first couple of lines of the log, you see the access method e.g. Get, Post, Delete etc. As you see this log is a JSON file that shows the encrypted information about the current node.

## Recommended guides

- [How to install and run example microservice](docs/1.1.0/microservices/How-to-deploy-Example-Microservice)
- [How to run edgeSDK example app on Linux Ubuntu 16.04](docs/1.1.0/example-apps/How-to-run-edgeSDK-example-app-on-Linux-Ubuntu)