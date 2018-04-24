---
layout: docs
title: How to run edgeSDK on Windows
type: edgeSDK
order: 07
---

# Objectives

These instructions will walk you through getting the edgeSDK running on Windows 10.

## Hardware Requirements

This guide assumes that:

- you are running Windows 10 computer or laptop
- you have a wired or wireless internet connection

## Pre-requisite

- [https://www.npmjs.com/](NPM) v5.7.1
- [https://nodejs.org](NodeJS) v 8.9.4

## Download license

A license file is required to create your mimik user token used to authenticate your account through out the system.

- Create account at [https://mimikgit.github.io/devportal/](https://mimikgit.github.io/devportal/) to receive edgeSDK license file
- Open your email inbox and follow instructions inside the message from mimik to confirm your account
- Copy the license file from an invitation email to the download folder of your platform
- Download the [latest](https://github.com/mimikgit/edgeSDK/releases/latest)  version of edgeSDK for linux

### Instructions

1. On your local environment create two directories:

``` "C:/mimik/edge"```
```"C:/mimik/edge/microservices"```

2. Copy the "/dist/PC/edgeSDK.exe" from your desktop into the "C:/mimik/edge" folder.

3. Copy "example" directory under "C:/mimik/edge/microservices" directory.

4. Copy license file (mimikEdge.lic) to "C:/mimik/edge" directory. ( The license file sent to you via email )

5. Goto "C:/mimik/edge" directory and click on  edge.exe to start edgeSDK

6. Once you run the edge on this machine, a series of screen output show the status the status of this particular node: for instance the following message shows that the current machine is acting as a regular node.

![](https://github.com/mimikgit/edgeSDK/blob/master/docs/pictures/Windows_regular_node.png)

7. You can also use the curl command as below in a new terminal and be able to see the following screen log shown below:

``` curl -i http://localhost:8083/mds/v1/nodes```

![](https://github.com/mimikgit/edgeSDK/blob/master/docs/pictures/windows_curl_response.png)

In the first couple of lines of the log, you see the access method e.g. Get, Post, Delete etc. As you see this log is a JSON file that shows the encrypted information about the current node.


## Recommended guides

- [How to install and run example microservice](https://github.com/mimikgit/edgeSDK/wiki/How-to-install-Example-Microservice)
- [How to run edgeSDK example app on Windows 10](https://github.com/mimikgit/edgeSDK/wiki/How-to-run-edgeSDK-example-app-on-Windows)