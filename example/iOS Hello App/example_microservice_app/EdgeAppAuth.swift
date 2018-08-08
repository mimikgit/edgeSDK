//
//  EdgeAppAuth.swift
//  EdgeAppAuth
//
//  Created by Radúz Benický on 2018-06-29.
//  Copyright © 2018 mimik. All rights reserved.
//

//        1.  mID configuration will be discovered using OIDAuthorizationService.discoverConfiguration
//        2. JSONRPC connection will be attempted to get the edgeAccess token2. OIDAuthorizationRequest.init will be created with AuthConfig
//        3. response will be parsed
//        4. edge account association
//        5. completion block will be called with AuthResponse (AuthStatus, AuthError?)

import UIKit
import AppAuth

enum AuthAction: String {
    case authorize = "authorize"
    case unauthorize = "unauthorize"
}

public struct AuthConfig {
    var clientId: String
    var redirectUrl: URL
    var additionalScopes: [String]?
    var authorizationRootUrl:  URL?
}

public struct AuthStatus {
    var accessToken: String  // edge token
    var idToken: String // part of the edge token response, used for user profile information
    var refreshToken: String?
    var accessTokenExpirationDate: Date
}

public class EdgeAppAuth: NSObject {
    
    fileprivate var jsonRPCRequest: JsonRPCRequest?
    fileprivate var currentAuthorizationFlow: OIDAuthorizationFlowSession?
    
    //
    // initiates the OID login process in a SFAuthenticationSession (called internally by the AppAuth library)
    // https://openid.github.io/AppAuth-iOS/
    // https://developer.apple.com/documentation/safariservices/sfauthenticationsession
    //
    public func authorize(authConfig: AuthConfig, viewController: UIViewController, completion: @escaping ((status: AuthStatus?, error: Error?)) -> Void) {
        self.authorizationAction(action: AuthAction.authorize, authConfig: authConfig, viewController: viewController, completion: completion)
    }
    
    public func unauthorize(authConfig: AuthConfig, viewController: UIViewController, completion: @escaping ((status: AuthStatus?, error: Error?)) -> Void) {
        self.authorizationAction(action: AuthAction.unauthorize, authConfig: authConfig, viewController: viewController, completion: completion)
    }
    
    @available(*, unavailable) func refreshToken(authConfig: AuthConfig, viewController: UIViewController, completion: @escaping ((AuthStatus?, error: Error?)) -> Void) {
        
    }
}

private extension EdgeAppAuth {
    func authorizationAction(action: AuthAction, authConfig: AuthConfig, viewController: UIViewController, completion: @escaping ((status: AuthStatus?, error: Error?)) -> Void)  {
        self.getEdgeIdToken { (edgeIdToken,error) in
            
            guard error == nil else {
                completion((nil, error))
                return
            }
            
            guard let verifiedEdgeIdToken = edgeIdToken else {
                completion((nil, NSError.init(domain: "Invalid edgeIdToken", code: 500, userInfo: nil)))
                return
            }
            
            self.getAccessToken(authConfig: authConfig, action: action, viewController: viewController, edgeIdToken: verifiedEdgeIdToken, completion: { (authResponse) in
                
                guard authResponse.error == nil else {
                    completion((nil, error))
                    return
                }
                
                guard let verifiedAccessToken = authResponse.status?.accessToken else {
                    completion((nil, NSError.init(domain: "Invalid edgeIdToken", code: 500, userInfo: nil)))
                    return
                }
                
                //
                // initiates edgeSDK account association process via a JSON-RPC protocol through a WebSocket connection to the edgeSDK instance
                //
                
                self.accountAction(action: action, accessToken: verifiedAccessToken, completion: { (associationResponse) in
                    
                    guard associationResponse.error == nil else {
                        completion((nil, error))
                        return
                    }
                    
                    completion(authResponse)
                })
            })
        }
    }
    
    func getEdgeIdToken(completion: @escaping ((result: String?, error: Error?)) -> Void) {
        self.jsonRPCRequest = JsonRPCRequest.init(method: .getEdgeIdToken, parameters: nil, completion: { (response) in
            completion(response)
            self.jsonRPCRequest = nil
        })
    }
    
    func accountAction(action: AuthAction, accessToken: String, completion: @escaping ((result: String?, error: Error?)) -> Void) {
        
        guard !accessToken.isEmpty else {
            completion((nil, NSError.init(domain: "Invalid accessToken", code: 500, userInfo: nil)))
            return
        }
        
        self.jsonRPCRequest = JsonRPCRequest.init(method: self.methodForAction(action: action), parameters: [accessToken], completion: { (response) in
            completion(response)
            self.jsonRPCRequest = nil
        })
    }
    
    func methodForAction(action: AuthAction) -> JsonRPCRequest.JsonRPCMethod {
        switch action {
        case .authorize:
            return .associateAccount
        case .unauthorize:
            return .unassociateAccount
        }
    }
    
