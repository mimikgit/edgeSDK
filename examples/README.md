# README #
This example contains simple "Hello World" microservices. Please following instructions to 

## The Repository Folders ##
    ./src     the folder store "Hello World" example
    ./build    the folder store compliled java sript 

## Build example microservice 
Run build script under example directory
```  
npm run-script build
```  
Verify that index.js is copied under build directory
 


## Run example microservice ##

create "example" directory under /opt/mimik/microservices
``mkdir /opt/mimik/microservices/example``
Copy index.js build from /example/build directory to /opt/mimik/microservices/example directory
 
```  

  run the command 
```  
  chmod a+x jmeter_env_setting.sh
  source jmeter_env_setting.sh
```  
  to setup the environment variables

## Create user and get user's access token  ##

* Prepare the test user data 
   The test users data is store in data\users.dat file
   The users.data include 10000 users email and password
* run "source jmeter_env_setting.sh" to setup the environment variables
* Run the mid_admin_users.sh with number threads and loops 
  The mid_admin_users.sh will test the /mid/v1/admin/users api and the API will create the test users and output the user's data with access token.      

## Q & A ##
Q: How to clean the mPO, mFD, mTS data in MongoDB
A:
   There is a tools which can clean the data in MongoDB
```
   1. setup the DB setting data in jmeter_env_setting.sh file and run "source  jmeter_env_setting.sh"
   2. goto tools folder and run "npm install"
   3. run "node dbClean.js"
```   
