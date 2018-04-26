Get the mcm Bearer token from .mcm-token file located under the same directory in where edgeSDK binary located 

Adding a image to the mimik container
curl -i -H 'Authorization: Bearer xAfKAu0XjebI159xy3mK' -F "image=@example-v1.tar" http://localhost:8083/mcm/v1/images


Creating a container from the image uploaded
curl -i -H 'Authorization: Bearer xAfKAu0XjebI159xy3mK' -d '{"name": "example-v1", "image": "example-v1", "env": {"BEAM": "http://127.0.0.1:8083/beam/v1","MCM.BASE_API_PATH": "/example/v1", "MCM.WEBSOCKET_SUPPORT": "false", "MFD": "https://mfd-dev.mimikdev.com/mFD/v1", "MPO": "https://mpo-dev.mimikdev.com/mPO/v1", "uMDS": "http://127.0.0.1:8083/mds/v1"}
}' http://localhost:8083/mcm/v1/containers

Delete a container
curl -i -X DELETE http://localhost:8083/mcm/v1/containers/example-v1


Delete a image
curl -i -X DELETE http://localhost:8083/mcm/v1/images/example-v1



Get the mcm token from .mcm-token file located in the same directory in where edgeSDK binary located 
curl -i -H 'Authorization: Bearer pBQvQQXdxLHalgdOvaCv' http://localhost:8083/mcm/v1/containers
