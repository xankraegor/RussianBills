//
//  LocationManager.swift
//  RussianBills
//
//  Created by Xan Kraegor on 16.11.2017.
//  Copyright © 2017 Xan Kraegor. All rights reserved.
//

import Foundation
import MapKit

protocol LocationManagerDelegate: class {
    func locationManager(_ manager: LocationManager, coordinates: CLLocationCoordinate2D)
}

final class LocationManager: NSObject {
    // Singleton
    static let instance = LocationManager()

    private override init() {
    }

    weak var delegate: LocationManagerDelegate?

    lazy var locationManager: CLLocationManager = {
        let lm = CLLocationManager()
        lm.delegate = self
        lm.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        lm.requestWhenInUseAuthorization()
        return lm
    }()

    let geocoder = CLGeocoder()

    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }

    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }

    func geocode(address: String, completion: @escaping (CLPlacemark?) -> Void) {
        let locale = Locale(identifier: "ru_RU")

        let addressInRussia = "Россия, \(address)"

        if #available(iOS 11.0, *) {
            geocoder.geocodeAddressString(addressInRussia, in: nil, preferredLocale: locale) {
                (places, _) in
                if let place = places?.first {
                    return completion(place)
                } else {
                    return completion(nil)
                }
            }
        } else {
            geocoder.geocodeAddressString(addressInRussia, in: nil) {
                (places, _) in
                if let place = places?.first {
                    return completion(place)
                } else {
                    return completion(nil)
                }
            }
        }
    }

}

extension LocationManager: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        delegate?.locationManager(self, coordinates: locations[0].coordinate)
    }

}
