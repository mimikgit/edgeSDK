//
//  MMKConfigurationManager.swift
//  example_microservice_app
//
//  Created by Radúz Benický on 2019-04-17.
//  Copyright © 2019 mimik. All rights reserved.
//

import UIKit
import edgeSDK_iOS

class MMKConfigurationManager: NSObject {

    class func exampleMicroServiceNetworkNodesLink() -> String {
        return self.edgeServiceLink() + "/" + self.clientId() + "/" + self.exampleMicroServiceName() + "/v1/drives?type=network"
    }

    class func exampleMicroServiceNearbyNodesLink() -> String {
        return self.edgeServiceLink() + "/" + self.clientId() + "/" + self.exampleMicroServiceName() + "/v1/drives?type=nearby"
    }

    class func exampleMicroServiceHelloEndpoint() -> String {
        return "/" + self.clientId() + "/" + self.exampleMicroServiceName() + "/v1/hello"
    }

    class func exampleMicroServiceNodesLink() -> String {
        return self.edgeServiceLink() + "/" + self.clientId() + "/" + self.exampleMicroServiceName() + "/v1/nodes/"
    }
    
    class func edgeServiceLink() -> String {
        return edgeSDK_iOS.edgeServiceLink()
    }
    
    class func edgeWebSocketServiceLink() -> String {
        return edgeSDK_iOS.edgeWebSocketServiceLink()
    }
    
    class func edgeServiceLinkURL() -> URL? {
        let checkedEdgeServiceLink = self.edgeServiceLink()
        let url = URL.init(string: checkedEdgeServiceLink)
        return url
    }
    
    class func exampleMicroServiceName() -> String {
        return "example-v1"
    }
}

extension MMKConfigurationManager {
    //
    // This is where you'd put your own application id from the developer portal, using mimik app value here.
    //
    class func clientId() -> String {
        return "ab933bf9-2131-4c08-8ab3-1f7086387ee2"
    }
    
    class func redirectURL() -> URL {
        return URL.init(string: "com.mimik.example.appauth://oauth2callback")!
    }
    
    class func authorizationURL() -> URL {
        return URL.init(string: "https://mid.mimik360.com")!
    }
}
