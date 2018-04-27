//
//  MMKEdgeManager.swift
//  mimik access test 01
//
//  Created by Raduz Benicky on 2018-01-10.
//  Copyright © 2017 mimik. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON
import edgeSDK_iOS

let kEdgeServicePort:String = "8042"
let kEdgeServiceLink:String = "http://127.0.0.1:"+kEdgeServicePort
let kEdgeServiceIPPort:String = "127.0.0.1:"+kEdgeServicePort
let kExampleMicroServiceNearbyNodesLink:String = kEdgeServiceLink+"/example/v1/drives?type=nearby"
let kExampleMicroServiceHelloEndpoint:String = "/example/v1/hello"
let kFriendsBackend: String = "https://mfd.mimik360.com"
let kProfileBackend: String = "https://mpo.mimik360.com"

final public class MMKEdgeManager: NSObject {
    
    public static let sharedInstance = MMKEdgeManager()
    var edgeProvider: edgeSDK_iOS?
    
    fileprivate let bundledMicroServices: [MicroService] = [.example]
    let edge_deviceId: String = UIDevice.current.name.contains("iPad") ? "iPad-UUID-12345678" : "iPhone-UUID-12345678"
}

public extension MMKEdgeManager {
    func startEdge(completion: @escaping (Any) -> Void) {

        print("starting edgeSDK with deviceId:\(edge_deviceId) workingDir:\(self.edgeServiceWorkingDirectoryPath() )")
        
        if self.edgeProvider == nil {
            self.edgeProvider = edgeSDK_iOS.init(deviceId: edge_deviceId, workingDir: self.edgeServiceWorkingDirectoryPath())
        }
        
        self.edgeProvider?.startEdge()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            completion("edgeSDK started")
        }
    }
    
    func stopEdge() -> Void {
        self.edgeProvider?.stopEdge()
        self.edgeProvider = nil
    }
    
    func setupMicroServices(completion: @escaping (Any) -> Void) {
        
        self.loadImage(microService:.example) {
            
            self.loadContainerFor(microService: .example, completion: {
                
                self.getLoadedElements(microServiceElement: MMKEdgeManager.MicroServiceElement.image, completion: { (result) in
                    print("Loaded micro service images: \(result)")
                    
                    self.getLoadedElements(microServiceElement: MMKEdgeManager.MicroServiceElement.container, completion: { (result) in
                        print("Loaded micro service containers: \(result)")
                        completion(result)
                    })
                })
            })
        }
    }
}

