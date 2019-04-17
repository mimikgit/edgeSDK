//
//  EdgeNode.swift
//  example_microservice_app
//
//  Created by Raduz Benicky on 2018-01-25.
//  Copyright © 2018 mimik. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import edgeSDK_iOS

/**
 An object representing an edgeSDK node.
 
 * accountId: accountId the node is currently associated with
 * name: node name
 * id: node id
 * os: node operating system
 * urlString: node external service link (string)
 * url: node external service link
 * thisDevice: convenience check whether this is the current node
 */
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
        
        let accountId = json["accountId"]
        if accountId != JSON.null {
            self.accountId = accountId.stringValue
        }
        
        let name = json["name"]
        if name != JSON.null {
            self.name = name.stringValue
        }
        
        let id = json["id"]
        if id != JSON.null {
            self.id = id.stringValue
        }
        
        let os = json["os"]
        if os != JSON.null {
            self.os = os.stringValue
        }
        
        let url = json["url"]
        if url != JSON.null {
            self.urlString = url.stringValue
            self.url = URL.init(string: self.urlString!)
        }

        if self.id == MMKAuthenticationManager.sharedInstance.edgeConfig?.nodeId {
            self.thisDevice = true
        }        
    }
    
    func displayName() -> String {
        
        guard let name = self.name else {
            assertionFailure()
            return ""
        }
        
        return name + (self.thisDevice ? " (this device)" : "")
    }
    
    func getBEPURL(_ completion: @escaping ((url: URL?, error: Error?)) -> Void) {
        
        guard let accessToken = MMKAuthenticationManager.sharedInstance.loadToken(type: .accessToken) else {
                return
        }
        
        guard let nodeId = self.id else {
            assertionFailure()
            return
        }
        
        let link = MMKConfigurationManager.exampleMicroServiceNodesLink() + nodeId
        
        let authenticatedLink = link + "?userAccessToken=\(accessToken)"
        let headers = ["Authorization" : "Bearer \(accessToken)" ]
        
        Alamofire.request(authenticatedLink, method: .get, parameters: nil, encoding: URLEncoding.default, headers: headers).responseJSON { response in
            switch response.result {
            case .success(let data):
                let json = JSON.init(data)
                if json != JSON.null {
                    
                    MMKLog.log(message: "getBEPURL id: ", type: .info, value: " \(nodeId) response_json: \(json)", subsystem: .edgeSDK_iOS_example)
                    
                    let code = json["code"]
                    if code != JSON.null {
                        let message = json["message"]
                        if message != JSON.null {
                            completion((nil, NSError.init(domain: message.stringValue, code: 500, userInfo: nil)))
                            return
                        }
                    }
                    
                    let urlString = json["url"]
                    guard !urlString.stringValue.isEmpty else {
                        completion((nil, NSError.init(domain: "Unable to process the response", code: 500, userInfo: nil)))
                        return
                    }
                    
                    guard let url = URL.init(string: urlString.stringValue) else {
                        completion((nil, NSError.init(domain: "Unable to parse the response", code: 500, userInfo: nil)))
                        return
                    }
                    
                    completion((url, nil))
                }
                
            case .failure(let error):
                completion((nil, error))
            }
        }
    }
}
