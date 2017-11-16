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


    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        LocationManager.instance.delegate = self
        LocationManager.instance.startUpdatingLocation()
    }

    deinit {
        LocationManager.instance.stopUpdatingLocation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
