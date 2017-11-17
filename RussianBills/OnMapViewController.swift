//
//  OnMapViewController.swift
//  RussianBills
//
//  Created by Xan Kraegor on 16.11.2017.
//  Copyright © 2017 Xan Kraegor. All rights reserved.
//

import UIKit
import MapKit

class OnMapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!

    var locationToDisplay: CLLocation?
    var nameToDisplay: String?

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        LocationManager.instance.delegate = self
        LocationManager.instance.startUpdatingLocation()

        let latDelta:CLLocationDegrees = 0.01
        let longDelta:CLLocationDegrees = 0.01
        let theSpan:MKCoordinateSpan = MKCoordinateSpanMake(latDelta, longDelta)
        let pointLocation:CLLocationCoordinate2D = locationToDisplay!.coordinate

        let region:MKCoordinateRegion = MKCoordinateRegionMake(pointLocation, theSpan)
        mapView.setRegion(region, animated: true)

        let pinLocation : CLLocationCoordinate2D = locationToDisplay!.coordinate
        let objectAnnotation = MKPointAnnotation()
        objectAnnotation.coordinate = pinLocation
        objectAnnotation.title = nameToDisplay
        self.mapView.addAnnotation(objectAnnotation)
    }

    deinit {
        LocationManager.instance.stopUpdatingLocation()
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension OnMapViewController: LocationManagerDelegate {

    func locationManager(_ manager: LocationManager, coordinates: CLLocationCoordinate2D) {
        print(coordinates)

        let currentRadius: CLLocationDistance = 1000
        let currentRegion = MKCoordinateRegionMakeWithDistance(coordinates, currentRadius * 2, currentRadius * 2)
        mapView.setRegion(currentRegion, animated: false)
        mapView.showsUserLocation = true
    }

}
