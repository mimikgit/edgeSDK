//
//  MMKGetManager.swift
//  mimik access test 01
//
//  Created by Raduz Benicky on 2018-05-18.
//  Copyright © 2017 mimik. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON
import edgeSDK_iOS

enum NodeListType {
    case network
    case nearby
}

final public class MMKGetManager: NSObject {
    
    class func getNodes( type: NodeListType, completion: @escaping (([MMKEdgeNode]?, error: Error?)) -> Void) {
        
        guard let edgeToken = MMKAuthenticationManager.sharedInstance.edgeToken(),
            let backendToken = MMKAuthenticationManager.sharedInstance.backendToken() else {
                completion ((nil, CustomError.errorWithMessage(message: "Authorization Failed")))
                return
        }
        
        var link: String!
        switch type {
        case .network:
            link = kExampleMicroServiceNetworkNodesLink
        case .nearby:
            link = kExampleMicroServiceNearbyNodesLink
        }
        
        let authenticatedLink = link + "&userAccessToken=\(backendToken)"
        let headers = ["Authorization" : "Bearer \(edgeToken)" ]
        
        Alamofire.request(authenticatedLink, method: .get, parameters: nil, encoding: URLEncoding.default, headers: headers).responseJSON { response in
            switch response.result {
            case .success(let data):
                
                let json = JSON.init(data)
                guard json != JSON.null else {
                    completion ((nil, CustomError.errorWithMessage(message: "Unable to process the response")))
                    return
                }
                
                let dataJson = json["data"]
                guard dataJson != JSON.null else {
                    completion ((nil, CustomError.errorWithMessage(message: "Unable to parse the response")))
                    return
                }
                
                self.getParsedNodes(json: dataJson, completion: { (nodes) in
                    completion((nodes, nil))
                })
                
            case .failure(let error):
                completion ((nil, error))
            }
        }
    }
    
    
    class func getHelloResponse( node: MMKEdgeNode, completion: @escaping ((json: JSON?, error: Error?)) -> Void) {
    
        let link = node.urlString! + kExampleMicroServiceHelloEndpoint
        
        Alamofire.request(link).responseJSON { response in
            switch response.result {
            case .success(let data):
                
                let json = JSON.init(data)
                guard json != JSON.null else {
                    completion((nil, CustomError.errorWithMessage(message: "Unable to process the response")))
                    return
                }
                
                completion((json, nil))
                
            case .failure(let error):
                completion ((nil, error))
            }
        }
    }
}

fileprivate extension MMKGetManager {
    
    class func getParsedNodes(json: JSON , completion: @escaping ([MMKEdgeNode]?) -> Void) {
        
        var newNodes: [MMKEdgeNode] = []
        
        for (_, node) in (json.array?.enumerated())! {
            let edgeNode = MMKEdgeNode.init(json: node)
            if edgeNode != nil {
                newNodes.append(edgeNode!)
            }
        }
        
        completion(newNodes)
    }
}
