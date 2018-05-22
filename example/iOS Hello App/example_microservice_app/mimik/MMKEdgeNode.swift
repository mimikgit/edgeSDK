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
        
        if self.id == MMKEdgeManager.sharedInstance.edge_deviceId {
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
        
        guard let edgeToken = MMKAuthenticationManager.sharedInstance.edgeToken(),
            let backendToken = MMKAuthenticationManager.sharedInstance.backendToken() else {
                return
        }
        
        guard let nodeId = self.id else {
            assertionFailure()
            return
        }
        
        let link = kExampleMicroServiceNodesLink + nodeId
        
        let authenticatedLink = link + "?userAccessToken=\(backendToken)"
        let headers = ["Authorization" : "Bearer \(edgeToken)" ]
        
        Alamofire.request(authenticatedLink, method: .get, parameters: nil, encoding: URLEncoding.default, headers: headers).responseJSON { response in
            switch response.result {
            case .success(let data):
                let json = JSON.init(data)
                if json != JSON.null {
                    
                    print("getBEPURL id: \(nodeId) response_json: \(json)")
                    
                    let code = json["code"]
                    if code != JSON.null {
                        let message = json["message"]
                        if message != JSON.null {
                            completion((nil, CustomError.errorWithMessage(message: message.stringValue)))
                            return
                        }
                    }
                    
                    let urlString = json["url"]
                    guard !urlString.stringValue.isEmpty else {
                        completion((nil, CustomError.errorWithMessage(message: "Unable to process the response")))
                        return
                    }
                    
                    guard let url = URL.init(string: urlString.stringValue) else {
                        completion((nil, CustomError.errorWithMessage(message: "Unable to parse the response")))
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
