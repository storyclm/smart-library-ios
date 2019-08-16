//
//  SLLocationManager.swift
//  SmartLibrary
//
//  Created by Oleksandr Yolkin on 5/22/19.
//  Copyright © 2019 Breffi. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import AddressBook


protocol SLLocationManagerProtocol: class {
    func locationServicesDisabled()
    func authorizationStatusNoAccess()
    func authorizationStatusAccessGranted()
    func autoLocationRecieved()
}

class SLLocationManager: NSObject, CLLocationManagerDelegate {
    
    static let shared = SLLocationManager()
    
    weak var delegate: SLLocationManagerProtocol?
    
    lazy private var locationManager: CLLocationManager = {
        let lm = CLLocationManager()
        lm.delegate = self
        lm.distanceFilter = kCLDistanceFilterNone
        lm.desiredAccuracy = kCLLocationAccuracyBest
        return lm
    }()
    
    var location: CLLocation?
    var address: String?

    
    deinit {
        locationManager.stopUpdatingLocation()
    }
    
    func startUpdatingLocation() {
        DispatchQueue.main.async {
            self.locationManager.startUpdatingLocation()
        }
    }
    
    func stopUpdatingLocation() {
        DispatchQueue.main.async {
            self.locationManager.stopUpdatingLocation()
        }
    }
    
    func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            let status = CLLocationManager.authorizationStatus()
            
            switch status {
            case .notDetermined:
                locationManager.requestAlwaysAuthorization()
            case .restricted, .denied:
                delegate?.authorizationStatusNoAccess()
            case .authorizedAlways, .authorizedWhenInUse:
                delegate?.authorizationStatusAccessGranted()
            }
            
        } else {
            delegate?.locationServicesDisabled()
        }
    }
    
    func locationServicesEnabled() -> Bool {
        if CLLocationManager.locationServicesEnabled() {
            let status = CLLocationManager.authorizationStatus()
            
            switch status {
            case .notDetermined:
                return false
            case .restricted, .denied:
                return false
            case .authorizedAlways, .authorizedWhenInUse:
                return true
            }
        } else {
            return false
        }
    }
    
    func geocode(latitude: Double, longitude: Double, completion: @escaping (CLPlacemark?, Error?) -> ())  {
        CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: latitude, longitude: longitude)) { placemarks, error in
            guard let placemark = placemarks?.first, error == nil else {
                completion(nil, error)
                return
            }
            completion(placemark, nil)
        }
    }
    
    // MARK: - CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let currentLocation = locations.last {
            location = currentLocation
            
            
            geocode(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude) { placemark, error in
                guard let placemark = placemark, error == nil else { return }
                
        
                self.address = "\(placemark.locality ?? "")  \(placemark.thoroughfare ?? "") \(placemark.subThoroughfare ?? "")"
                    
                self.delegate?.autoLocationRecieved()
                
                
//                print("location updated")
                /*
                 DispatchQueue.main.async {
                 //  update UI here
                 print("address1:", placemark.thoroughfare ?? "")
                 print("address2:", placemark.subThoroughfare ?? "")
                 print("city:",     placemark.locality ?? "")
                 print("state:",    placemark.administrativeArea ?? "")
                 print("zip code:", placemark.postalCode ?? "")
                 print("country:",  placemark.country ?? "")
                 }
                 */
                
            }
        }
        
    }
    
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            delegate?.authorizationStatusAccessGranted()
        }
    }
    
}
