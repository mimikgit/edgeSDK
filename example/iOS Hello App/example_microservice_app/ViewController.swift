//
//  ViewController.swift
//  example_microservice_app
//
//  Created by Raduz Benicky on 2018-01-25.
//  Copyright © 2018 mimik. All rights reserved.
//

import UIKit
import Alamofire
import CoreLocation
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
    @IBOutlet weak var button10: UIButton!
    @IBOutlet weak var button11: UIButton!
    @IBOutlet weak var button12: UIButton!
    @IBOutlet weak var bottomInfoLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.button01.setTitle("StartEdge", for: UIControl.State.normal)
        self.button01.setTitle("StartEdge", for: UIControl.State.disabled)

        self.button02.setTitle("Authorize", for: UIControl.State.normal)
        self.button02.setTitle("Authorize", for: UIControl.State.disabled)
        
        self.button03.setTitle("Deploy", for: UIControl.State.normal)
        self.button03.setTitle("Deploy", for: UIControl.State.disabled)
        
        self.button04.setTitle("UpdateGPS", for: UIControl.State.normal)
        self.button04.setTitle("UpdateGPS", for: UIControl.State.disabled)
        
        self.button05.setTitle("GetNetwork", for: UIControl.State.normal)
        self.button05.setTitle("GetNetwork", for: UIControl.State.disabled)

        self.button06.setTitle("GetNearby", for: UIControl.State.normal)
        self.button06.setTitle("GetNearby", for: UIControl.State.disabled)

        self.button07.setTitle("Info", for: UIControl.State.normal)
        self.button07.setTitle("Info", for: UIControl.State.disabled)
        
        self.button08.setTitle("Remove", for: UIControl.State.normal)
        self.button08.setTitle("Remove", for: UIControl.State.disabled)
        
        self.button09.setTitle("UnAuthorize", for: UIControl.State.normal)
        self.button09.setTitle("UnAuthorize", for: UIControl.State.disabled)

        self.button10.setTitle("edgeIdToken", for: UIControl.State.normal)
        self.button10.setTitle("edgeIdToken", for: UIControl.State.disabled)

        self.button11.isEnabled = false
        self.button11.setTitle("n/a", for: UIControl.State.normal)
        self.button11.setTitle("n/a", for: UIControl.State.disabled)
        
        self.button12.setTitle("StopEdge", for: UIControl.State.normal)
        self.button12.setTitle("StopEdge", for: UIControl.State.disabled)
        
        self.bottomInfoLabel.text = "Ready"
        self.setupLoggingLevels()
    }
    
    /**
     Set logging levels for various modules and print several logging test messages.
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
     Initiates edgeSDK startup sequence
     MMKEdgeManager singleton class holds a reference to the edgeProvider instance after its initialization
     */
    @IBAction func button01Action(_ sender: UIButton) {
        
        self.buttonsEnabled(enabled: false)
        self.bottomInfoLabel.text = "startEdge called"
        
        if self.appOpsWrapper == nil {
            self.appOpsWrapper = edgeSDK_iOS_app_ops.init()
        }
        
        guard let appOpsWrapper = self.appOpsWrapper else {
            fatalError()
        }
        
        let edge_nodeId: String = UIDevice.current.name.contains("iPad") ? "iPad-UUID-12345678" : "iPhone-UUID-12345678"
        appOpsWrapper.startEdge(nodeId: edge_nodeId, delegate: self, completion: { state in
            
            guard state.error == nil else {
                DispatchQueue.main.async {
                    MMKLog.log(message: "startEdge Error: ", type: .error, value: "\(state.error?.localizedDescription ?? "no Error description")", subsystem: .edgeSDK_iOS_example)
                    self.bottomInfoLabel.text = "edgeSDK failed to start: \(state.error?.localizedDescription ?? "no Error description")"
                    self.buttonsEnabled(enabled: true)
                }
                return
            }
            
            DispatchQueue.main.async {
                self.bottomInfoLabel.text = "edgeSDK is running."
                self.buttonsEnabled(enabled: true)
            }
            
            appOpsWrapper.getConfig({ state in
                
                guard state.error == nil else {
                    MMKLog.log(message: "getConfig Error: ", type: .error, value: "\(state.error?.localizedDescription ?? "no Error description")", subsystem: .edgeSDK_iOS_example)
                    return
                }
                
                guard state.config != nil else {
                    MMKLog.log(message: "getConfig result is nil.", type: .error, subsystem: .edgeSDK_iOS_example)
                    return
                }
                
                MMKAuthenticationManager.sharedInstance.edgeConfig = state.config
                MMKLog.log(message: "edgeConfig: ", type: .info, value: "\(MMKAuthenticationManager.sharedInstance.edgeConfig!)", subsystem: .edgeSDK_iOS_example)
            })
        })
    }
    
    /**
     Starts the authentication session.
     */
    @IBAction func button02Action(_ sender: UIButton) {
        self.buttonsEnabled(enabled: false)
        self.bottomInfoLabel.text = "OID login in progress..."
        
        if self.appAuthWrapper == nil {
            self.appAuthWrapper = edgeSDK_iOS_app_auth.init()
        }
        
        guard let appAuthWrapper = self.appAuthWrapper else {
            fatalError()
        }
        
        // Configuration information is located in the MMKConfigurationManager class
        let authConfig = MMKAuthConfig.init(clientId: MMKConfigurationManager.clientId(), redirectUrl: MMKConfigurationManager.redirectURL(), additionalScopes: ["edge:gps:update"], authorizationRootUrl: MMKConfigurationManager.authorizationURL())
        
        appAuthWrapper.authorize(authConfig: authConfig, viewController: self, completion: { state in
            
            DispatchQueue.main.async {
                guard state.error == nil else {
                    MMKLog.log(message: "Authorization finished with an Error: ", type: .error, value: "\(state.error?.localizedDescription ?? "no Error description")", subsystem: .edgeSDK_iOS_example)
                    self.bottomInfoLabel.text = "Authorization finished with an Error: \(state.error?.localizedDescription ?? "no Error description")"
                    MMKAuthenticationManager.sharedInstance.clearAuthStatus()
                    self.buttonsEnabled(enabled: true)
                    return
                }
                
                guard state.status != nil else {
                    MMKLog.log(message: "Authorization finished with an Error", type: .error, subsystem: .edgeSDK_iOS_example)
                    self.bottomInfoLabel.text = "Authorization finished with an Error"
                    MMKAuthenticationManager.sharedInstance.clearAuthStatus()
                    self.buttonsEnabled(enabled: true)
                    return
                }
                
                MMKAuthenticationManager.sharedInstance.saveAuthStatus(status: state.status!)
                MMKLog.log(message: "Authorization finished successfully. accessToken: ", type: .info, value: "\(state.status?.accessToken ?? "no-token")", subsystem: .edgeSDK_iOS_example)
                self.bottomInfoLabel.text = "Authorization finished successfully."
                self.buttonsEnabled(enabled: true)
            }
        })
    }
    
    /**
     Starts the example micro service loading process by uploading its content via a edgeSDK service URL.
     */
    @IBAction func button03Action(_ sender: UIButton) {
        
        self.buttonsEnabled(enabled: false)
        self.bottomInfoLabel.text = "Deploying the example micro service..."
        
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
        
        let config: MMKMicroserviceDeploymentConfig = self.microserviceConfig()
        appOpsWrapper.deployMicroservice(edgeAccessToken: edgeAccessToken, config: config) { state in
            
            DispatchQueue.main.async {
                guard state.error == nil else {
                    MMKLog.log(message: "deployEdgeMicroservice Error: ", type: .error, value: "\(state.error?.localizedDescription ?? "no Error description")", subsystem: .edgeSDK_iOS_example)
                    self.bottomInfoLabel.text = "edgeSDK failed to deploy the example micro service: \(state.error?.localizedDescription ?? "no Error description")"
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
     Start the GPS location update process.
     */
    @IBAction func button04Action(_ sender: UIButton) {
        
        let message = "In order to use mimik's location services you need to update your mimik developer profile information.\n\nPlease see the mimik developer portal for more details."
        let alertVC = UIAlertController.init(title: "Location Services.", message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil)
        
        let callAction = UIAlertAction.init(title: "Call UpdateGPS", style: .default) { (action) in
            self.buttonsEnabled(enabled: false)
            self.bottomInfoLabel.text = "updateGps called. This may take a minute."
            
            MMKLocationManager.sharedInstance.provideLocation { (location, error) in
                
                guard error == nil, location != nil else {
                    
                    let message = error == nil ? "Change the iOS setting at edgeSDK | Allow Location Access or contact the device administrator" : error!.domain
                    
                    self.bottomInfoLabel.text = message
                    self.buttonsEnabled(enabled: true)
                    self.showLocationServicesWarning(message: message)
                    return
                }
                
                self.updateGps(location: location!)
            }
        }
        
        let portalAction = UIAlertAction.init(title: "Take me to Dev Portal", style: UIAlertAction.Style.default) { (action) in
            if let url = URL(string: "https://developer.mimik360.com"), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:])
            }
        }
        
        alertVC.addAction(okAction)
        alertVC.addAction(portalAction)
        alertVC.addAction(callAction)
        
        self.present(alertVC, animated: false, completion: nil)
    }
    
    /**
     Uses the edgeSDK app ops wrapper to send the devices's GPS location it received from the MMKLocatioManager to edgeSDK. It can only be done with a valid authorization token, so an edge access token is also supplied.
     */
    private func updateGps(location: CLLocation) -> Void {
        
        if self.appOpsWrapper == nil {
            self.appOpsWrapper = edgeSDK_iOS_app_ops.init()
        }
        
        guard let appOpsWrapper = self.appOpsWrapper else {
            fatalError()
        }
        
        guard let edgeAccessToken = MMKAuthenticationManager.sharedInstance.loadToken(type: .accessToken) else {
            self.bottomInfoLabel.text = "UpdateGps Error. Missing edgeAccessToken token. Please authorize."
            self.buttonsEnabled(enabled: true)
            return
        }
        
        appOpsWrapper.updateGps(edgeAccessToken, location: location) { state in
            DispatchQueue.main.async {
                guard state.error == nil else {
                    MMKLog.log(message: "UpdateGps Error: ", type: .error, value: "\(state.error?.localizedDescription ?? "no Error description.")", subsystem: .edgeSDK_iOS_example)
                    self.bottomInfoLabel.text = "UpdateGPS Error: \(state.error?.localizedDescription ?? "no Error description.")"
                    self.buttonsEnabled(enabled: true)
                    return
                }
                
                self.bottomInfoLabel.text = "UpdateGps OK"
                self.buttonsEnabled(enabled: true)
            }
        }
    }
    
    /**
     Shows a popup alert when location services are not available.
     */
    private func showLocationServicesWarning(message: String) -> Void {
        
        let alertVC = UIAlertController.init(title: "Location Unavailable.", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction.init(title: "OK", style: .default, handler: nil)
        alertVC.addAction(okAction)
        
        self.present(alertVC, animated: false, completion: nil)
    }
    
    /**
     Uses MMKGetManager to sends a getNetwork API call that returns a list of edgeSDK nodes visible on the local network
     */
    @IBAction func button05Action(_ sender: UIButton) {
        
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
     Uses MMKGetManager to sends a getNearby API call that returns a list of edge nodes visible across all networks considered within a "proximity" distance.
     - Remarks: The returned list will be either IP or GPS location based, depending on whether device's GPS location information has been sent to edgeSDK.
     */
    @IBAction func button06Action(_ sender: UIButton) {
        
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
     Combines several get info calls into one to provide an edgeSDK configuration overview.
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
     Removes deployed micro services from edgeSDK.
     */
    @IBAction func button08Action(_ sender: UIButton) {
        
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
        
        let config: MMKMicroserviceDeploymentConfig = self.microserviceConfig()
        appOpsWrapper.removeMicroservice(edgeAccessToken: edgeAccessToken, config: config) { state in
            
            DispatchQueue.main.async {
                guard state.error == nil else {
                    MMKLog.log(message: "deployEdgeMicroservice Error: ", type: .error, value: "\(state.error?.localizedDescription ?? "no Error description")", subsystem: .edgeSDK_iOS_example)
                    self.bottomInfoLabel.text = "edgeSDK failed to remove the example micro service: \(state.error?.localizedDescription ?? "no Error description")"
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
     Starts an unautorization session.
     */
    @IBAction func button09Action(_ sender: UIButton) {
        self.buttonsEnabled(enabled: false)
        self.bottomInfoLabel.text = "OID unauthorize in progress..."
        
        if self.appAuthWrapper == nil {
            self.appAuthWrapper = edgeSDK_iOS_app_auth.init()
        }
        
        guard let appAuthWrapper = self.appAuthWrapper else {
            fatalError()
        }
        
        // Configuration information is located in the MMKConfigurationManager class
        let authConfig = MMKAuthConfig.init(clientId: MMKConfigurationManager.clientId(), redirectUrl: MMKConfigurationManager.redirectURL(), additionalScopes: nil, authorizationRootUrl: MMKConfigurationManager.authorizationURL())
        
        appAuthWrapper.unauthorize(authConfig: authConfig, viewController: self) { state in
         
            DispatchQueue.main.async {
                guard state.error == nil else {
                    MMKLog.log(message: "auth status Error: ", type: .error, value: "\(String(describing: state.error))", subsystem: .edgeSDK_iOS_example)
                    self.bottomInfoLabel.text = "OID unauthorize finished with an Error: \(state.error?.localizedDescription ?? "no Error description")"
                    self.buttonsEnabled(enabled: true)
                    return
                }
                
                guard state.status != nil else {
                    MMKLog.log(message: "auth status unknown Error", type: .error, subsystem: .edgeSDK_iOS_example)
                    self.bottomInfoLabel.text = "OID unauthorize finished with an unknown Error"
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
     Get edgeIdToken
     */
    @IBAction func button10Action(_ sender: UIButton) {
        
        self.buttonsEnabled(enabled: false)
        self.bottomInfoLabel.text = "getEdgeIdToken called"
        
        if self.appAuthWrapper == nil {
            self.appAuthWrapper = edgeSDK_iOS_app_auth.init()
        }
        
        guard let appAuthWrapper = self.appAuthWrapper else {
            fatalError()
        }
        
        appAuthWrapper.edgeIdTokenDecoded { state in
         
            guard state.error == nil, let checkedContent = state.content as? [String:Any] else {
                MMKLog.log(message: "Get edgeIdToken Error: ", type: .error, value: "\(state.error?.localizedDescription ?? "no Error description")", subsystem: .edgeSDK_iOS_example)
                self.bottomInfoLabel.text = "Get edgeIdToken Error: \(state.error?.localizedDescription ?? "no Error description")"
                self.buttonsEnabled(enabled: true)
                return
            }
            
            DispatchQueue.main.async {
                let alertVC = UIAlertController.init(title: "Decoded edgeIdToken", message: checkedContent.description, preferredStyle: .alert)
                let okAction = UIAlertAction.init(title: "OK", style: .default, handler: nil)
                
                alertVC.addAction(okAction)
                self.present(alertVC, animated: true, completion: {
                    self.bottomInfoLabel.text = "Get edgeIdToken finished."
                    self.buttonsEnabled(enabled: true)
                })
            }
        }
    }
    
    /**
     Starts the edgeSDK shutdown procedure
     */
    @IBAction func button12Action(_ sender: UIButton) {

        self.buttonsEnabled(enabled: false)
        self.bottomInfoLabel.text = "stopEdge called"

        if self.appOpsWrapper == nil {
            self.appOpsWrapper = edgeSDK_iOS_app_ops.init()
        }

        guard let appOpsWrapper = self.appOpsWrapper else {
            fatalError()
        }

        appOpsWrapper.stopEdge(completion: { state in

            DispatchQueue.main.async {
                guard state.error == nil else {
                    MMKLog.log(message: "stopEdge Error: ", type: .error, value: "\(state.error?.localizedDescription ?? "no Error description")", subsystem: .edgeSDK_iOS_example)
                    self.bottomInfoLabel.text = "edgeSDK failed to stop: \(state.error?.localizedDescription ?? "no Error description")"
                    self.buttonsEnabled(enabled: true)
                    return
                }

                self.bottomInfoLabel.text = "edgeSDK is stopped. Lifecycle listener unregistered"
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
            self.button10.isEnabled = enabled
            self.button11.isEnabled = false
            self.button12.isEnabled = enabled
        }
    }
}

internal extension ViewController {
    
    /**
     Determines which edgeSDK node has been selected, then gets an url to it and initiates a hello endpoint call on it.
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
                    MMKLog.log(message: "Hello response from node: ", type: .info, value: "\(node.urlString ?? "no-url-detected") json: \(json ?? JSON())", subsystem: .edgeSDK_iOS_example)
                })
                
            }
            else if let checkedError = error {
                self.bottomInfoLabel.text = checkedError.localizedDescription
            }
            else {
                self.bottomInfoLabel.text = "An unknown Error occured"
            }
        }
    }
    
    /**
     Returns a number of edgeSDK nodes for the table
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
    func microserviceConfig() -> MMKMicroserviceDeploymentConfig {
        
        guard let imageUrl = self.microServiceBundleStorageURL(name: "example-v1") else {
            fatalError()
        }
        
        let envVariables: [String:String] = [
            "BEAM": MMKConfigurationManager.edgeServiceLink() + "/beam/v1",
            "uMDS": MMKConfigurationManager.edgeServiceLink() + "/mds/v1"
        ]
        
        return MMKMicroserviceDeploymentConfig.init(name: "example-v1", apiRootUrl: "/example-v1/v1", imagePath: imageUrl.path, envVariables: envVariables)
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
        
        appOpsWrapper.getDeployedImages(edgeAccessToken: edgeAccessToken) { state in
            
            if state.error == nil {
                let imagesJson = JSON.init(state.content ?? "")
                debugInfo += "getDeployedImages:\n"
                debugInfo += imagesJson.rawString(String.Encoding.utf8, options: JSONSerialization.WritingOptions.prettyPrinted)!+"\n\n"
            }
            
            appOpsWrapper.getDeployedContainers(edgeAccessToken: edgeAccessToken) { state in
                
                if state.error == nil {
                    let containersJson = JSON.init(state.content ?? "")
                    debugInfo += "getDeployedContainers:\n"
                    debugInfo += containersJson.rawString(String.Encoding.utf8, options: JSONSerialization.WritingOptions.prettyPrinted)!+"\n\n"
                }
                
                appOpsWrapper.getConfig({ state in
                    
                    if state.config != nil && state.error == nil {
                        debugInfo += "getConfig:\n"
                        debugInfo += state.config!.description+"\n\n"
                    }

                    appOpsWrapper.getInfo({ state in
                        
                        if state.info != nil && state.error == nil {
                            debugInfo += "getInfo:\n"
                            debugInfo += (state.info?.description)!+"\n\n"
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
extension ViewController: MMKEdgeAppOpsProtocol {
    func edgeStatusChanged(status: MMKEdgeStatus) {
        MMKLog.log(message: "edgeStatusChanged.", type: .info, value: "state: \(status.edgeState.rawValue) event: \(status.stateChangingEvent.rawValue)", subsystem: .edgeSDK_iOS_example)
        DispatchQueue.main.async {
            self.bottomInfoLabel.text = "state: \(status.edgeState.rawValue) event: \(status.stateChangingEvent.rawValue)"
        }
    }
}
