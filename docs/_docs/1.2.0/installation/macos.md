---
layout: docs
title: How to run edgeSDK on macOS
type: installation
order: 05
---

## Objectives

These instructions will walk you through getting the edgeSDK running on macOS.

## Hardware Requirements

This guide assumes that:

- you are running macOS  computer or laptop
- you have a wired or wireless internet connection

## Prerequisite

- [Docker Community Edition](https://www.docker.com/community-edition#/download) for your target development platform(s)
- [NPM](https://www.npmjs.com/) v5.7.1
- [NodeJS](https://nodejs.org) v 8.9.4

## Instructions

On your local environment create the following directories. This guide will start from the user Downloads directory:

```mkdir ~/Downloads/mimik/```

```mkdir ~/Downloads/mimik/edge```

```mkdir ~/Downloads/mimik/edge/microservices```

Change into the Downloads directory

Download the [latest Edge.Daemon.pkg](https://github.com/mimikgit/edgeSDK/releases) for macOS and copy it to the directory created in the last step "~/mimik/edge" folder.

```cp ~/Downloads/Edge.Daemon.pkg ~/Downloads/mimik/edge/```

<!-- Next copy the edgeSDK license configuration to the edgeSDK installation directory

```cp -a ~/Downloads/edgeSDK/tools/mimikEdge.lic ~/Downloads/mimik/edge/ ```
 -->

Using Finder navigate to ```~/mimik/edge``` directory and click on package to start edgeSDK **Note** The installer will ask you to log out to complete the installation and start the edgeSDK macOS service

Once the edgSDK is running, you can  use the curl command in a new terminal and be able to see the following screen log shown below:

```curl -i http://localhost:8083/mds/v1/nodes```

![curl response](/assets/images/documentation/curl_response_install_edgeSDK.png)

In the first couple of lines of the log, you see the access method e.g. Get, Post, Delete etc. As you see this log is a JSON file that shows the encrypted information about the current node.

## Account association

Use the [account association](/docs/1.2.0/getting-started/account-association.html) guide link your Developer Account to your edgeSDK allowing you to discover and make calls to devices belonging to the account cluster.

Download the example application  [PC example app](https://github.com/mimikgit/edgeSDK/tree/master/example/PC%20Hello%20App) and use the [documentation](/docs/1.2.0/example-apps/how-to-run-edgesdk-example-app-on-macos.html)  for a quick end to end demo of this process.

## Recommended guides

- [How to install and run example microservice](/docs/1.2.0/microservices/How-to-deploy-example-microservice.html)
- [How to run edgeSDK example app on macOS ](/docs/1.2.0/example-apps/how-to-run-edgeSDK-example-app-on-macos.html)