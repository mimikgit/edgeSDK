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

    //let kExampleMicroServiceNetworkNodesLink:String = kEdgeServiceLink+"/"+kExampleMicroserviceName+"/v1/drives?type=network"
    class func exampleMicroServiceNetworkNodesLink() -> String {
        return self.edgeServiceLink() + "/" + self.exampleMicroServiceName() + "/v1/drives?type=network"
    }

    //let kExampleMicroServiceNearbyNodesLink:String = kEdgeServiceLink+"/"+kExampleMicroserviceName+"/v1/drives?type=nearby"
    class func exampleMicroServiceNearbyNodesLink() -> String {
        return self.edgeServiceLink() + "/" + self.exampleMicroServiceName() + "/v1/drives?type=nearby"
    }

    //let kExampleMicroServiceHelloEndpoint:String = "/example-v1/v1/hello"
    class func exampleMicroServiceHelloEndpoint() -> String {
        return "/example-v1/v1/hello"
    }

    //let kExampleMicroServiceNodesLink:String = kEdgeServiceLink+"/"+kExampleMicroserviceName+"/v1/nodes/"
    class func exampleMicroServiceNodesLink() -> String {
        return self.edgeServiceLink() + "/" + self.exampleMicroServiceName() + "/v1/nodes/"
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
        return "fe6b7dca-a3ac-427e-a5c0-c0f0523c5baa"
    }
    
    class func redirectURL() -> URL {
        return URL.init(string: "com.exampleapp://example-authorization-code")!
    }
    
    class func authorizationURL() -> URL {
        return URL.init(string: "https://mid.mimik360.com")!
    }
}
