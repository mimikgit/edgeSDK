---
layout: docs
title: Technical documentation
type: resources
order: 03
---

# edgeSDK

mimik provides distributed edge cloud computing platform that extends the cloud functionality to the edge by utilizing the power of edge nodes.  By downloading the mimik edgeSDK you can turn any computing device including mobile, smart TV, STB, NAS, PC, Wi-Fi AP, Raspberry Pi, IOT Gateway, etc. into an edge cloud node.  The edgeSDK also includes a light container as a runtime environment for remote microservice deployment and management (download, install, start, stop and delete).  mimik platform provides ad-hoc formations of clusters based on network, proximity and account and enables the enables the communication between the nodes within and across the cluster within and across networks and devices. On top of this communication fabric, mimik provides the light container management technology that allows software developers to develop and manage the microservices and enable communication of microservices within and across networks and devices. 

As a developer you can think of many different use cases utilizing edgeSDK without worrying about the complexity of underlying distributed edge cloud platform and stay focused on develop and deploy your solution based on microservice, serverless architecture in similar fashion as you develop with traditional cloud within the constrain of targeted device. These use cases include but not limited to content distribution, personal cloud, gaming, autonomous car (v2v, v2x), drone communication, digital health, IoT and many others.  

Our goal with this page is to provide you with a simple guideline in how to use our SDK.  We continue evolving the solution and we are eager to receive your feedback as you are using the edgeSDK to enable your targeted SDK. 

mimik edgeSDK is a downloadable software that developers can interact with through a series of API(s).  The edge cloud fabric provides the following capabilities 

1. real-time device (node) discovery
2. ad-hoc cluster formation of nodes
3. communication between nodes within and across clusters, direct and indirect via on-demand dynamic instantiation of the intermediary nodes.

light container as a runtime environment for microservice development and management on the edge device:

4. light container for microservices
5. remote microservice discovery
6. remote microservice management
7. ad-hoc cluster formation and communication at the microservice level

mimik edgeSDK is available for variety of platforms:

- Android (5.0+)
- iOS (9.0+)
- Linux - Ubuntu (16.04+)
- Linux - Debian
- Linux - Raspbian (8.1+)
- mac OS X (El Capitan+)
- Windows (7+)
- Tizen (3.0+)

*Please note:*
Please send your request to (support.sdk@mimik.com[support.sdk@mimik.com]) in order to receive the edgeSDK.*

### JavaScript Serverless Programming API

mimik edgeSDK provides a JavaScript programming API for developers to develop and deploy their microservices. Microservice(s) is an approach to application development in which a large application is built as a suite of modular services. Each module supports a specific business goal and uses a simple, well-defined interface to communicate with other sets of services. [see JS Serverless programming API](/docs/1.1.0/resources/how-to-use-mimik-serverless-javascript-programming-api.html).  The serverless microservice development is mainly practiced for the back-end development and deployment on the cloud.  Given we are turning an edge node into a cloud server, with mimik edgeSDK we now made it possible to follow the same principal and develop such microservices for the edge environment using standard JavaScript programming. 
 
To show case the capabilities of the edgeSDK we have developed a few microservices and to use as examples for your development in how to develop a microservice on our environment and how to utilize the API(s). 


***
### Microservices


#### mSuperdrive microservice:
mSuperdrive microservice, provides API for media distribution use cases. By using mSuperdrive you can share, by streaming, any type of file/content on any node (edge or cloud node) to any other nodes across any type of network,  (Wi-Fi, LTE or 3G) and cluster account and proximity.
 
[Check out the mSuperdrive API(s) on SWAGGERhub](https://app.swaggerhub.com/apis/mimik/mSuperdrive/)


#### mDrive microservice:
mDrive microservice abstracts access to storage capability available on any edge node(s) and provides distributed file management. This microservice provides the same capability as cloud storage like google drive, Dropbox, and iCloud but with edge computing resources.  So this way your device turns into a cloud drive as long as you have the edgeSDK and mDrive on your device.  The API follows the same semantics as cloud storage providers which makes it super easy to use. So you simply, can deploy and use this microservice on any node that has storage including cloud node.
 
[Check out the mDrive API(s) on SWAGGERhub](https://app.swaggerhub.com/apis/mimik/mDrive/)


#### mBeam microservice:
With mBeam you don’t have to copy your file/content in another storage but can simple send the link to your file on any node to another node. This way the receiver node utilizes the link to view your file/content off of your node while your file/content remains on sender node.  So no more duplicating your file/content across different cloud providers or social media.  You can simply pass the link to it for view and with addition of policy you can change the policy to download the content if that is required for the application business logic. 
 
[Check out the mBeam API(s) on SWAGGERhub](https://app.swaggerhub.com/apis/mimik/mBeam/)
 


***
