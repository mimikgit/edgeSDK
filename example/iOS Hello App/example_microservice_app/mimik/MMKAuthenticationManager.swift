//
//  MMKAuthenticationManager.swift
//  example_microservice_app
//
//  Created by Raduz Benicky on 2018-03-06.
//  Copyright © 2018 mimik. All rights reserved.
//

import edgeSDK_iOS
import edgeSDK_iOS_app_auth

final public class MMKAuthenticationManager: NSObject {
    
    /**
     A singleton shared instance.
     */
    public static let sharedInstance = MMKAuthenticationManager()

    let kEdgeIdTokenKey: String = "com.mimik.exampleapp.kEdgeIdTokenKey"
    let kAccessTokenKey: String = "com.mimik.exampleapp.kAccessTokenKey"
    let kAuthStatusKey: String = "com.mimik.exampleapp.kAuthStatusKey"
    public var edgeConfig: MMKEdgeConfig?
    var savedAuthStatusData: Data?
    
    /**
     enum of potential token types.
     */
    public enum AuthTokenType: String {
        case accessToken = "accessToken"
        case edgeIdToken = "edgeIdToken"
    }
    
    /**
     enum of potential authentication actions.
     */
    public enum AuthStateActionType: String {
        case login = "login"
        case reset = "reset"
    }
    
    private override init() {
        super.init()
    }
}

public extension MMKAuthenticationManager {
    
    /**
     Saves AuthStatus to memory as encoded data.
     */
    func saveAuthStatus(status: MMKAuthStatus) -> Void {
        let codedAuthStatus = NSKeyedArchiver.archivedData(withRootObject: status as MMKAuthStatus)
        self.savedAuthStatusData = codedAuthStatus
    }

    /**
     Recreates AuthStatus object from memory where it was stored as encoded data.
     */
    func loadAuthStatus() -> MMKAuthStatus? {
        if let authStatusData = self.savedAuthStatusData,
            let unarchivedAuthStatus = NSKeyedUnarchiver.unarchiveObject(with: authStatusData) as? MMKAuthStatus {
            return unarchivedAuthStatus
        }
        
        return nil
    }
    
    /**
     Forgets the AuthStatus object stored in memory.
     */
    func clearAuthStatus() -> Void {
        self.savedAuthStatusData = nil
    }
    
    /**
     Returns a token of a specific type stored in memory.
     */
    func loadToken(type: AuthTokenType) -> String? {
        
        guard let authStatus = self.loadAuthStatus() else {
            return nil
        }
        
        switch type {
        case .accessToken:
            return authStatus.accessToken
        case .edgeIdToken:
            return authStatus.idToken
        }
    }
}
