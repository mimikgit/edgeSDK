# README #
This example contains simple "Hello World" microservices. Please use following instructions to install example microservice :

Clone the edgeSDK project from GitHub and use following follder under example directory

```
git clone https://github.com/mimikgit/edgeSDK.git
```

## The Repository Folders ##
    ./src     the folder store "Hello World" example
    ./build   the folder store compliled java sript
    ./deploy  image file for the container

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

Create an image for the container under build directory
```  
./build.sh
```  
Verify that example.tar mimik container image created as example.tar under build directory

## Run example microservice ##

Start edge process from /opt/mimik/edge directory
```
cd /opt/mimik/edge
./edge
```

Get the bearer token from /opt/mimik/edge directory using following command
```  
more .mcmUserToken
```
Install the example.tar image on edgeSDK mCM container using bearer token
```  
curl -i -H 'Authorization: Bearer xAfKAu0XjebI159xy3mK' -F "image=@example-v1.tar" http://localhost:8083/mcm/v1/images
```
Initialize example microservice in edgeSDK mCM contatiner using bearer token
```
curl -i -H 'Authorization: Bearer xAfKAu0XjebI159xy3mK' -d '{"name": "example-v1", "image": "example-v1", "env": {"BEAM": "http://127.0.0.1:8083/beam/v1","MCM.BASE_API_PATH": "/example/v1", "MCM.WEBSOCKET_SUPPORT": "false", "MFD": "https://mfd-eu.mimik360.com/mFD/v1", "MPO": "https://mpo.mimik360.com/mPO/v1", "uMDS": "http://127.0.0.1:8083/mds/v1"}
}' http://localhost:8083/mcm/v1/containers
```


Verify that "Hello World" example microservices registered and works properly by calling following curl commands:
```
curl -i http://localhost:8083/example/v1/hello
```

## Q & A ##
Q:
A:
