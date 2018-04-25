---
layout: docs
title: Questions and Answers
type: resources
order: 02
---

**Question:**
How is edgeSDK embeded to android device using JavaScript code?

**Answer:**
mimik edgeSDK provides a Serverless JavaScript Programming environment for developers to develop their own specific use microservices. For more information please read the following article: [mimik serverless JavaAcript programming API](/docs/1.2.0/resources/how-to-use-mimik-serverless-javascript-programming-api.html)


***

**Question:**
How do we useedgeSDK API? From what I've seen it's only JS modules, which use prepared functions on response and etc. 

**Answer:**
Once you read the above mentioned documents, and still have uncertainty about how to use the JS to develop microservices, please let us know.  We have an open source project  and that also might help you toward this purpose:

https://github.com/mimikgit/mBeam

***

**Question:**
Is there a need for at least one device to be connected to the internet to create the mesh network? or will it work even if no devices are connected to the internet?

**Answer:**
_When the internet is available:_

(1) The user install the app using app store (on any platforms e.g. iOS, Android etc.).

(2) The user register app under his/her name (meaning edgeSDK register the nodeId under specific accountId) 

(3) edgeSDK receives a valid token from our back-end services (the token has a scope and the scope defines the validation time which could be varied e.g. 24 hours or a couple of days)

_From this point on edgeSDK doesn’t need the internet to be available:_

(4) edgeSDK uses the valid token to provide all functionalities.

(5) Two (or more) devices under the same Wi-Fi could discover each other using edgeSDK.

(6) mimik container manager can spin up any number of required microservice and use edgeSDK services.

(7) Microservices can communicate among each other exchanging data in the way that we illustrated in the diagrams previously.

(8) Once the token gets invalid (passed the valid time, please see number 3), edgeSDK requires the Internet be available to fetch a new valid token.

If all devices inside of the cluster are already registered, and they are under the same Wi-Fi, in that case edgeSDK doesn’t need internet to function.

***

**Question:**
Does edgeSDK has a dependency on running as a SaaS in the cloud. What are the deployment options for edgeSDK backend?

**Answer:**
The product is deployed in Amazon cloud with multi region configuration and it  uses AWS Load balancer and auto scaling features. Other than that, all edgeSDK components are NodeJS. And deployed using Ansible which let us to minimize the required effort required to deploy in Amazon. All deployments are done via Ansible which can also be used for on promise deployment with some modifications in Ansible script.

***
**Question:**
In your current SDK, do you have implementation enabling P2P communication through TCP/UDP hole punching technique or similar (ex: used by bittorrents, VoIP .. etc)?

**Answer:**
We are not using UDP or TCP hole punching as the primary p2p communication b/c of inconsistency in NAT traversal.  
We are using UDP multicast for local supernode discovery. for bootstrap registration and other communication we use HTTPS and for tunneling to BEP we use Secure WebSocket (WSS)  on inbound (BEP TO NODE) and and HTTPS for outbound (NODE TO BEP). 
In future we may consider the UDP/TCP hole punching as a secondary mechanism. 

***
**Question:**

On the current edgeSDK implementation the additional services (micro services/mimik node container) as mentioned in your documentation have to written in javascript , which is not standard in Android or iOS development. Dont’ you have support for native Android SDK development/language?


**Answer:**
To confirm using our edgeSDK you can develop your microservice you can develop microservices using javascript, one time, and deploy them across all platforms.  We have indicated this in our development documentation. 
 
The foundation of mimik technology is to allow server development and deployment on the edge node. We are turning a node into a cloud server which means developers can develop microservices based on serverless architecture to develop server type functionality like what’s being developed on Amazon Lambda using NodeJS.  Server developers are not using OS specific languages/API.  We had to make the effort to make the container layer to work with JavaScript, to keep the servers (microservices) OS agnostic on the edge (similar to nodeJS).  However, on the application level you could use any language to call the Javascript microservice.  For example, for mimik accesses we have developed our three microservices using javascript and the application level been developed using native (iOS is swift, android is java, and PC is html).  This gives flexibility to easily deploy microservices across all platforms, if edgesdk exists, and minimize the OS dependency to the application level only.

