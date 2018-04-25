---
layout: docs
title: How to use mimik serverless Javascript API
type: resources
order: 01
---

mimik node container manager provides a serverless programming environment and at the moment it only supports JavaScript programming language.

## Programming Model

The programming model for mimik edgeSDK follows the Node.js and serverless programming standard. You should be familiar with both serverless programming and Node.JS to understand the terminologies used below.

Local module is a module created locally in your Node.js microservice. This module (or modules) include different functionalities of your microservice in separate files and folders.
The second step is understanding how to expose different types (in this example, the end point is an "String" type and represents an URL) as a module using module.exports. 
The module.exports (or exports) is a special object which is included in every JavaScript file in the Node.js application by default. module is a variable that represents current module (in our example we call it "mimikModule") and exports is an object that will be exposed as a module. So, whatever you assign to module.exports or exports, will be exposed as a module. in our example we are assigning a function to our module, and this function will be executed when you make an HTTP request to the deployed function's endpoint. The function that we defined below (as it shows in the example) will take three parameters, namely: context, request, response.

