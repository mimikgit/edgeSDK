//
//  MMKGetManager.swift
//  example_microservice_app
//
//  Created by Raduz Benicky on 2018-05-18.
//  Copyright © 2017 mimik. All rights reserved.
//

import Alamofire
import SwiftyJSON

/**
 enum of potential node list types.
 */
enum NodeListType {
    case network
    case nearby
}

/**
 Class for getting different edgeSDK node lists and performing further calls on their endpoints.
 */
final public class MMKGetManager: NSObject {
    
    /**
     Produces a list of edgeSDK nodes from either the same network as the current node (network) or edgeSDK nodes located nearby (from all networks) as determined by their proximity to the current node with a completion block.
     
     - Parameter type: A type of a edgeSDK nodes list requested. edgeSDK nodes from either the same network as the current node (network) or edgeSDK nodes located nearby (from all networks) as determined by their proximity to the current node.
     - Parameter completion: Completion block returning a list of nodes [MMKEdgeNode] or Error.
     */
    class func getNodes( type: NodeListType, completion: @escaping (([MMKEdgeNode]?, error: Error?)) -> Void) {
        
        guard let accessToken = MMKAuthenticationManager.sharedInstance.loadToken(type: .accessToken) else {
            completion((nil, NSError.init(domain: "Authorization Failed", code: 500, userInfo: nil)))
            return
        }
        
        var link: String!
        switch type {
        case .network:
            link = MMKConfigurationManager.exampleMicroServiceNetworkNodesLink()
        case .nearby:
            link = MMKConfigurationManager.exampleMicroServiceNearbyNodesLink()
        }
        
        let headers = ["Authorization" : "Bearer \(accessToken)" ]
        
        Alamofire.request(link, method: .get, parameters: nil, encoding: URLEncoding.default, headers: headers).responseJSON { response in
            switch response.result {
            case .success(let data):
                
                let json = JSON.init(data)
                guard json != JSON.null else {
                    completion((nil, NSError.init(domain: "Unable to process the response", code: 500, userInfo: nil)))
                    return
                }
                
                let dataJson = json["data"]
                guard dataJson != JSON.null else {
                    completion((nil, NSError.init(domain: "Unable to parse the response", code: 500, userInfo: nil)))
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
    
    /**
     Attempts to call the hello endpoint of the example micro service on a edgeSDK node with a completion block.
     
     - Parameter node: edgeSDK node to call the hello endpoint on.
     - Parameter completion: Completion block returning a hello response JSON or Error.
     */
    class func getHelloResponse( node: MMKEdgeNode, completion: @escaping ((json: JSON?, error: Error?)) -> Void) {
    
        let link = node.urlString! + MMKConfigurationManager.exampleMicroServiceHelloEndpoint()
        
        Alamofire.request(link).responseJSON { response in
            switch response.result {
            case .success(let data):
                
                let json = JSON.init(data)
                guard json != JSON.null else {
                    completion((nil, NSError.init(domain: "Unable to process the response", code: 500, userInfo: nil)))
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
    
    /**
     A private parser.
     
     - Parameter json: raw JSON object to parse the MMKEdgeNode nodes from.
     - Parameter completion: Completion block returning an array of parsed MMKEdgeNode nodes.
     */
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
