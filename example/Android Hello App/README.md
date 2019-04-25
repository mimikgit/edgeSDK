## Objectives

Use the example application for Android devices to understand how interactions between application, microservice, and edgeSDK work.

## Installation

First download and install the [edgeSDK for Android](https://developer.mimik.com/docs/installation/android) on to the mobile device you will test with

On your computer use the command line to clone the edgeSDK project from GitHub somewhere accessible on your user home directory. This guide starts from the Downloads folder .

```cd ~/Downloads```

```git clone https://github.com/mimikgit/edgeSDK.git```

Open Android Studio

Select open an existing project and find the example app on your local machine

Run the build on a physical android device

## Using the app

Once the application is running on your test device a few functions you can test out

First start the edgeSDK service

Next press the login button and use your Developer Account credentials to login

Allow the example application the requested authorization

The app will show feedback that the edgeSDK acquired your user token

Associate your account

Press dock to deploy the [example microservice](https://developer.mimik.com/docs/microservices/deploy) to this device

Once deployed you can scan for devices and see the list of devices the edgeSDK can discovery nearby.

Tap on any of the devices to see a hello world response at the bottom of your screen.

## Summary

Below is message sequence between example app, microservice and edgeSDK:

1. First the example app associates edgeSDK with accountID
1. Developer registers its sample app to mimik developer portal and receives the account information and account key
1. In the sample app, it uses registered account key to associate sample app with edgeSDK
1. App verifies that edgeSDK associated with the correct account info.

After  the following message flow is used to retrieve account cluster nodes:

1. Sample app first calls account service from example microservice to retrieve account cluster nodes from the BES using the authorization key of associated account
1. mPO requests the nodes information  including BEP references of account cluster nodes.
1. mDS gets the account key and returns cluster nodes information.
1. mPO returns nodes and profile information of cluster account
1. example microservices also calls nearby service from edgeSDK to get linked local nodes,
1. if available, example microservice uses the local addresses of account cluster nodes to communicate with them
1. example microservice return account cluster nodes ( BEP or local address)  and then sample example displays info on the app screen.
1. User selects one of the nodes and then sample app calls hello method with select node's' url to get a message from this node.
1. Show the hello world response

## Recommended guides

- [mimik serverless JavaScript programming API](https://developer.mimik.com/docs/api-guides/apis)
