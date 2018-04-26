//
//  MMKAuthenticationManager.swift
//  mimik access
//
//  Created by Raduz Benicky on 2018-03-06.
//  Copyright © 2018 mimik. All rights reserved.
//

import Foundation
import SafariServices
import AppAuth
import SwiftyJSON
import JWTDecode
import Alamofire

final public class MMKAuthenticationManager: NSObject {
    
    public static let sharedInstance = MMKAuthenticationManager()
    let kAuthStateEdgeKey: String = "com.mimik.exampleapp.authStateEdge"
    let kProfileNickNameSetKey: String = "com.mimik.exampleapp.profileNickNameSetKey"
    let kBackEndTokenKey: String = "com.mimik.exampleapp.backEndTokenKey"
    let kAuthorizationCodeIssuer: String = "https://mid.mimik360.com"
    let kRedirectURL: URL = URL.init(string: "com.exampleapp://example-authorization-code")!
    var authorizationServiceConfiguration: OIDServiceConfiguration?
    
    //
    // this is where you'd put your own application id from the developer portal (https://developers-stg.mimik360.com)
    // for now we'll use mimik's internal registration id for this example application
    //
    let kClientId: String = "fe6b7dca-a3ac-427e-a5c0-c0f0523c5baa"
    
    public enum AuthStateType: String {
        case edge = "edge"
        case backend = "backend"
    }
    
    public enum AuthStateActionType: String {
        case login = "login"
        case reset = "reset"
    }
    
    private override init() {
        super.init()
        self.loadAuthState(type: MMKAuthenticationManager.AuthStateType.edge)
    }
    
    fileprivate var currentAuthorizationFlow: OIDAuthorizationFlowSession?
    fileprivate var authStateEdge: OIDAuthState?
    fileprivate var jsonRPCRequest: JsonRPCRequest?
}

public extension MMKAuthenticationManager {
    
    //
    // initiates the OID login process in a SFAuthenticationSession (called internally by the AppAuth library)
    // https://openid.github.io/AppAuth-iOS/
    // https://developer.apple.com/documentation/safariservices/sfauthenticationsession
    //
    func login(viewController: UIViewController, completion: @escaping (Any) -> Void){
        
        self.getEdgeIdToken { (edgeIdToken) in
            
            self.getAndStoreAllTokens(viewController: viewController, edgeIdToken: edgeIdToken, completion: { (result) in
                completion("OK")
            })
        }
    }
    
    //
    // initiates the OID reset process in a SFAuthenticationSession (called internally by the AppAuth library)
    // https://openid.github.io/AppAuth-iOS/
    // https://developer.apple.com/documentation/safariservices/sfauthenticationsession
    //
    func resetEdge(viewController: UIViewController, completion: @escaping (Any) -> Void){
        
        self.getEdgeIdToken { (edgeIdToken) in
            
            self.getUnassociateToken(viewController: viewController, edgeIdToken: edgeIdToken, completion: { (result) in
                completion("OK")
            })
        }
    }
    
    //
    // initiates edgeSDK account association process via a JSON-RPC protocol through a WebSocket connection to the edgeSDK instance
    //
    func accountAssociate(completion: @escaping (Any) -> Void){
        self.jsonRPCRequest = JsonRPCRequest.init(method: .associateAccount, parameters: nil)
        self.jsonRPCRequest?.executeRequest(completion: { (result) in
            completion(result)
        })
    }
    
    //
    // initiates edgeSDK account unassociation process via a JSON-RPC protocol through a WebSocket connection to the edgeSDK instance
    //
    func accountUnassociate(completion: @escaping (Any) -> Void){
        self.jsonRPCRequest = JsonRPCRequest.init(method: .unassociateAccount, parameters: nil)
        self.jsonRPCRequest?.executeRequest(completion: { (result) in
            completion(result)
        })
    }
    
    func isAuthorized(type: AuthStateType) -> Bool {
        
        switch type {
        case .edge:
            do {
                if self.authStateEdge != nil {
                    return self.authStateEdge!.isAuthorized
                }
            }
        case .backend:
            do {
                if  UserDefaults.standard.string(forKey: kBackEndTokenKey) != nil {
                    return !(UserDefaults.standard.string(forKey: kBackEndTokenKey)?.isEmpty)!
                }
                return false
            }
        }
        
        return false
    }
    
    func backendToken() -> String? {
        var backendToken: String?
        
        backendToken = self.restoreBackEndToken()
        return backendToken
    }
    
