//
//  FirstViewController.swift
//  Spotbirdparking
//
//  Created by user138340 on 4/17/18.
//  Copyright © 2018 Spotbird. All rights reserved.
//

import UIKit
import CoreLocation
import GoogleMaps
import GooglePlaces

class FirstViewController: UIViewController, CLLocationManagerDelegate {
    
    //MARK: Properties
    @IBOutlet weak var ProfileNameTextField: UITextField!
    let locationManager = CLLocationManager()
    var mapView: GMSMapView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        enableBasicLocationServices()

        let camera = GMSCameraPosition.camera(withLatitude: 39.95, longitude: -75.16, zoom: 10.0)
        mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        self.view = mapView
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func enableBasicLocationServices() {
        
        let status  = CLLocationManager.authorizationStatus()
        
        // Check initial authorization
        if status == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
            return
        }
        
        // Handle location serviced denied
        if status == .denied || status == .restricted {
            let alert = UIAlertController(title: "Location Services Disabled", message: "Please enable Location Services in Settings", preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            
            present(alert, animated: true, completion: nil)
            return
        }
        
        if status == .authorizedWhenInUse {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {

        if status == .authorizedWhenInUse {
            
            locationManager.startUpdatingLocation()
            mapView.isMyLocationEnabled = true
            mapView.settings.myLocationButton = true
        }
        else {
            locationManager.stopUpdatingLocation()
            mapView.isMyLocationEnabled = false
            mapView.settings.myLocationButton = false
        }
    }
}

