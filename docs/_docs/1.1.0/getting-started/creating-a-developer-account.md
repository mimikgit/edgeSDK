---
layout: docs
title: Creating a Developer Account
type: getting-started
order: 02
---

A developer account is required to run the provided example microservices and applications:

## Registration

![](/assets/images/documentation/DevRegister.png)

1. Navigate to the [mimik Developer Portal](/dev) 
2. Tap the Register Tab
3. Enter email address and password then tap on Register button
4. Next open the inbox of the email address you provided and confirm your account

## Login

![](/assets/images/documentation/DevLogin.png)

1. Navigate to the [mimik Developer Portal](/dev) 
2. Tap the Login Tab
3. Enter email address and password used in the previous step
3. Tap on Login button
4. Tap Allow to authorize the mimik Developer Portal access rights for app management

After login and authorization you will be redirected to the home screen of the Developer portal

## Add your first application

![](/assets/images/documentation/AppRegister.png)

1. Click on the Developer tab at the top of the home screen
2. Click on the "Add a new app" tab to register your app
3. Provided the required information to add your app

- **App Name**: This field is shown to end users when they registered as a  end user for the application. This info  also indicated in the dialogue box while getting access grants from end users.
- **Website URI**: web URI of the application developer or enterprise company. It should start with protocol address such as "http://mimik.com"
- **Redirect URI**: Redirect URLs are a critical part of the OAuth flow. After a user successfully authorizes an application, the authorization server will redirect the user back to the application with either an authorization code or access token in the URL. Because the redirect URL will contain sensitive information, it is critical that the service doesn’t redirect the user to arbitrary locations.
- **App Type**: Indicates that application type as "web" or native. The redirected URI should  be configured accordingly. The Developer Portal follows OAuth specifications. You can find detailed information about defining URI info based on the app type in the [OAuth redirect URI specification ](https://www.oauth.com/oauth2-servers/redirect-uris) . Please also note that web app should use "App Secret" which is generated when application added in Developer Portal

## Application Settings

![](/assets/images/documentation/AppList.png)

1. After adding your first application, return to Developer Portal home screen
1. For developing native applications with the edgeSDK, you  need the Application ID or App ID (shown at the top right of each Developer Portal)
1. For web applications, you will the App ID as well as the SECRET key. This can be found by tapping the edit icon at the top right corner of your Developer Portal app
1. You will need your app ID and SECRET key to develop your own applications or to run the provided example applications

## Recommended guides

- [How to install edgeSDK on Linux Ubuntu](/docs/1.1.0/installation/linux-ubuntu.html)
- [How to install edgeSDK on Android](/docs/1.1.0/installation/android.html)
- [How to install edgeSDK on iOS](/docs/1.1.0/installation/ios.html)