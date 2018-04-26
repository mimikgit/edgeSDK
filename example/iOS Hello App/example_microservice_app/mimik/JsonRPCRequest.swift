//
//  JsonRPCRequest.swift
//  mimik
//
//  Created by Raduz Benicky on 2018-02-16.
//  Copyright © 2018 MIMIK. All rights reserved.
//

import Starscream
import SwiftyJSON

class JsonRPCRequest: NSObject, WebSocketAdvancedDelegate {
    
    public enum JsonRPCMethod : String {
        case getMe = "getMe"
        case getEdgeIdToken = "getEdgeIdToken"
        case associateAccount = "associateAccount"
        case unassociateAccount = "unassociateAccount"
        case unknown = "unknown"
    }
    
    var method:JsonRPCMethod = .unknown
    var jsonrpc:String = "2.0"
    var id: String = UUID().uuidString
    var parameters: [String] = []
    var requestJSON: JSON?
    var completionHandler: ((Any)->Void)?
    
    internal lazy var edgeServiceSocket: WebSocket = {
        let socket = WebSocket.init(request: URLRequest.init(url: URL.init(string: "ws://"+kEdgeServiceIPPort+"/ws/edge-service-api/v1")!))
        socket.advancedDelegate = self
        return socket
    }()
    
    convenience init(method: JsonRPCMethod, parameters: [String]?) {
        self.init()
        self.method = method
        
        if parameters == nil {
            self.parameters = parametersForMethod(method: method)
        }
        
        let json: [String: Any] = [
            "method" : self.method.rawValue,
            "jsonrpc" : self.jsonrpc,
            "id" : self.id,
            "params" : self.parameters
        ]
        
        self.requestJSON = JSON.init(json)
    }
    
    func parametersForMethod(method: JsonRPCMethod) -> [String] {
        switch self.method {
        case .getMe, .unknown:
            return []
        case .associateAccount, .unassociateAccount:
            
            guard let edgeToken = MMKAuthenticationManager.sharedInstance.edgeToken() else {
                return []
            }

            return [edgeToken]
        case .getEdgeIdToken:
            return []
        }
    }
    
    func executeRequest(completion: @escaping (Any) -> Void) {
        self.edgeServiceSocket.connect()
        self.completionHandler = completion
    }
    
    func parseAndPostResult(json: JSON) -> Void {
        var string: String = ""
        
        guard let storedCompletionHandler = self.completionHandler else {
            return
        }
        
        switch self.method {
        case .getMe:
            if json != JSON.null {
                let subJson = json["result"]
                if subJson != JSON.null {
                    let result = JSON.init(subJson)
                    if result != JSON.null {
                        string = result["accountId"].stringValue
                        storedCompletionHandler(string)
                    }
                }
            }
            break
        case .associateAccount, .unassociateAccount:

            if json != JSON.null {
                
                let resultJSON = json["result"]
                let errorJSON = json["error"]
                
                if resultJSON != JSON.null {
                    string = resultJSON["accountId"].stringValue
                    storedCompletionHandler(string)
                }
                else if errorJSON != JSON.null {
                    string = errorJSON["data"].stringValue
                    if string.contains("parse error - unexpected") {
                        return
                    }
                    
                    storedCompletionHandler(CustomError.errorWithMessage(message: string))
                }
                else {
                    storedCompletionHandler(CustomError.errorWithMessage(message: "Unknown Error"))
                }
            }
        case .unknown:
            break
        case .getEdgeIdToken:

            if json != JSON.null {
                let subJson = json["result"]
                if subJson != JSON.null {
                    let result = JSON.init(subJson)
                    if result != JSON.null {
                        string = result["id_token"].stringValue
                    
                        storedCompletionHandler(string)
                    }
                }
            }
            break
        }
        
        self.edgeServiceSocket.disconnect(forceTimeout: 1, closeCode: 1000)
    }
    
    internal func responseId(json: JSON) -> String? {
        let string = json["id"].stringValue
        return string
    }
    
    internal func processResponseForId(responseJSON: JSON, responseId: String) -> Void {
        self.parseAndPostResult(json: responseJSON)
    }
    
    public func websocketDidConnect(socket: WebSocket) {
        print("JsonRPCRequest websocketDidConnect: \(self.edgeServiceSocket.currentURL)")
        print("JsonRPCRequest sending to edgeServiceSocket: \(self.requestJSON?.rawString() ?? "")")
        self.edgeServiceSocket.write(string: self.requestJSON!.rawString()!)
    }
    
    public func websocketDidDisconnect(socket: WebSocket, error: Error?) {
        print("JsonRPCManager websocketDidDisconnect: \(self.edgeServiceSocket.currentURL)")
    }
    
    public func websocketDidReceiveMessage(socket: WebSocket, text: String, response: WebSocket.WSResponse) {
        
        if !text.contains("parse error - unexpected") {
            print("JsonRPCManager websocketDidReceiveMessage: \(text)")
        }
        
        let json = JSON.init(parseJSON: text)
        if json != JSON.null {
            let responseId = self.responseId(json: json)
            if responseId != nil {
                self.processResponseForId(responseJSON: json, responseId: responseId!)
            }
        }
    }
    
    public func websocketDidReceiveData(socket: WebSocket, data: Data, response: WebSocket.WSResponse) {
    }
    
    public func websocketHttpUpgrade(socket: WebSocket, request: String) {
    }
    
    public func websocketHttpUpgrade(socket: WebSocket, response: String) {
    }
}
