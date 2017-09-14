//
//  LocationService.swift
//  E-Bike App
//
//  Created by KWANIL KIM on 9/11/17.
//  Copyright © 2017 DTI Holdings Inc. All rights reserved.
//

import Foundation
import CoreLocation

class LocationService: NSObject, CLLocationManagerDelegate{

    public static var sharedInstance = LocationService()
    let locationManager: CLLocationManager
    var locationDataArray: [CLLocation]
    var userFilter: Bool = true
    
    override init() {
    
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.distanceFilter = 5
        locationManager.requestWhenInUseAuthorization()
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        locationDataArray = [CLLocation]()
        
        userFilter = true
        super.init()
        
        locationManager.delegate = self
    }


    func startUpdatingLocation() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        } else {
            // tell view controller to show an alert
            showTurnOnLocationServiceAlert()
        }
    
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        var locationAdded:Bool
        if let newLocation = locations.last{
        
            if userFilter{
                locationAdded = filterAndAddLocation(newLocation)
            } else {
            
                locationDataArray.append(newLocation)
                locationAdded = true
            }
        
            if locationAdded {
                notifyDidUpdateLocation(newLocation: newLocation)
            
            }
        }
    }
    
    
    
    func filterAndAddLocation(_ location: CLLocation) -> Bool {
        let age = -location.timestamp.timeIntervalSinceNow
        
        if age > 10 {
            print("Location is old")
            return false
        }
        if location.horizontalAccuracy < 0 {
            print("Lat and Long values are invalid")
            return false
        }
        if location.horizontalAccuracy > 100 {
            print("Accuracy is too low")
            return false
        }
        
        print("Location quality is good enough")
        locationDataArray.append(location)
        
        return true
    
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if (error as NSError).domain == kCLErrorDomain && (error as NSError).code == CLError.Code.denied.rawValue{
            // User denied your app to access your location information
            showTurnOnLocationServiceAlert()
        
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted:
            
            print("Location access was restricted.")
            
        case .denied:
            
            print("User denied access to locaiton.")
            
        case .notDetermined:
            
            print("Location status not determined.")
            
        case .authorizedAlways:
            
            guard CLLocationManager.headingAvailable() else {
                print("Heading is not available right now")
                return }
            
        case .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
            //mapView.isMyLocationEnabled = true
        }
    }
    
    
    
    func showTurnOnLocationServiceAlert() {
        NotificationCenter.default.post(name: Notification.Name(rawValue:"showTurnOnLocationServiceAlert"), object: nil)
    }
    
    func notifyDidUpdateLocation(newLocation: CLLocation){
    
        NotificationCenter.default.post(name: Notification.Name(rawValue:"didUpdateLocation"), object: nil, userInfo: ["location" : newLocation])
    }
    
    
}
