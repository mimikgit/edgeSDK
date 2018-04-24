---
layout: docs
title: How to run edgeSDK on Android
type: edgeSDK
order: 00
---

### Avaliable by request

[Message us for more information](support.sdk@mimik.com)

<!-- These instructions will walk you through getting the edgeSDK running on Android platform  -->

<!-- feedback to use edge service from google play unclear. would this not mean my app is associated with the mimik developer account for access app?s -->

<!-- ### Prerequisites
This guide assumes that:
- You are running Windows 10 computer or laptop
- you have a wired or wireless internet connection

### Create license
* Create account at [https://mimikgit.github.io/devportal/](https://mimikgit.github.io/devportal/) to receive edgeSDK license file
* Open your email inbox and follow instructions inside the message from mimik to confirm your account 
* Copy the license file from an invitation email to the download folder of your platform
* Download the (https://github.com/mimikgit/edgeSDK/releases/latest)[latest version] of edgeSDK for Windows
* Unzip edge_Windows.zip and follow the steps as below:


### Instructions

1. On your local environment create two directories:
``` "C:/mimik/edge"``` ```"C:/mimik/edge/microservices"```

3) Copy the "/dist/PC/edgeSDK.exe" from your desktop into the "C:/mimik/edge" folder.

4) Copy "example" directory under "C:/mimik/edge/microservices" directory.

5) Copy license file (mimikEdge.lic) to "C:/mimik/edge" directory. ( The license file sent to you via email )

6) Goto "C:/mimik/edge" directory and click on  edge.exe to start edgeSDK

Once you run the edge on this machine, a series of screen output show the status the status of this particular node: for instance the following message shows that the current machine is acting as a regular node.

![](https://github.com/mimikgit/edgeSDK/blob/master/docs/pictures/Windows_regular_node.png)


You can also use the curl command as below in a new terminal:
```
curl -i http://localhost:8083/mds/1.0.1/nodes
```
you should be able to see the following screen log:

![](https://github.com/mimikgit/edgeSDK/blob/master/docs/pictures/windows_curl_response.png)

In the first couple of lines of the log, you see the access method e.g. Get, Post, Delete etc.

As you see this log is a JSON file that shows the information about the current node. For instance, you can see all the information about nodes (or devices) registered under this particular account ID.

Also you can see microservices which are running on the particular node. for instance as we show in picture 6, the particular node ID is running two different microservices on itself and you can find them under "services". -->