# README #
This example contains simple "Hello World" microservices. Please following instructions to 

## The Repository Folders ##
    ./src     the folder store "Hello World" example
    ./build    the folder store compliled java sript 

## Build example microservice 
Run npm install command for packages
```  
npm install
```  
Run build script under example directory
```  
npm run-script build
```  
Verify that index.js is copied under build directory
 

## Run example microservice ##

create "example" directory under /opt/mimik/microservices
``` 
mkdir /opt/mimik/microservices/example``
``` 
Copy index.js build and config file from /example/build directory to /opt/mimik/microservices/example directory

``` 
cp ./example/build/index.js  /opt/mimik/microservices/example
cp ./example/build/config.json /opt/mimik/microservices/example/

``` 
Restart edge process from /opt/mimik/edge directory
``` 
cd /opt/mimik/edge
./edge
``` 
Verify that "Hello World" example microservices registered and works properly by calling following curl commands:
``` 
curl -i http://localhost:8083/mds/v1/nodes

curl -i http://localhost:8083/example/v1/hello
``` 

## Q & A ##
Q:
A:
   
