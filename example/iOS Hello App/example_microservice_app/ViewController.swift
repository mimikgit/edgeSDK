//
//  ViewController.swift
//  example_microservice_app
//
//  Created by Raduz Benicky on 2018-01-25.
//  Copyright © 2018 mimik. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import edgeSDK_iOS
import edgeSDK_iOS_app_auth
import edgeSDK_iOS_app_ops
import os.log

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var edgeNodes: [MMKEdgeNode] = []
    var appAuthWrapper:  edgeSDK_iOS_app_auth?
    var appOpsWrapper:  edgeSDK_iOS_app_ops?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var button01: UIButton!
    @IBOutlet weak var button02: UIButton!
    @IBOutlet weak var button03: UIButton!
    @IBOutlet weak var button04: UIButton!
    @IBOutlet weak var button05: UIButton!
    @IBOutlet weak var button06: UIButton!
    @IBOutlet weak var button07: UIButton!
    @IBOutlet weak var button08: UIButton!
    @IBOutlet weak var button09: UIButton!
    @IBOutlet weak var bottomInfoLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.button01.isEnabled = true
        self.button01.setTitle("StartEdge", for: UIControlState.normal)
        self.button01.setTitle("StartEdge", for: UIControlState.disabled)

        self.button02.isEnabled = true
        self.button02.setTitle("Authorize", for: UIControlState.normal)
        self.button02.setTitle("Authorize", for: UIControlState.disabled)
        
        self.button03.isEnabled = true
        self.button03.setTitle("Deploy", for: UIControlState.normal)
        self.button03.setTitle("Deploy", for: UIControlState.disabled)
        
        self.button04.isEnabled = true
        self.button04.setTitle("GetNetwork", for: UIControlState.normal)
        self.button04.setTitle("GetNetwork", for: UIControlState.disabled)

        self.button05.isEnabled = true
        self.button05.setTitle("GetNearby", for: UIControlState.normal)
        self.button05.setTitle("GetNearby", for: UIControlState.disabled)

        self.button06.isEnabled = true
        self.button06.setTitle("Remove", for: UIControlState.normal)
        self.button06.setTitle("Remove", for: UIControlState.disabled)

        self.button07.isEnabled = true
        self.button07.setTitle("Info", for: UIControlState.normal)
        self.button07.setTitle("Info", for: UIControlState.disabled)
        
        self.button08.isEnabled = true
        self.button08.setTitle("UnAuthorize", for: UIControlState.normal)
        self.button08.setTitle("UnAuthorize", for: UIControlState.disabled)
        
        self.button09.isEnabled = true
        self.button09.setTitle("StopEdge", for: UIControlState.normal)
        self.button09.setTitle("StopEdge", for: UIControlState.disabled)
        
        self.bottomInfoLabel.text = "Ready"
        
        self.setupLoggingLevels()
    }
    
    /**
     Sets up logging levels for various modules and logs several test logging messages.
     */
    func setupLoggingLevels() -> Void {
        
        // This application's logging level
        MMKLog.changeLoggingLevelTo(level: .debug, subsystem: .edgeSDK_iOS_example)
        
        // Two ways of setting the edgeSDK-iOS framework's logging level. They accomplish the same thing.
        edgeSDK_iOS.changeLoggingLevelTo(level: .info)
        MMKLog.changeLoggingLevelTo(level: .info, subsystem: .edgeSDK_iOS)
        
        // Two ways of setting the edgeSDK-iOS-app-ops framework's logging level. They accomplish the same thing.
        edgeSDK_iOS_app_ops.changeLoggingLevelTo(level: .info)
        MMKLog.changeLoggingLevelTo(level: .info, subsystem: .edgeSDK_iOS_app_ops)
        
        // Two ways of setting the edgeSDK-iOS-app-auth framework's logging level. They accomplish the same thing.
        edgeSDK_iOS_app_auth.changeLoggingLevelTo(level: .info)
        MMKLog.changeLoggingLevelTo(level: .info, subsystem: .edgeSDK_iOS_app_auth)
        
        // Other mimik module, for illustration purposes only
        MMKLog.changeLoggingLevelTo(level: .info, subsystem: .edgeSDK_iOS_access)
        
        // Examples of logging messages in different categories
        MMKLog.log(message: "example logging .info", type: .info, subsystem: .edgeSDK_iOS_example)
        MMKLog.log(message: "example logging .error", type: .error, subsystem: .edgeSDK_iOS_example)
        MMKLog.log(message: "example logging .debug", type: .debug, subsystem: .edgeSDK_iOS_example)
        MMKLog.log(message: "example logging .fault", type: .fault, subsystem: .edgeSDK_iOS_example)
    }
    
    /**
     initiates the edgeSDK startup sequence
     MMKEdgeManager singleton class holds a reference to the edgeProvider instance after initialization
     */
    @IBAction func button01Action(_ sender: UIButton) {
        
        self.buttonsEnabled(enabled: false)
        self.bottomInfoLabel.text = "registerLifecycle called"
        
        if self.appOpsWrapper == nil {
            self.appOpsWrapper = edgeSDK_iOS_app_ops.init()
        }
        
        guard let appOpsWrapper = self.appOpsWrapper else {
            fatalError()
        }
        
        let edge_nodeId: String = UIDevice.current.name.contains("iPad") ? "iPad-UUID-12345678" : "iPhone-UUID-12345678"
        appOpsWrapper.startEdge(nodeId: edge_nodeId, delegate: self, completion: { (status,error) in
            
            appOpsWrapper.getConfig({ (result,error) in
                MMKAuthenticationManager.sharedInstance.edgeConfig = result
                MMKLog.log(message: "edgeConfig: ", type: .info, value: "\(MMKAuthenticationManager.sharedInstance.edgeConfig!)", subsystem: .edgeSDK_iOS_example)
            })
            
            DispatchQueue.main.async {
                guard error == nil else {
                    MMKLog.log(message: "startEdge error: ", type: . error, value: "\(error?.localizedDescription ?? "no-error")", subsystem: .edgeSDK_iOS_example)
                    self.bottomInfoLabel.text = "edge failed to start: \(error?.localizedDescription ?? "no-error")"
                    self.buttonsEnabled(enabled: true)
                    return
                }
                
                self.bottomInfoLabel.text = "edgeSDK is running. lifecycle listener registered."
                self.buttonsEnabled(enabled: true)
            }
        })
    }
    
    /**
     Starts the authentication session.
     */
    @IBAction func button02Action(_ sender: UIButton) {
        self.buttonsEnabled(enabled: false)
        self.bottomInfoLabel.text = "OID login is in progress..."
        
        if self.appAuthWrapper == nil {
            self.appAuthWrapper = edgeSDK_iOS_app_auth.init()
        }
        
        guard let appAuthWrapper = self.appAuthWrapper else {
            fatalError()
        }
        
        //
        // this is where you'd put your own application id from the developer portal
        // for now we'll use mimik's internal registration id for this example application
        //
        let kClientId: String = "fe6b7dca-a3ac-427e-a5c0-c0f0523c5baa"
        let kRedirectURL: URL = URL.init(string: "com.exampleapp://example-authorization-code")!
        
        let authConfig = AuthConfig.init(clientId: kClientId, redirectUrl: kRedirectURL, additionalScopes: nil, authorizationRootUrl: nil)
        appAuthWrapper.authorize(authConfig: authConfig, viewController: self, completion: { (status, error) in
            
            DispatchQueue.main.async {
                guard error == nil else {
                    MMKLog.log(message: "Authorization finished with an error: ", type: . error, value: "\(error?.localizedDescription ?? "no-error")", subsystem: .edgeSDK_iOS_example)
                    self.bottomInfoLabel.text = "Authorization finished with an error: \(error?.localizedDescription ?? "no-error")"
                    MMKAuthenticationManager.sharedInstance.clearAuthStatus()
                    self.buttonsEnabled(enabled: true)
                    return
                }
                
                guard status != nil else {
                    MMKLog.log(message: "Authorization finished with an error", type: .error, subsystem: .edgeSDK_iOS_example)
                    self.bottomInfoLabel.text = "Authorization finished with an error"
                    MMKAuthenticationManager.sharedInstance.clearAuthStatus()
                    self.buttonsEnabled(enabled: true)
                    return
                }
                
                MMKAuthenticationManager.sharedInstance.saveAuthStatus(status: status!)
                MMKLog.log(message: "Authorization finished successfully. accessToken: ", type: .info, value: "\(status?.accessToken ?? "no-token")", subsystem: .edgeSDK_iOS_example)
                self.bottomInfoLabel.text = "Authorization finished successfully."
                self.buttonsEnabled(enabled: true)
            }
        })
    }
    
    /**
     initiates the example micro service loading process by uploading the content via a edgeSDK service URL
     */
    @IBAction func button03Action(_ sender: UIButton) {
        
        self.buttonsEnabled(enabled: false)
        self.bottomInfoLabel.text = "deploying the example micro service..."
        
        if self.appOpsWrapper == nil {
            self.appOpsWrapper = edgeSDK_iOS_app_ops.init()
        }
        
        guard let appOpsWrapper = self.appOpsWrapper else {
            fatalError()
        }
        
        guard let edgeAccessToken = MMKAuthenticationManager.sharedInstance.loadToken(type: .accessToken) else {
            self.bottomInfoLabel.text = "edgeSDK failed to deploy the example micro service: Missing edgeAccessToken token"
            self.buttonsEnabled(enabled: true)
            return
        }
        
        let config: MicroserviceDeploymentConfig = self.microserviceConfig()
        appOpsWrapper.deployMicroservice(edgeAccessToken: edgeAccessToken, config: config) { (status,error) in
            
            DispatchQueue.main.async {
                guard error == nil else {
                    MMKLog.log(message: "deployEdgeMicroservice error: ", type: . error, value: "\(error?.localizedDescription ?? "no-error")", subsystem: .edgeSDK_iOS_example)
                    self.bottomInfoLabel.text = "edgeSDK failed to deploy the example micro service: \(error?.localizedDescription ?? "no-error")"
                    self.buttonsEnabled(enabled: true)
                    return
                }
                
                MMKLog.log(message: "deployEdgeMicroservice status ok", type: . info, subsystem: .edgeSDK_iOS_example)
                self.bottomInfoLabel.text = "edgeSDK deployed the example micro service"
                self.buttonsEnabled(enabled: true)
            }
        }
    }
    
    /**
     initiates a "getNetwork" API call that returns a list of edge nodes visible on the local network
     */
    @IBAction func button04Action(_ sender: UIButton) {
        
        self.buttonsEnabled(enabled: false)
        self.edgeNodes.removeAll()
        self.tableView.reloadData()
        self.bottomInfoLabel.text = "Calling getNetwork"
        
        MMKGetManager.getNodes(type: .network, completion: { (nodes, error) in
            
            guard error == nil else {
                self.tableView.reloadData()
                self.bottomInfoLabel.text = error?.localizedDescription
                sender.isEnabled = true
                self.buttonsEnabled(enabled: true)
                return
            }
            
            guard nodes != nil else {
                self.tableView.reloadData()
                self.bottomInfoLabel.text = "Unable to process the response"
                sender.isEnabled = true
                self.buttonsEnabled(enabled: true)
                return
            }
            
            sender.isEnabled = true
            self.edgeNodes = nodes!
            self.tableView.reloadData()

            let nodeString: String = self.edgeNodes.count == 1 ? "node" : "nodes"
            self.bottomInfoLabel.text = "Received information about \(self.edgeNodes.count) \(nodeString)"
            self.buttonsEnabled(enabled: true)
        })
    }
    
    /**
     initiates a "getNearby" API call that returns a list of edge nodes visible across all networks considered within a "proximity" distance
     */
    @IBAction func button05Action(_ sender: UIButton) {
        
        self.buttonsEnabled(enabled: false)
        self.edgeNodes.removeAll()
        self.tableView.reloadData()
        self.bottomInfoLabel.text = "Calling getNearby"
        
        MMKGetManager.getNodes(type: .nearby, completion: { (nodes, error) in
            
            guard error == nil else {
                self.tableView.reloadData()
                self.bottomInfoLabel.text = error?.localizedDescription
                sender.isEnabled = true
                self.buttonsEnabled(enabled: true)
                return
            }
            
            guard nodes != nil else {
                self.tableView.reloadData()
                self.bottomInfoLabel.text = "Unable to process the response"
                sender.isEnabled = true
                self.buttonsEnabled(enabled: true)
                return
            }

            sender.isEnabled = true
            self.edgeNodes = nodes!
            self.tableView.reloadData()
            
            let nodeString: String = self.edgeNodes.count == 1 ? "node" : "nodes"
            self.bottomInfoLabel.text = "Received information about \(self.edgeNodes.count) \(nodeString)"
            self.buttonsEnabled(enabled: true)
        })
    }
    
    /**
     Removes deployed micro services.
     */
    @IBAction func button06Action(_ sender: UIButton) {

        sender.isEnabled = false
        
        if self.appOpsWrapper == nil {
            self.appOpsWrapper = edgeSDK_iOS_app_ops.init()
        }
        
        guard let appOpsWrapper = self.appOpsWrapper else {
            fatalError()
        }
        
        guard let edgeAccessToken = MMKAuthenticationManager.sharedInstance.loadToken(type: .accessToken) else {
            self.bottomInfoLabel.text = "edgeSDK failed to remove the example micro service: Missing edgeAccessToken token"
            self.buttonsEnabled(enabled: true)
            return
        }
        
        let config: MicroserviceDeploymentConfig = self.microserviceConfig()
        appOpsWrapper.removeMicroservice(edgeAccessToken: edgeAccessToken, config: config) { (status,error) in

            DispatchQueue.main.async {
                guard error == nil else {
                    MMKLog.log(message: "deployEdgeMicroservice error: ", type: . error, value: "\(error?.localizedDescription ?? "no-error")", subsystem: .edgeSDK_iOS_example)
                    self.bottomInfoLabel.text = "edgeSDK failed to remove the example micro service: \(error?.localizedDescription ?? "no-error")"
                    self.buttonsEnabled(enabled: true)
                    return
                }
                
                MMKLog.log(message: "deployEdgeMicroservice status ok", type: . info, subsystem: .edgeSDK_iOS_example)
                self.bottomInfoLabel.text = "edgeSDK removed the example micro service"
                self.buttonsEnabled(enabled: true)
            }
        }
    }
    
    /**
     Combines several get info calls into one.
     */
    @IBAction func button07Action(_ sender: UIButton) {
        
        self.buttonsEnabled(enabled: false)
        
        guard MMKAuthenticationManager.sharedInstance.loadToken(type: .accessToken) != nil else {
            self.bottomInfoLabel.text = "edgeSDK failed to get debug information: Missing edgeAccessToken token"
            self.buttonsEnabled(enabled: true)
            return
        }
        
        self.getCombinedDebugInfo { (debugInfo,error) in
            
            guard debugInfo != nil, !(debugInfo?.isEmpty)! else {
                self.bottomInfoLabel.text = "getCombinedDebugInfo finished empty. maybe edgeSDK is not running?"
                self.buttonsEnabled(enabled: true)
                return
            }
            
            DispatchQueue.main.async {
                let alertVC = UIAlertController.init(title: "Debug Info", message: debugInfo, preferredStyle: .alert)
                let okAction = UIAlertAction.init(title: "OK", style: .default, handler: nil)
                
                alertVC.addAction(okAction)
                self.present(alertVC, animated: true, completion: {
                    self.bottomInfoLabel.text = "getCombinedDebugInfo finished."
                    self.buttonsEnabled(enabled: true)
                })
            }
        }
    }
    
    /**
     Initiates unautorization session.
     */
    @IBAction func button08Action(_ sender: UIButton) {
        self.buttonsEnabled(enabled: false)
        self.bottomInfoLabel.text = "OID unauthorize is in progress..."
        
        if self.appAuthWrapper == nil {
            self.appAuthWrapper = edgeSDK_iOS_app_auth.init()
        }
        
        guard let appAuthWrapper = self.appAuthWrapper else {
            fatalError()
        }
        
        //
        // this is where you'd put your own application id from the developer portal (https://developers-stg.mimik360.com)
        // for now we'll use mimik's internal registration id for this example application
        //
        let kClientId: String = "fe6b7dca-a3ac-427e-a5c0-c0f0523c5baa"
        let kRedirectURL: URL = URL.init(string: "com.exampleapp://example-authorization-code")!
        
        let authConfig = AuthConfig.init(clientId: kClientId, redirectUrl: kRedirectURL, additionalScopes: nil, authorizationRootUrl: nil)
        
        appAuthWrapper.unauthorize(authConfig: authConfig, viewController: self) { (status,error) in
         
            DispatchQueue.main.async {
                guard error == nil else {
                    MMKLog.log(message: "auth status error: ", type: . error, value: "\(String(describing: error))", subsystem: .edgeSDK_iOS_example)
                    self.bottomInfoLabel.text = "OID unauthorize finished with error: \(error?.localizedDescription ?? "no-error")"
                    self.buttonsEnabled(enabled: true)
                    return
                }
                
                guard status != nil else {
                    MMKLog.log(message: "auth status unknown error", type: .error, subsystem: .edgeSDK_iOS_example)
                    self.bottomInfoLabel.text = "OID unauthorize finished with an unknown error"
                    MMKAuthenticationManager.sharedInstance.clearAuthStatus()
                    self.buttonsEnabled(enabled: true)
                    return
                }
                
                MMKAuthenticationManager.sharedInstance.clearAuthStatus()
                self.bottomInfoLabel.text = "OID unauthorize finished successfully."
                self.buttonsEnabled(enabled: true)
            }
        }
    }
    
    /**
     initiates the edgeSDK shutdown procedure
     */
    @IBAction func button09Action(_ sender: UIButton) {

        self.buttonsEnabled(enabled: false)
        self.bottomInfoLabel.text = "unregisterLifecycle called"
        
        if self.appOpsWrapper == nil {
            self.appOpsWrapper = edgeSDK_iOS_app_ops.init()
        }
        
        guard let appOpsWrapper = self.appOpsWrapper else {
            fatalError()
        }
        
        appOpsWrapper.stopEdge(completion: { (status,error) in
            
            DispatchQueue.main.async {
                guard error == nil else {
                    MMKLog.log(message: "stopEdge error: ", type: . error, value: "\(error?.localizedDescription ?? "no-error")", subsystem: .edgeSDK_iOS_example)
                    self.bottomInfoLabel.text = "edge failed to stop: \(error?.localizedDescription ?? "no-error")"
                    self.buttonsEnabled(enabled: true)
                    return
                }
                
                self.bottomInfoLabel.text = "edgeSDK is stopped. lifecycle listener unregistered"
                self.buttonsEnabled(enabled: true)
            }
        })
    }
    
    /**
     Toggles UI buttons between enabled and disabled.
     */
    func buttonsEnabled(enabled: Bool) -> Void {
        DispatchQueue.main.async {
            self.button01.isEnabled = enabled
            self.button02.isEnabled = enabled
            self.button03.isEnabled = enabled
            self.button04.isEnabled = enabled
            self.button05.isEnabled = enabled
            self.button06.isEnabled = enabled
            self.button07.isEnabled = enabled
            self.button08.isEnabled = enabled
            self.button09.isEnabled = enabled
        }
    }
}

