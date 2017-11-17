# README #
This example contains simple "Hello World" microservices. Please following instructions to 

## The Repository Folders ##
    ./src     the folder store "Hello World" example
    ./build    the folder store compliled java sript 

## Download and install Jmeter 
* Download the Jmeter and unzip to {home}/apache-jmeter folder 
     http://http://jmeter.apache.org/download_jmeter.cgi

## Setup environment variables ##
  create a jmeter_env_setting.sh file which include 
```  
#!/bin/bash
export MID_URL={ the mid server URL, example mid-dev1.mimik360.com }
export MPO_URL={ the mpo server URL, example mpo-dev1.mimikdev.com }
export USERS_TOKEN_FILE={ the users token data file } 
export DEV_US_DATABASE_IP={ the MongoDb ip setting }
export DEV_US_DATABASE_NAME={ the MongoDb database name }
export SERVER_DEPLOY_TYPE={ the deploy type, example dev1 }
export MID_ADMIN_TOKEN={ the mID server admin user token }
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