fileprivate extension MMKEdgeManager {
    enum MicroService: String {
        case example = "example-v1"
    }
    
    enum MicroServiceElement: String {
        case image = "images"
        case container = "containers"
    }

    func getLoadedElements(microServiceElement: MicroServiceElement, completion: @escaping (Any) -> Void) {
        
        guard let edgeToken = MMKAuthenticationManager.sharedInstance.edgeToken() else {
            return
        }
        
        let link = kEdgeServiceLink+"/mcm/v1/"+microServiceElement.rawValue
        let headers = ["Authorization" : "Bearer \(edgeToken)" ]
        
        Alamofire.request(link, method: .get, parameters: nil, encoding: URLEncoding.default, headers: headers).responseJSON { response in
            switch response.result {
            case .success(let data):
                completion(data)
            case .failure(let error):
                print("Something went wrong when getting a loaded microservice: \(microServiceElement.rawValue) ERROR: \(error)")
                assertionFailure("LoadedElement \(microServiceElement.rawValue) ERROR: \(error)")
            }
        }
    }
    
    func loadImage(microService:MicroService, completion: @escaping () -> Void) {
        
        guard let edgeToken = MMKAuthenticationManager.sharedInstance.edgeToken() else {
            return
        }
        
        let link = kEdgeServiceLink+"/mcm/v1/images"
        let data = self.microServiceBinaryDataFromBundledFile(microService: microService)
        let headers = ["Authorization" : "Bearer \(edgeToken)" ]
        
        Alamofire.upload(multipartFormData: { multipartFormData in
            multipartFormData.append(data!, withName: "image", mimeType: "application/tar")
        },
                         usingThreshold: 100000000,
                         to: link,
                         method: .post ,
                         headers: headers,
                         encodingCompletion: { encodingResult in
                            switch encodingResult {
                            case .success(let upload, _, _):
                                upload.responseJSON { response in
                                    
                                    do {
                                        if response.data != nil {
                                            _ = try JSON.init(data: response.data!)
                                            completion()
                                        }
                                    }
                                    catch {
                                        print("Something went wrong when loading a microservice image: \(microService.rawValue) ERROR: \(error.localizedDescription)")
                                    }
                                }
                            case .failure(let error):
                                print("Something went wrong when loading a microservice image: \(microService.rawValue) ERROR: \(error)")
                                assertionFailure("LoadImage \(microService.rawValue) ERROR: \(error)")
                            }
        })
    }
    
    func loadContainerFor(microService:MicroService, completion: @escaping () -> Void) {
        
        guard let edgeToken = MMKAuthenticationManager.sharedInstance.edgeToken() else {
            return
        }
        
        let link = kEdgeServiceLink+"/mcm/v1/containers"
        let url: URL = URL.init(string: link)!
        let parameters = self.loadContainerParameters(microService: microService)
        
        let request = NSMutableURLRequest(url: url)
        let session = URLSession.shared
        request.httpMethod = "POST"
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: [])
        request.addValue("Bearer \(edgeToken)", forHTTPHeaderField: "Authorization")
        
        let task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
            if error == nil {
                
                do {
                    if data != nil {
                        _ = try JSON.init(data: data!)
                        completion()
                    }
                }
                catch {
                    completion()
                }
            }
            else {
                print("Something went wrong when loading a microservice container: \(microService.rawValue) ERROR: \(error!)")
                assertionFailure("Something went wrong when loading a microservice container: \(microService.rawValue) ERROR: \(error!)")
            }
        })
        
        task.resume()
    }
    
    func loadContainerParameters(microService: MicroService) -> [String: Any] {
        switch microService {
        case .example:
            return
                [
                    "name": "example-v1",
                    "image": "example-v1",
                    "env": [
                        "BEAM": kEdgeServiceLink+"/beam/v1",
                        "MCM.BASE_API_PATH": "/example/v1",
                        "MCM.WEBSOCKET_SUPPORT": "false",
                        "MFD": kFriendsBackend+"/mFD/v1",
                        "MPO": kProfileBackend+"/mPO/v1",
                        "uMDS": kEdgeServiceLink+"/mds/v1"
                    ]
            ]
        }
    }
    
    func deleteElementForMicroService(microServiceElement: MicroServiceElement, microService: MicroService, completion: @escaping () -> Void) {
        
        guard let edgeToken = MMKAuthenticationManager.sharedInstance.edgeToken() else {
            return
        }

        let link = kEdgeServiceLink+"/mcm/v1/"+microServiceElement.rawValue+"/"+microService.rawValue
        let headers = ["Authorization" : "Bearer \(edgeToken)" ]
        
        Alamofire.request(link, method: .delete, parameters: nil, encoding: URLEncoding.default, headers: headers).responseJSON { response in
            switch response.result {
            case .success(_):
                completion()
            case .failure(_):
                assertionFailure("failed to delete an elements")
            }
        }
    }
    
    func microServiceBinaryDataFromBundledFile(microService: MicroService) -> Data? {
        let microServiceFilePath = self.microServiceBundleStoragePath(microService: microService)
        let data = FileManager.default.contents(atPath: microServiceFilePath!)
        return data
    }
    
    func microServiceTarFileName(microService: MicroService, withExtension: Bool) -> String {
        return withExtension == true ? microService.rawValue+".tar":microService.rawValue
    }
    
    // This is where the .tar micro service is stored in the application's bundle
    func microServiceBundleStoragePath(microService: MicroService) -> String? {
        let microServiceFileName = self.microServiceTarFileName(microService: microService, withExtension: false)
        let microServiceBundlePath = Bundle.main.path(forResource: microServiceFileName, ofType: ".tar")
        return microServiceBundlePath
    }
    
    func errorWithGenericMessage() -> Error {
        let error: Error = NSError.init(domain: NSCocoaErrorDomain, code: 500, userInfo: nil)
        return error
    }
    
    // This is where the edge and container service co-exists
    func edgeServiceWorkingDirectoryFileURL() -> URL {
        
        let edgeServiceWorkingDirectoryPath = self.edgeServiceWorkingDirectoryPath()
        return URL.init(fileURLWithPath: edgeServiceWorkingDirectoryPath)
    }
    
    // This is the root working directory for the edgeService
    func edgeServiceWorkingDirectoryPath() -> String {
        do {
            let applicationSupportDirURL = try FileManager.default.url(for: FileManager.SearchPathDirectory.applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: false).path
            let workingDir = applicationSupportDirURL+"/.edgeService"
            try FileManager.default.createDirectory(atPath: workingDir, withIntermediateDirectories: true, attributes: nil)
            return workingDir
        }
        catch {
            assertionFailure("Unable to establish edgeServiceWorkingDirectoryPath")
            return "assertionFailure"
        }
    }
}

fileprivate extension String {
    //: ### Base64 encoding a string
    func base64Encoded() -> String? {
        if let data = self.data(using: .utf8) {
            return data.base64EncodedString()
        }
        return nil
    }
    
    //: ### Base64 decoding a string
    func base64Decoded() -> String? {
        if let data = Data(base64Encoded: self) {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }
}
