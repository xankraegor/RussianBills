//
//  LocationManager.swift
//  RussianBills
//
//  Created by Xan Kraegor on 16.11.2017.
//  Copyright © 2017 Xan Kraegor. All rights reserved.
//

import Foundation
import MapKit
import CoreLocation

protocol LocationManagerDelegate: class {
    func locationManager(_ manager: LocationManager, coordinates: CLLocationCoordinate2D)
}

final class LocationManager: NSObject {
    // Singletone
    static let instance = LocationManager()
    private override init() {}

    weak var delegate: LocationManagerDelegate?

    lazy var locationManager: CLLocationManager =  {
        let lm = CLLocationManager()
        lm.delegate = self
        lm.desiredAccuracy = kCLLocationAccuracyBest
        lm.requestWhenInUseAuthorization()
        return lm
    }()

    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }

    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }

}

extension LocationManager: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        delegate?.locationManager(self, coordinates: locations[0].coordinate)
    }
    
}
