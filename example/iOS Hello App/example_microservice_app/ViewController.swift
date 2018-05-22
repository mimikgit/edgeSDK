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

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var edgeNodes: [MMKEdgeNode] = []
    
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

        self.button02.isEnabled = false
        self.button02.setTitle("Login", for: UIControlState.normal)
        self.button02.setTitle("Login", for: UIControlState.disabled)

        self.button03.isEnabled = false
        self.button03.setTitle("Associate", for: UIControlState.normal)
        self.button03.setTitle("Associate", for: UIControlState.disabled)
        
        self.button04.isEnabled = false
        self.button04.setTitle("LoadExample", for: UIControlState.normal)
        self.button04.setTitle("LoadExample", for: UIControlState.disabled)
        
        self.button05.isEnabled = false
        self.button05.setTitle("GetNetwork", for: UIControlState.normal)
        self.button05.setTitle("GetNetwork", for: UIControlState.disabled)

        self.button06.isEnabled = false
        self.button06.setTitle("GetNearby", for: UIControlState.normal)
        self.button06.setTitle("GetNearby", for: UIControlState.disabled)

        self.button07.isEnabled = false
        self.button07.setTitle("Unassociate", for: UIControlState.normal)
        self.button07.setTitle("Unassociate", for: UIControlState.disabled)
        
        self.button08.isEnabled = false
        self.button08.setTitle("StopEdge", for: UIControlState.normal)
        self.button08.setTitle("StopEdge", for: UIControlState.disabled)
        
        self.button09.isEnabled = true
        self.button09.setTitle("edgeSDK URL", for: UIControlState.normal)
        self.button09.setTitle("edgeSDK URL", for: UIControlState.disabled)
        
        self.bottomInfoLabel.text = "Ready"
        
        // uncomment below to have all the startup buttons pushed automatically, after you have logged in at last once before manually.
        // self.automaticStart()
    }
    
    @IBAction func button01Action(_ sender: UIButton) {
        
        self.button01.isEnabled = false
        self.bottomInfoLabel.text = "Starting edgeSDK..."
        
        //
        // initiates the edgeSDK startup sequence
        // MMKEdgeManager singleton class holds a reference to the edgeProvider instance after initialization
        //
        
        MMKEdgeManager.sharedInstance.startEdge { (result) in
            print("startEdge result: \(result)")
            self.bottomInfoLabel.text = "edgeSDK is running."
            self.button02.isEnabled = true
            self.button08.isEnabled = true
        }
    }
    
    @IBAction func button02Action(_ sender: UIButton) {
        
        self.button02.isEnabled = false
        self.bottomInfoLabel.text = "OID login is in progress..."
        
        //
        // initiates the OID login process in a SFAuthenticationSession (called internally by the AppAuth library)
        // https://openid.github.io/AppAuth-iOS/
        // https://developer.apple.com/documentation/safariservices/sfauthenticationsession
        //
        
        MMKAuthenticationManager.sharedInstance.login(viewController: self) { (result) in
            print("OID login result: \(result)")
            self.bottomInfoLabel.text = "OID login finished."
            self.button02.isEnabled = !MMKAuthenticationManager.sharedInstance.isAuthorized(type: .edge)
            self.button03.isEnabled = true
        }
    }
    
    @IBAction func button03Action(_ sender: UIButton) {
        
        self.button03.isEnabled = false
        self.bottomInfoLabel.text = "edgeSDK is account associating..."
        
        //
        // initiates edgeSDK account association process via a JSON-RPC protocol through a WebSocket connection to the edgeSDK instance
        //
        
        MMKAuthenticationManager.sharedInstance.accountAssociate { (result) in
            print("accountAssociate result: \(result)")
            self.bottomInfoLabel.text = "edgeSDK is account associated."
            self.button04.isEnabled = true
        }
    }
    
    @IBAction func button04Action(_ sender: UIButton) {
        
        self.button04.isEnabled = false
        self.bottomInfoLabel.text = "edgeSDK is loading the example micro service..."
        
        //
        // initiates the example micro service loading process by uploading the content via a edgeSDK service URL
        //
        
        MMKEdgeManager.sharedInstance.setupMicroServices { (result) in
            print("setupMicroServices result: \(result)")
            self.bottomInfoLabel.text = "edgeSDK loaded the example micro service"
            self.button05.isEnabled = true
            self.button06.isEnabled = true
            self.button07.isEnabled = true
        }
    }
    
    @IBAction func button05Action(_ sender: UIButton) {
        
        sender.isEnabled = false
        
        //
        // initiates a "getNetwork" API call that returns a list of edge nodes visible on the local network
        //
        
        self.edgeNodes.removeAll()
        self.tableView.reloadData()
        self.bottomInfoLabel.text = "Calling getNetwork"
        
        MMKGetManager.getNodes(type: .network, completion: { (nodes, error) in
            
            guard error == nil else {
                self.tableView.reloadData()
                self.bottomInfoLabel.text = error?.localizedDescription
                sender.isEnabled = true
                return
            }
            
            guard nodes != nil else {
                self.tableView.reloadData()
                self.bottomInfoLabel.text = "Unable to process the response"
                sender.isEnabled = true
                return
            }
            
            sender.isEnabled = true
            self.edgeNodes = nodes!
            self.tableView.reloadData()

            let nodeString: String = self.edgeNodes.count == 1 ? "node" : "nodes"
            self.bottomInfoLabel.text = "Received information about \(self.edgeNodes.count) \(nodeString)"
        })
    }
    
    @IBAction func button06Action(_ sender: UIButton) {
        
        sender.isEnabled = false
        
        //
        // initiates a "getNearby" API call that returns a list of edge nodes visible across all networks considered within a "proximity" distance
        //
        
        self.edgeNodes.removeAll()
        self.tableView.reloadData()
        self.bottomInfoLabel.text = "Calling getNearby"
        
        MMKGetManager.getNodes(type: .nearby, completion: { (nodes, error) in
            
            guard error == nil else {
                self.tableView.reloadData()
                self.bottomInfoLabel.text = error?.localizedDescription
                sender.isEnabled = true
                return
            }
            
            guard nodes != nil else {
                self.tableView.reloadData()
                self.bottomInfoLabel.text = "Unable to process the response"
                sender.isEnabled = true
                return
            }

            sender.isEnabled = true
            self.edgeNodes = nodes!
            self.tableView.reloadData()
            
            let nodeString: String = self.edgeNodes.count == 1 ? "node" : "nodes"
            self.bottomInfoLabel.text = "Received information about \(self.edgeNodes.count) \(nodeString)"
        })
    }
    
    @IBAction func button07Action(_ sender: UIButton) {
        
        self.button07.isEnabled = false
        
        //
        // initiates edgeSDK account unassociation process
        // first attempts to get a permission from the user via OID authentication
        // if successfull attempts to unassociate via a JSON-RPC protocol call through a WebSocket connection to the edgeSDK instance
        //
        
        MMKAuthenticationManager.sharedInstance.resetEdge(viewController: self) { (result) in
            print("OID reset result: \(result)")
            self.bottomInfoLabel.text = "OID reset finished."
            
            self.button02.isEnabled = false
            
            MMKAuthenticationManager.sharedInstance.accountUnassociate { (result) in
                print("accountUnassociate result: \(result)")
                self.bottomInfoLabel.text = "edgeSDK is account unassociated."
                self.button03.isEnabled = true
                self.button04.isEnabled = true
                MMKAuthenticationManager.sharedInstance.clearAuthStates()
                self.button01.isEnabled = !MMKAuthenticationManager.sharedInstance.isAuthorized(type: .edge)
                self.button02.isEnabled = false
            }
        }
    }
    
    @IBAction func button08Action(_ sender: UIButton) {
        
        self.button08.isEnabled = false
        
        //
        // initiates the edgeSDK shutdown sequence
        // MMKEdgeManager singleton class releases the edgeProvider reference
        //
        
        MMKEdgeManager.sharedInstance.stopEdge()
        self.button01.isEnabled = true
        self.button02.isEnabled = true
    }
    
    @IBAction func button09Action(_ sender: UIButton) {
        
        //
        // returns externaly accessible URL link to the edge service
        //
        
        let serviceLink = MMKEdgeManager.sharedInstance.edgeProvider?.edgeServiceExternalURL()
        self.bottomInfoLabel.text = serviceLink?.absoluteString
    }
}

