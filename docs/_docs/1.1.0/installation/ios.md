---
layout: docs
title: How to run edgeSDK on iOS
type: installation
order: 02
---

## Objectives

These instructions will walk you through getting the edgeSDK running on iOS

## Hardware Requirements

This guide assumes that:

- You are running iOS 11.0+
- You have a LTE or WiFi connection

## Prerequisite

- Xcode 9.3
- Swift 4.1

## Instructions

First download the iOS edgeSDK Cocoapod from our [Github Repository(https://github.com/mimikgit/cocoapod-edge-prod.git)]

To install it, simply add the following lines to your Podfile:

```source 'https://github.com/CocoaPods/Specs.git'```

```source https://github.com/mimikgit/cocoapod-edge-specs.git'```

```cd edgeSDK-ios```

```pod 'edgeSDK-iOS', '0.0.83'```

## Account association

Use the [account association](/docs/1.1.0/getting-started/account-association.html) guide link your Developer Account to your edgeSDK allowing you to discover and make calls to devices belonging to the account cluster 

Download the example application  [PC example app](https://github.com/mimikgit/edgeSDK/example/PC%20Hello%20App) and use the [documentation](/docs/1.1.0/example-apps/how-to-run-edgesdk-example-app-on-linux-ubuntu.html)  for a quick end to end demo of this process.

## Recommended guides

- [How to deploy a microservice to the edgeSDK](/docs/1.1.0/microservices/how-to-deploy-example-microservice.html)
- [How to run edgeSDK example app on iOS](/docs/1.1.0/example-apps/how-to-run-edgeSDK-example-app-on-iOS.html)