    func getAccessToken(authConfig: AuthConfig, action: AuthAction, viewController: UIViewController, edgeIdToken:String, completion: @escaping ((status: AuthStatus?, error: Error?)) -> Void) {
        
        guard !edgeIdToken.isEmpty else {
            completion((nil, NSError.init(domain: "Invalid edgeIdToken", code: 500, userInfo: nil)))
            return
        }
        
        guard let verifiedAuthorizationRootURL =  self.determineAuthorizationRootURL(authConfig: authConfig) else {
            completion((nil, NSError.init(domain: "Invalid AuthorizationRootURL", code: 500, userInfo: nil)))
            return
        }
        
        guard let verifiedRedirectURL =  self.determineRedirectURL(authConfig: authConfig) else {
            completion((nil, NSError.init(domain: "Invalid RedirectURL", code: 500, userInfo: nil)))
            return
        }
        
        let verifiedClientId = authConfig.clientId
        guard !verifiedClientId.isEmpty else {
            completion((nil, NSError.init(domain: "Invalid ClientId", code: 500, userInfo: nil)))
            return
        }
        
        let verifiedScopes = self.determineScopes(action: action, authConfig: authConfig)
        guard !verifiedScopes.isEmpty else {
            completion((nil, NSError.init(domain: "Invalid Scopes", code: 500, userInfo: nil)))
            return
        }
        
        OIDAuthorizationService.discoverConfiguration(forIssuer: verifiedAuthorizationRootURL, completion: { (configuration, error) in
            
            guard let verifiedConfiguration = configuration else {
                completion((nil, NSError.init(domain: "Invalid configuration", code: 500, userInfo: nil)))
                return
            }
            
            guard error == nil else {
                completion((nil, error))
                return
            }
            
            let additionalParameters: [String:String] = ["edge_id_token":edgeIdToken]
            
            let request: OIDAuthorizationRequest = OIDAuthorizationRequest.init(configuration: verifiedConfiguration,
                                                                                clientId: verifiedClientId,
                                                                                scopes: verifiedScopes,
                                                                                redirectURL: verifiedRedirectURL,
                                                                                responseType: OIDResponseTypeCode,
                                                                                additionalParameters: additionalParameters)
            
            self.currentAuthorizationFlow = OIDAuthState.authState(byPresenting: request, presenting: viewController) { authState, error in
                
                let status = self.parseAuthState(authState: authState, error: error)
                completion(status)
            }
        })
    }
    
    func parseAuthState(authState: OIDAuthState?, error: Error?) -> (AuthStatus?, Error?) {
        
        guard error == nil else {
            return ((nil, error))
        }
        
        guard let checkedTokenResponse = authState?.lastTokenResponse else {
            return (nil, NSError.init(domain: "Invalid lastTokenResponse", code: 500, userInfo: nil))
        }
        
        guard let checkedAccessToken = checkedTokenResponse.accessToken else {
            return (nil, NSError.init(domain: "Invalid accessToken", code: 500, userInfo: nil))
        }

        guard let checkedIdToken = checkedTokenResponse.idToken else {
            return (nil, NSError.init(domain: "Invalid idToken", code: 500, userInfo: nil))
        }

        guard let checkedAccessTokenExpirationDate = checkedTokenResponse.accessTokenExpirationDate else {
            return (nil, NSError.init(domain: "Invalid accessTokenExpirationDate", code: 500, userInfo: nil))
        }

        let authStatus = AuthStatus.init(accessToken: checkedAccessToken, idToken: checkedIdToken, refreshToken: checkedTokenResponse.refreshToken, accessTokenExpirationDate: checkedAccessTokenExpirationDate)
        return (authStatus, authState?.authorizationError)
    }
    
    func determineAuthorizationRootURL(authConfig: AuthConfig) -> URL? {
        let kDefaultAuthorizationRoot: String = "https://mid.mimik360.com"
        var authorizationRootURL: URL?
        guard let kDefaultAuthorizationRootURL: URL = URL.init(string: kDefaultAuthorizationRoot) else {
            return nil
        }
        authorizationRootURL = kDefaultAuthorizationRootURL
        
        if let customAuthorizationRootURL = authConfig.authorizationRootUrl {
            authorizationRootURL = customAuthorizationRootURL
        }
        
        return authorizationRootURL
    }
    
    func determineRedirectURL(authConfig: AuthConfig) -> URL? {
        var redirectURL: URL?
        
        if !authConfig.redirectUrl.absoluteString.isEmpty {
            redirectURL = authConfig.redirectUrl
        }
        
        return redirectURL
    }
    
    func determineScopes(action: AuthAction, authConfig: AuthConfig) -> [String] {
        var scopes: [String] = self.defaultScopes(action: action)
        
        if let additionalScopes = authConfig.additionalScopes {
            scopes.append(contentsOf: additionalScopes)
        }
        
        return scopes
    }
    
    func defaultScopes(action: AuthAction) -> [String] {
        switch action {
        case .authorize:
            return ["openid", "edge:mcm", "edge:clusters", "edge:account:associate"]
        case .unauthorize:
            return ["openid" , "edge:account:unassociate"]
        }
    }
}
