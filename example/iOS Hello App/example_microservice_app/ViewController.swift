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
        self.button04.setTitle("LoadµServices", for: UIControlState.normal)
        self.button04.setTitle("LoadµServices", for: UIControlState.disabled)
        
        self.button05.isEnabled = false
        self.button05.setTitle("GetNodes", for: UIControlState.normal)
        self.button05.setTitle("GetNodes", for: UIControlState.disabled)
        
        self.button06.isEnabled = false
        self.button06.setTitle("Unassociate", for: UIControlState.normal)
        self.button06.setTitle("Unassociate", for: UIControlState.disabled)
        
        self.button07.isEnabled = false
        self.button07.setTitle("StopEdge", for: UIControlState.normal)
        self.button07.setTitle("StopEdge", for: UIControlState.disabled)
        
        self.button08.isEnabled = false
        self.button08.setTitle("edgeSDK external URL", for: UIControlState.normal)
        self.button08.setTitle("edgeSDK external URL", for: UIControlState.disabled)
        
        self.bottomInfoLabel.text = "Ready"
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
            self.button07.isEnabled = true
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
        self.bottomInfoLabel.text = "edgeSDK is loading example micro service..."
        
        //
        // initiates the example micro service loading process by uploading the content via a edgeSDK service URL
        //
        
        MMKEdgeManager.sharedInstance.setupMicroServices { (result) in
            print("setupMicroServices result: \(result)")
            self.bottomInfoLabel.text = "edgeSDK loaded example micro service"
            self.button05.isEnabled = true
            self.button06.isEnabled = true
        }
    }
    
    @IBAction func button05Action(_ sender: UIButton) {
        
        self.button05.isEnabled = false
        
        //
        // initiates a "getNodes" API call that returns a list of edge nodes visible on the local network
        //
        
        guard let edgeToken = MMKAuthenticationManager.sharedInstance.edgeToken(),
            let backendToken = MMKAuthenticationManager.sharedInstance.backendToken() else {
                return
        }
        
        let link = kExampleMicroServiceNearbyNodesLink
        
        self.edgeNodes.removeAll()
        self.tableView.reloadData()
        self.bottomInfoLabel.text = ""
        
        let authenticatedLink = link + "&userAccessToken=\(backendToken)"
        let headers = ["Authorization" : "Bearer \(edgeToken)" ]
        
        Alamofire.request(authenticatedLink, method: .get, parameters: nil, encoding: URLEncoding.default, headers: headers).responseJSON { response in
            switch response.result {
            case .success(let data):
                sender.isEnabled = true
                
                let json = JSON.init(data)
                if json != JSON.null {
                    let dataJson = json["data"]
                    if dataJson != JSON.null {
                        self.parseNodes(json: dataJson)
                    }
                }
                
            case .failure(let error):
                self.tableView.reloadData()
                self.bottomInfoLabel.text = error.localizedDescription
                sender.isEnabled = true
                self.button05.isEnabled = true
            }
        }
    }
    
    @IBAction func button06Action(_ sender: UIButton) {
        
        self.button06.isEnabled = false
        
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
    
    @IBAction func button07Action(_ sender: UIButton) {
        
        self.button07.isEnabled = false
        
        //
        // initiates the edgeSDK shutdown sequence
        // MMKEdgeManager singleton class releases the edgeProvider reference
        //
        
        MMKEdgeManager.sharedInstance.stopEdge()
        self.button01.isEnabled = true
        self.button02.isEnabled = true
    }
    
    @IBAction func button08Action(_ sender: UIButton) {
        
        //
        // returns externaly accessible URL link to the edge service
        //
        
        let serviceLink = MMKEdgeManager.sharedInstance.edgeProvider?.edgeServiceExternalURL()
        self.bottomInfoLabel.text = serviceLink?.absoluteString
    }
}

internal extension ViewController {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let node = self.edgeNodes[indexPath.row]
        self.bottomInfoLabel.text = "Selected node: \(self.nodeDisplayName(node: node))"
        
        //
        // initiates a "hello" API call that returns a "Hellow WORLD!!!" string in a JSON from the selected node.
        //
        self.callHelloAtEdgeNode(node: node)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.edgeNodes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "NodeCell")!
        let node = self.edgeNodes[indexPath.row]
        cell.textLabel?.text = "name: "+self.nodeDisplayName(node: node)
        cell.detailTextLabel?.text = "id:   "+node.id! + "\nos: \(node.os ?? "")" + "\nurl: \(node.urlString ?? "")"
        return cell
    }
}

fileprivate extension ViewController {
    func parseNodes(json: JSON) -> Void {
        for (_, node) in (json.array?.enumerated())! {
            let edgeNode = MMKEdgeNode.init(json: node)
            if edgeNode != nil {
                self.edgeNodes.append(edgeNode!)
            }
        }
        
        self.tableView.reloadData()
        let nodeString: String = self.edgeNodes.count == 1 ? "node" : "nodes"
        self.bottomInfoLabel.text = "Received information about \(self.edgeNodes.count) \(nodeString)"
        self.button05.isEnabled = true
    }
    
    func callHelloAtEdgeNode(node: MMKEdgeNode) {
        
        let link = node.urlString!+kExampleMicroServiceHelloEndpoint
        self.bottomInfoLabel.text = "Calling hello on "+node.name!
        print("☘️☘️☘️ calling hello at node: \(link)")
        
        Alamofire.request(link).responseJSON { response in
            switch response.result {
            case .success(let data):
                
                let json = JSON.init(data)
                if json != JSON.null {
                    self.bottomInfoLabel.text = "\(json["JSONMessage"]) received from \(self.nodeDisplayName(node: node))"
                    print("☘️☘️☘️ hello response json: \(json)")
                }
                
            case .failure(let error):
                print("🔥🔥🔥 error: \(error.localizedDescription)")
                self.tableView.reloadData()
                self.bottomInfoLabel.text = error.localizedDescription
            }
        }
    }
    
    func nodeDisplayName(node: MMKEdgeNode) -> String {
        return node.name! + (node.thisDevice ? " (this device)" : "")
    }
}
