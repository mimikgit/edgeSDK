//
//  JsonRPCRequestQuery.swift
//  mimik
//
//  Created by Raduz Benicky on 2018-02-19.
//  Copyright © 2018 MIMIK. All rights reserved.
//

import SwiftyJSON

class JsonRPCRequestQuery: JsonRPCRequest {
    
    public enum JsonRPCRequestQueryType : String {
        case isAssociated = "isAssociated"
        case isAssociatedWithAccountId = "isAssociatedWithAccountId"
        case getVersion = "getVersion"
        case getNodeId = "getNodeId"
        case getAccountId = "getAccountId"
        case unknown = "unknown"
    }
    
    var query: JsonRPCRequestQueryType = .unknown
    var queryParameters: [String]?
    
    convenience init(query: JsonRPCRequestQueryType, queryParameters: [String]?) {
        self.init(method: JsonRPCRequestQuery.requestMethodForQuery(query: query), parameters: nil)
        self.query = query
        self.queryParameters = queryParameters
    }
    
    class func requestMethodForQuery(query: JsonRPCRequestQueryType) -> JsonRPCRequest.JsonRPCMethod {
        switch query {
        case .isAssociated:
            return .getMe
        case .isAssociatedWithAccountId:
            return .getMe
        case .getVersion:
            return .getMe
        case .getNodeId:
            return .getMe
        case .getAccountId:
            return .getMe
        case .unknown:
            return .unknown
        }
    }
    
    func executeRequestQuery(completion: @escaping (Any) -> Void) {
        self.edgeServiceSocket.connect()
        completion("OK")
    }
    
    @available(*, unavailable) override func executeRequest(completion: @escaping (Any) -> Void) {
        self.edgeServiceSocket.connect()
        completion("OK")
    }
    
    override func parseAndPostResult(json: JSON, completion: @escaping (Any) -> Void) {
        var queryResult: Any?
        
        switch self.query {
            
        case .isAssociated:
            if json != JSON.null {
                let subJson = json["result"]
                if subJson != JSON.null {
                    let result = JSON.init(subJson)
                    if result != JSON.null {
                        let string = result["accountId"].stringValue
                        queryResult = !string.isEmpty
                        completion(queryResult ?? "")
                    }
                }
            }
            break
            
        case .isAssociatedWithAccountId:
            if json != JSON.null {
                let subJson = json["result"]
                if subJson != JSON.null {
                    let result = JSON.init(subJson)
                    if result != JSON.null {
                        let string = result["accountId"].stringValue
                        if self.queryParameters != nil {
                            queryResult = (self.queryParameters?.contains(string))!
                            completion(queryResult ?? "")
                        }
                    }
                }
            }
            break
            
        case .getVersion:
            if json != JSON.null {
                let subJson = json["result"]
                if subJson != JSON.null {
                    let result = JSON.init(subJson)
                    if result != JSON.null {
                        let string = result["version"].stringValue
                        queryResult = string
                        completion(queryResult ?? "")
                    }
                }
            }
            break
        
        case .getNodeId:
            if json != JSON.null {
                let subJson = json["result"]
                if subJson != JSON.null {
                    let result = JSON.init(subJson)
                    if result != JSON.null {
                        let string = result["nodeId"].stringValue
                        queryResult = string
                        completion(queryResult ?? "")
                    }
                }
            }
            break
            
        case .getAccountId:
            if json != JSON.null {
                let subJson = json["result"]
                if subJson != JSON.null {
                    let result = JSON.init(subJson)
                    if result != JSON.null {
                        let string = result["accountId"].stringValue
                        queryResult = string
                        completion(queryResult ?? "")
                    }
                }
            }
            break
            
        case .unknown:
            break
        }
        
        self.edgeServiceSocket.disconnect(forceTimeout: 1, closeCode: 1000)
    }
}
