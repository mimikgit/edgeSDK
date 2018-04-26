//
//  EdgeNode.swift
//  example_microservice_app
//
//  Created by Raduz Benicky on 2018-01-25.
//  Copyright © 2018 mimik. All rights reserved.
//

import UIKit
import SwiftyJSON

class MMKEdgeNode: NSObject {

    var accountId: String?
    var name: String?
    var id: String?
    var os: String?
    var urlString: String?
    var url: URL?
    var thisDevice: Bool = false
    
    convenience init?(json: JSON) {
        
        self.init()
        
        self.accountId = json["accountId"].stringValue
        self.name = json["name"].stringValue
        self.id = json["id"].stringValue
        self.os = json["os"].stringValue
        self.urlString = json["url"].stringValue
        
        if self.urlString != nil {
            self.url = URL.init(string: self.urlString!)
        }
        
        if self.id == MMKEdgeManager.sharedInstance.edge_deviceId {
            self.thisDevice = true
        }
    }
}