    func edgeToken() -> String? {
        var edgeToken: String?
        
        if !self.isAuthorized(type: .edge){
            return nil
        }
        
        edgeToken = self.authStateEdge?.lastTokenResponse?.accessToken
        return edgeToken
    }
    
    func accountId() -> String? {
        
        if !self.isAuthorized(type: .edge){
            return nil
        }
        
        return self.accountIdFrom(authState: self.authStateEdge!)
    }
    
    func clearAuthStates() -> Void {
        self.clearBackEndToken()
        self.clearEdgeToken()
    }
}

fileprivate extension MMKAuthenticationManager {
    func getEdgeIdToken(completion: @escaping (String) -> Void) {
        
        self.jsonRPCRequest = JsonRPCRequest.init(method: .getEdgeIdToken, parameters: nil)
        self.jsonRPCRequest?.executeRequest(completion: { (result) in
            completion(result as! String)
        })
    }
    
    
    func getAndStoreAllTokens(viewController: UIViewController, edgeIdToken:String, completion: @escaping (Any) -> Void) {
        
        self.getAndStoreEdgeToken(action: .login, viewController: viewController, edgeIdToken: edgeIdToken) { (result) in
            
            self.getAndStoreBackEndToken(completion: { (result) in
                completion("OK")
            })
        }
    }
    
    func getUnassociateToken(viewController: UIViewController, edgeIdToken:String, completion: @escaping (Any) -> Void) {
        
        self.getAndStoreEdgeToken(action: .reset, viewController: viewController, edgeIdToken: edgeIdToken) { (result) in
            completion("OK")
        }
    }
    
    func getAndStoreEdgeToken(action: AuthStateActionType, viewController: UIViewController, edgeIdToken:String, completion: @escaping (Any) -> Void) {
        
        do {
            OIDAuthorizationService.discoverConfiguration(forIssuer: URL(string: self.kAuthorizationCodeIssuer)!, completion: { (configuration, error) in

                self.authorizationServiceConfiguration = configuration
                
                if configuration != nil && error == nil {
                    
                    let additionalParameters: [String:String] = ["edgeIdToken":edgeIdToken]
                    
                    let request: OIDAuthorizationRequest = OIDAuthorizationRequest.init(configuration: configuration!,
                                                                                        clientId: self.kClientId,
                                                                                        scopes: self.scopesForEdgeAuthToken(action: action),
                                                                                        redirectURL: self.kRedirectURL,
                                                                                        responseType: OIDResponseTypeCode,
                                                                                        additionalParameters: additionalParameters)
                    
                    self.currentAuthorizationFlow = OIDAuthState.authState(byPresenting: request, presenting: viewController) { authState, error in
                        
                        if error != nil {
                            print("🔥🔥🔥 getAndStoreEdgeToken error: \(String(describing: error?.localizedDescription))")
                            completion(error!)
                        }
                        else if authState != nil {
                            print("☘️☘️☘️ Success in getAndStoreEdgeToken")
                            self.memorizeEdgeAuthState(authState: authState!)
                            completion(authState!)
                        }
                        else {
                            print("🔥🔥🔥 Failed in getAndStoreEdgeToken")
                            completion(CustomError.errorWithMessage(message: "🔥🔥🔥 Failed in getAndStoreEdgeToken"))
                        }
                    }
                }
            })
        }
    }
    
    func getAndStoreBackEndToken(completion: @escaping (Any) -> Void) {
        
        if self.isAuthorized(type: .edge) {
            guard let url = self.authorizationServiceConfiguration?.tokenEndpoint else {
                assertionFailure()
                return
            }
            
            let parameters: [String: Any] =  [
                "grant_type" : "exchange_edge_token",
                "token" : self.edgeToken()!,
                "client_id" : self.kClientId
            ]
            
            let headers = [
                "Content-Type": "application/x-www-form-urlencoded"
            ]
            
            Alamofire.request(url, method: .post, parameters: parameters, encoding: URLEncoding.httpBody, headers: headers).responseJSON(completionHandler: { (response) in
                
                switch response.result {
                    
                case .success(_):
                    
                    do {
                        if response.data != nil {
                            let json = try JSON.init(data: response.data!)
                            print("☘️☘️☘️ getAndStoreBackEndToken json: \(json)")
                            
                            if json["access_token"] != JSON.null {
                                completion("OK")
                                let backend_access_token = json["access_token"].stringValue
                                print("🍀🍀🍀 got the backend_access_token: \(backend_access_token)")
                                self.storeBackEndToken(token: backend_access_token)
                            }
                            else {
                                completion(CustomError.errorWithMessage(message: "invalid token data"))
                            }
                        }
                        else {
                            completion(CustomError.errorWithMessage(message: "invalid token data"))
                        }
                    }
                    catch {
                        print(error)
                        completion(error)
                    }
                    
                case .failure(let error):
                    print(error)
                    completion(error)
                }
                
            })
        }
        else {
            print("🔥🔥🔥 can't get the backend token, without having a valid edge token")
            completion(CustomError.errorWithMessage(message: "can't get the backend token, without having a valid edge token"))
        }
    }
    
    func scopesForEdgeAuthToken(action: AuthStateActionType) -> [String] {
        switch action {
        case .login:
            return ["openid", "edge:mcm", "edge:clusters", "edge:account:associate"]
        case .reset:
            return ["openid" , "edge:account:unassociate"]
        }
    }
    
    func memorizeEdgeAuthState(authState: OIDAuthState) {
        
        if !self.accountIdSameAsCurrentUser(authState: authState) && self.authStateEdge != nil {
            print("different account's credentials coming in, IGNORING")
            return
        }
        
        self.authStateEdge = authState
        self.authStateEdge?.stateChangeDelegate = self
        self.saveEdgeAuthStateToUserDefaults(authState: authState)
    }
    
    func saveEdgeAuthStateToUserDefaults(authState: OIDAuthState) {
        
        let data: Data = NSKeyedArchiver.archivedData(withRootObject: authState)
        UserDefaults.standard.set(data, forKey: self.kAuthStateEdgeKey)
        UserDefaults.standard.synchronize()
    }
    
    func loadAuthState(type: AuthStateType) {
        
        guard let data = UserDefaults.standard.object(forKey: self.kAuthStateEdgeKey) as? Data else {
            return
        }
        
        if let authState = NSKeyedUnarchiver.unarchiveObject(with: data) as? OIDAuthState {
            self.memorizeEdgeAuthState(authState: authState)
        }
    }
    
    func accountIdFrom(authState: OIDAuthState) -> String? {
        var accountIdDecoded: String?
        
        if !self.isAuthorized(type: .edge) {
            return nil
        }
        
        do {
            let idTokenDecoded = try decode(jwt: (authState.lastTokenResponse?.idToken)!)
            let idTokenJson = JSON.init(idTokenDecoded.body)
            if idTokenJson != JSON.null {
                accountIdDecoded = idTokenJson["sub"].stringValue
            }
        }
        catch {
            return nil
        }
        
        return accountIdDecoded
    }
    
    func accountIdSameAsCurrentUser(authState: OIDAuthState) -> Bool {
        let currentAccountId = self.accountId()
        let incomingAccountId = self.accountIdFrom(authState: authState)
        return currentAccountId == incomingAccountId
    }
    
    func storeBackEndToken (token: String) -> Void {
        UserDefaults.standard.set(token, forKey: kBackEndTokenKey)
        UserDefaults.standard.synchronize()
    }
    
    func restoreBackEndToken () -> String? {
        
        if !self.isAuthorized(type: .backend) {
            return nil
        }
        
        return UserDefaults.standard.string(forKey: kBackEndTokenKey)
    }
    
    func clearEdgeToken() -> Void {
        UserDefaults.standard.removeObject(forKey: kAuthStateEdgeKey)
        UserDefaults.standard.synchronize()
        self.authStateEdge = nil
    }
    
    func clearBackEndToken() -> Void {
        UserDefaults.standard.removeObject(forKey: kBackEndTokenKey)
        UserDefaults.standard.synchronize()
    }
}

//MARK: OIDAuthState Delegate
extension MMKAuthenticationManager: OIDAuthStateChangeDelegate, OIDAuthStateErrorDelegate {
    public func didChange(_ state: OIDAuthState) {
    }
    
    public func authState(_ state: OIDAuthState, didEncounterAuthorizationError error: Error) {
    }
}

public enum CustomError: Error {
    case errorWithGenericMessage
    case errorWithMessage(message: String)
}

extension CustomError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .errorWithGenericMessage:
            return NSLocalizedString("Error occured.", comment: "CustomError")
        case .errorWithMessage(let message):
            return NSLocalizedString(message, comment: "CustomError")
        }
    }
}