internal extension ViewController {
    
    /**
     Determines which edgeSDK node has been selected, then gets a url to it and initiates a hello endpoint call on it.
     */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let node = self.edgeNodes[indexPath.row]
        self.bottomInfoLabel.text = "Connecting to node: \(node.displayName()), please wait for a response."
        
        node.getBEPURL { (url, error) in
            let updatedNode: MMKEdgeNode = node
            
            if let checkedUrl = url {
                
                updatedNode.urlString = checkedUrl.absoluteString
                self.bottomInfoLabel.text = "Calling hello endpoint on node: \(node.urlString ?? "no-url-detected"), please wait for a response."
                
                MMKGetManager.getHelloResponse(node: node, completion: { (json,error) in
                    
                    guard error == nil else {
                        self.tableView.reloadData()
                        self.bottomInfoLabel.text = error?.localizedDescription
                        return
                    }
                    
                    guard json != nil else {
                        self.tableView.reloadData()
                        self.bottomInfoLabel.text = "Unable to process the response"
                        return
                    }
                    
                    self.bottomInfoLabel.text = "\(json!["JSONMessage"]) received from \(node.displayName())"
                    MMKLog.log(message: "hello response from node: ", type: .info, value: "\(node.urlString ?? "no-url-detected") json: \(json ?? JSON())", subsystem: .edgeSDK_iOS_example)
                })
                
            }
            else if let checkedError = error {
                self.bottomInfoLabel.text = checkedError.localizedDescription
            }
            else {
                self.bottomInfoLabel.text = "An unknown error occured"
            }
        }
    }
    
    /**
     Number of edgeSDK nodes for the table
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.edgeNodes.count
    }
    
    /**
     Prepares the UI for each cell.
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "NodeCell")!
        let node = self.edgeNodes[indexPath.row]
        
        cell.textLabel?.text = "name: " + node.displayName()
        cell.detailTextLabel?.text = "id:   "+node.id! + "\nos: \(node.os ?? "")" + "\nurl: \(node.urlString ?? "external network")"
        return cell
    }
}

extension ViewController {
    
    /**
     This is where the .tar micro service is stored in the application's bundle
     */
    func microServiceBundleStorageURL(name: String) -> URL? {
        let microServiceFileName = self.microServiceTarFileName(name: name, withExtension: false)
        guard let microServiceBundlePath = Bundle.main.path(forResource: microServiceFileName, ofType: ".tar") else {
            return nil
        }
        
        let fileURL = URL.init(fileURLWithPath: microServiceBundlePath)
        return fileURL
    }
    
    /**
     File name for each micro service tar file.
     */
    func microServiceTarFileName(name: String, withExtension: Bool) -> String {
        return withExtension == true ? name+".tar":name
    }
    
    /**
     A configuration object for each micro service.
     */
    func microserviceConfig() -> MicroserviceDeploymentConfig {
        
        guard let imageUrl = self.microServiceBundleStorageURL(name: "example-v1") else {
            fatalError()
        }
        
        let envVariables: [String:String] = [
            "BEAM": kEdgeServiceLink+"/beam/v1",
            "uMDS": kEdgeServiceLink+"/mds/v1"
        ]
        
        return MicroserviceDeploymentConfig.init(name: "example-v1", apiRootUrl: "/example-v1/v1", imagePath: imageUrl.path, envVariables: envVariables)
    }
    
    /**
     Combined debug information.
     */
    func getCombinedDebugInfo(_ completion: @escaping ((response: String?, error: Error?)) -> Void) {
        if self.appOpsWrapper == nil {
            self.appOpsWrapper = edgeSDK_iOS_app_ops.init()
        }
        
        guard let appOpsWrapper = self.appOpsWrapper else {
            fatalError()
        }
        
        guard let edgeAccessToken = MMKAuthenticationManager.sharedInstance.loadToken(type: .accessToken) else {
            completion((nil,NSError.init(domain: "Missing edgeAccessToken", code: 500, userInfo: nil)))
            return
        }
        

        var debugInfo: String = ""
        
        appOpsWrapper.getDeployedImages(edgeAccessToken: edgeAccessToken) { (images,imagesError) in
            
            if imagesError == nil {
                let imagesJson = JSON.init(images)
                debugInfo += "getDeployedImages:\n"
                debugInfo += imagesJson.rawString(String.Encoding.utf8, options: JSONSerialization.WritingOptions.prettyPrinted)!+"\n\n"
            }
            
            appOpsWrapper.getDeployedContainers(edgeAccessToken: edgeAccessToken) { (containers,containerError) in
                
                if containerError == nil {
                    let containersJson = JSON.init(containers)
                    debugInfo += "getDeployedContainers:\n"
                    debugInfo += containersJson.rawString(String.Encoding.utf8, options: JSONSerialization.WritingOptions.prettyPrinted)!+"\n\n"
                }
                
                appOpsWrapper.getConfig({ (edgeConfig,edgeConfigError) in
                    
                    if edgeConfig != nil && edgeConfigError == nil {
                        debugInfo += "getConfig:\n"
                        debugInfo += edgeConfig!.description+"\n\n"
                    }

                    appOpsWrapper.getInfo({ (edgeInfo,edgeInfoError) in
                        
                        if edgeInfo != nil && edgeInfoError == nil {
                            debugInfo += "getInfo:\n"
                            debugInfo += (edgeInfo?.description)!+"\n\n"
                            completion((debugInfo,nil))
                        }
                        else {
                            completion((debugInfo,nil))
                        }
                    })
                })
            }
        }
    }
}

/**
 EdgeAppOpsProtocol. Getting calls about edgeSDK state changes.
 */
extension ViewController: EdgeAppOpsProtocol {
    func edgeStatusChanged(status: EdgeStatus) {
        MMKLog.log(message: "EdgeAppOpsProtocol edgeStatusChanged. status.edgeState.rawValue: ", type: .info, value: "\(status.edgeState.rawValue) status.stateChangingEvent.rawValue: \(status.stateChangingEvent.rawValue)", subsystem: .edgeSDK_iOS_example)
        DispatchQueue.main.async {
            self.bottomInfoLabel.text = "status.edgeState.rawValue: \(status.edgeState.rawValue) status.stateChangingEvent.rawValue: \(status.stateChangingEvent.rawValue)"
        }
    }
}