fileprivate extension ViewController {
    func automaticStart() -> Void {
        
        // checking to see if we have been through the authorization process at least once before
        guard MMKAuthenticationManager.sharedInstance.isAuthorized(type: .edge),
            MMKAuthenticationManager.sharedInstance.isAuthorized(type: .backend) else {
                return
        }
        
        DispatchQueue.main.async {
            // start edgeSDK
            self.button01Action(self.button01)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                // initiate OID login - you can click the cancel button
                self.button02Action(self.button02)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                    // initiate edgeSDK account association
                    self.button03Action(self.button03)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                        // load the example micro service
                        self.button04Action(self.button04)
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                            // initiate the "getNearby" API call for a list of nearby edge nodes (by proximity, across all networks)
                            self.button06Action(self.button06)
                        }
                    }
                }
            }
        }
    }
}

internal extension ViewController {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let node = self.edgeNodes[indexPath.row]
        self.bottomInfoLabel.text = "Connecting to node: \(node.displayName()), please wait for a response."
        
        node.getBEPURL { (url, error) in
            let updatedNode: MMKEdgeNode = node
            
            if let checkedUrl = url {
                //
                // We've received our internal or BEP url so we'll initiate a "hello" API call that returns a "Hellow WORLD!!!" string in a JSON format (from the selected node.)
                //
                
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
                    print("☘️☘️☘️ hello response from node: \(node.urlString ?? "no-url-detected") json: \(json ?? JSON())")
                })
                
            }
            else if let checkedError = error {
                //
                // We've received an error in the response
                //
                
                self.bottomInfoLabel.text = checkedError.localizedDescription
            }
            else {
                //
                // We don't know what happend, so let's assume an error occured
                //
                
                self.bottomInfoLabel.text = "An unknown error occured"
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.edgeNodes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "NodeCell")!
        let node = self.edgeNodes[indexPath.row]
        
        cell.textLabel?.text = "name: " + node.displayName()
        cell.detailTextLabel?.text = "id:   "+node.id! + "\nos: \(node.os ?? "")" + "\nurl: \(node.urlString ?? "external network")"
        return cell
    }
}
