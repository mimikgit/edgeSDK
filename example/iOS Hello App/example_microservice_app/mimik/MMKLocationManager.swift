//
//  MMKLocationManager.swift
//  example_microservice_app
//
//  Created by Radúz Benický on 2019-01-03.
//  Copyright © 2019 mimik. All rights reserved.
//

import CoreLocation
import Foundation
import UIKit

class MMKLocationManager: NSObject {
    
    /** MMKLocationManager singleton shared instance. */
    public static let sharedInstance = MMKLocationManager()
    
    /** Location manager instance. */
    lazy var locationManager: CLLocationManager = {
        return CLLocationManager.init()
    }()
    
    /** A location completion handler that a caller registers in order to receive one time location information when it becomes available. Alternatively an Error is sent if the location information is not available. */
    var locationCompletion: (((location: CLLocation?, error: NSError?))->Void)?
    
    /** Cached authorization to use location services. */
    var authorizationStatus: CLAuthorizationStatus = .notDetermined
    
    private override init() {
        super.init()
        self.configureLocationManager()
    }
    
    /** Configures the location manager instance. Delegate and location information accuracy. */
    private func configureLocationManager() -> Void {
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    /** Configures the location manager instance. Delegate registration and location information accuracy. */
    func provideLocation(_ completion: @escaping ((location: CLLocation?, error: NSError?)) -> Void) {
        self.locationCompletion = completion
        self.processAuthorizationStatus(status: self.authorizationStatus)
    }
    
    /** Starts the location and heading information updating processes. */
    func startLocationServices() -> Void {
        self.locationManager.startUpdatingLocation()
        self.locationManager.startUpdatingHeading()
    }
    
    /** Stops the location and heading information updating processes. */
    func stopLocationServices() -> Void {
        self.locationManager.stopUpdatingLocation()
        self.locationManager.stopUpdatingHeading()
    }
}

extension MMKLocationManager: CLLocationManagerDelegate {
    /** This method is called whenever the application’s ability to use location services changes. We will cache the updated authorization status and react to the change. */
    func locationManager(_ manager: CLLocationManager,
                         didChangeAuthorization status: CLAuthorizationStatus) {
        self.authorizationStatus = status
        self.processAuthorizationStatus(status: self.authorizationStatus)
    }
    
    /** Reacting to the change of location services authorization status. */
    func processAuthorizationStatus(status: CLAuthorizationStatus) -> Void {
        
        /** Disregarding the location services authorization status since there is no completion handler registered. */
        guard let locationCompletion = self.locationCompletion else {
            return
        }
        
        switch self.authorizationStatus {
        case .restricted:
            // This app is not authorized to use location services.
            // The user cannot change this app’s status, possibly due to active restrictions such as parental controls being in place.
            locationCompletion((nil, NSError.init(domain: "Access to location information is restricted.\nCheck with the device administrator.", code: 403, userInfo: nil)))
            self.locationCompletion = nil
            self.stopLocationServices()
            break
            
        case .denied:
            // The user explicitly denied the use of location services for this app or location services are currently disabled in Settings.
            locationCompletion((nil, NSError.init(domain: "Access to location information was denied.\nChange the iOS setting at edgeSDK | Allow Location Access.", code: 401, userInfo: nil)))
            self.locationCompletion = nil
            self.stopLocationServices()
            break
            
        case .authorizedWhenInUse:
            // This app is authorized to start most location services while running in the foreground.
            self.startLocationServices()
            break
            
        case .authorizedAlways:
            // This app is authorized to start location services at any time.
            self.startLocationServices()
            break
            
        case .notDetermined:
            // The user has not yet made a choice regarding whether this app can use location services.
            self.locationManager.requestWhenInUseAuthorization()
            break
        @unknown default:
            locationCompletion((nil, NSError.init(domain: "Access to location information is undetermined.\nChange the iOS setting at edgeSDK | Allow Location Access.", code: 401, userInfo: nil)))
            self.locationCompletion = nil
            self.stopLocationServices()
        }
    }
    
    /**
     Called when updated location information has been received.
     - Remarks: A valid location completion handler is fulfilled with the first location received.
     */
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        self.stopLocationServices()
        
        guard let firstLocation = locations.first, let locationCompletion = self.locationCompletion else {
            return
        }
        
        locationCompletion((firstLocation, nil))
        self.locationCompletion = nil
    }
}
