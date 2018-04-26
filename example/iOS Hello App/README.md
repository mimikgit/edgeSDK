## Objectives

Use the example application for iOS devices to understand how interactions between application, microservice, and edgeSDK work.

## Installation

First download and install the [edgeSDK for iOS](https://developers.mimik360.com/docs/1.1.0/installation/ios.html) on to the mobile device you will test with

On your computer use the command line to clone the edgeSDK project from GitHub somewhere accessible on your user home directory. This guide starts from the Downloads folder

```cd ~/Downloads```

```git clone https://github.com/mimikgit/edgeSDK.git```

Navigate to the example iOS directory

```cd /examples/iOS\ Hello\ App/```

Install the required cocoapods

```pod install```

Start Xcode 9.3+ and open the example_microservice_app project. **Note** You must use a real device, not an emulator to build the example. edgeSDK functionality will not operate on emulated devices.

## Using the app

Once the application is running on your test device there are a few functions you can test.

First press the StartEdge button to start the edgeSDK service

After about five seconds press the Login button and allow the example application to use the authorization webpage by selecting Continue on the iOS popup dialogue

Then login using your Developer Account credentials and select Allow to exit the authorization webpage

Tap Associate to link your developer account to this edgeSDK runtime

Press Load&mu;Services button to deploy the [example microservice](https://developers.mimik360.com/docs/1.1.0/microservices/how-to-deploy-example-microservice.html) on this device

Once deployed you can scan for devices by pressing GetNodes and see the list of devices edgeSDK can discover nearby. It works best if you have two device running the example app on the same network.

Tap any of the discovered devices to see a Hello WORLD!!! response at the bottom of your screen.

## Summary

Below is the message sequence between example app, microservice and edgeSDK:

![app registration](https://developers.mimik360.com/assets/images/documentation/Hello App registration.png)

1. First the example app associates edgeSDK with accountID
1. Developer registers its sample app to mimik developer portal and receives the account information and account key
1. In the sample app, it uses registered account key to associate sample app with edgeSDK 
1. App verifies that edgeSDK associated with the correct account info.

After  the following message flow is used to retrieve account cluster nodes:

![account cluster](https://developers.mimik360.com/assets/images/documentation/example microservice account cluster.png)

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

- [mimik serverless JavaScript programming API](https://developers.mimik360.com/docs/1.1.0/resources/how-to-use-mimik-serverless-javascript-programming-api.html)