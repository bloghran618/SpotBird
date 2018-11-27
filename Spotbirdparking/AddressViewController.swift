//
//  AddressViewController.swift
//  Spotbirdparking
//
//  Created by user138340 on 7/10/18.
//  Copyright © 2018 Spotbird. All rights reserved.
//

import UIKit
import CoreLocation
import GoogleMaps
import Alamofire
import Firebase
import Photos
import GooglePlaces
import GooglePlacePicker
import GooglePlaces

class AddressViewController: UIViewController, UITextFieldDelegate,CLLocationManagerDelegate,GMSMapViewDelegate,GMSAutocompleteViewControllerDelegate{
    
    @IBOutlet weak var addressField: UITextField!
    @IBOutlet weak var townField: UITextField!
    @IBOutlet weak var stateField: UITextField!
    @IBOutlet weak var zipField: UITextField!
    @IBOutlet weak var nextButton: UIBarButtonItem!
    
    // MApview Outlets
    @IBOutlet var mapView: GMSMapView!
    
    var locationManager = CLLocationManager()
    let CurrentLocMarker = GMSMarker()
    
    var spotcamera = false
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mapView.delegate = self
        self.locationManager.delegate = self
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        CurrentLocMarker.map = self.mapView
        mapView.settings.myLocationButton = true
        self.locationManager.startMonitoringSignificantLocationChanges()
        self.locationManager.startUpdatingLocation()
        
        self.addressField.delegate = self
        self.townField.delegate = self
        self.stateField.delegate = self
        self.zipField.delegate = self
        
        self.hideKeyboardWhenTappedAround()
        
        addressField.text = AppState.sharedInstance.activeSpot.address
        townField.text = AppState.sharedInstance.activeSpot.town
        stateField.text = AppState.sharedInstance.activeSpot.state
        zipField.text = AppState.sharedInstance.activeSpot.zipCode
        
        
     if ((AppState.sharedInstance.activeSpot.address == "") && (AppState.sharedInstance.activeSpot.town == "")) && ((AppState.sharedInstance.activeSpot.zipCode == "") && (AppState.sharedInstance.activeSpot.state == "")) {
            nextButton.isEnabled = false
         }
     }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.mapView.layer.borderWidth = 1
        self.mapView.layer.borderColor = UIColor(red:222/255, green:225/255, blue:227/255, alpha: 1).cgColor
      }
    
    // Button Search :-
    @IBAction func Address_search(_ sender: Any) {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        present(autocompleteController, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // Behavior when you hit return on keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == addressField {
            self.addressField.resignFirstResponder()
            AppState.sharedInstance.activeSpot.address = addressField.text!
        }
        else if textField == townField {
            self.townField.resignFirstResponder()
            AppState.sharedInstance.activeSpot.town = townField.text!
        }
        else if textField == stateField {
            self.stateField.resignFirstResponder()
            AppState.sharedInstance.activeSpot.state = stateField.text!
        }
        else if textField == zipField {
            self.zipField.resignFirstResponder()
            AppState.sharedInstance.activeSpot.zipCode = zipField.text!
        }
        
        if ((AppState.sharedInstance.activeSpot.address != "") && (AppState.sharedInstance.activeSpot.town != "")) && ((AppState.sharedInstance.activeSpot.zipCode != "") && (AppState.sharedInstance.activeSpot.state != "")) {
            nextButton.isEnabled = true
        }
        else {
            nextButton.isEnabled = false
        }
        return true
    }
    
    // Behavior when you click outside of the text box
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == addressField {
            self.addressField.resignFirstResponder()
            AppState.sharedInstance.activeSpot.address = addressField.text!
        }
        else if textField == townField {
            self.townField.resignFirstResponder()
            AppState.sharedInstance.activeSpot.town = townField.text!
        }
        else if textField == stateField {
            self.stateField.resignFirstResponder()
            AppState.sharedInstance.activeSpot.state = stateField.text!
        }
        else if textField == zipField {
            self.zipField.resignFirstResponder()
            AppState.sharedInstance.activeSpot.zipCode = zipField.text!
        }
        
        if ((AppState.sharedInstance.activeSpot.address != "") && (AppState.sharedInstance.activeSpot.town != "")) && ((AppState.sharedInstance.activeSpot.zipCode != "") && (AppState.sharedInstance.activeSpot.state != "")) {
            nextButton.isEnabled = true
        }
        else {
            nextButton.isEnabled = false
        }
    }
}

// ADD NEW FUNCTIONALITY MAP : -
extension AddressViewController {
    
    
    
    // MARK:- locationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = locations.last
        
        self.CurrentLocMarker.position = (location?.coordinate)!
        self.CurrentLocMarker.title = "myLoc"
        var markerView = UIImageView()
        markerView = UIImageView(image: UIImage.init(named: "current_location_icon"))
        markerView.frame.size.width = 30
        markerView.frame.size.height = 30
        self.CurrentLocMarker.iconView = markerView
        self.CurrentLocMarker.map = self.mapView
        
        if spotcamera == false {
        let camera = GMSCameraPosition.camera(withLatitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!, zoom:12)
        self.mapView.animate(to: camera)
        }
         self.locationManager.stopUpdatingLocation()
        
    if ((AppState.sharedInstance.activeSpot.address != "") && (AppState.sharedInstance.activeSpot.town != "")) && ((AppState.sharedInstance.activeSpot.zipCode != "") && (AppState.sharedInstance.activeSpot.state != "")) {
        
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: AppState.sharedInstance.activeSpot.latitude, longitude: AppState.sharedInstance.activeSpot.longitude)
        marker.map = self.mapView
        let price =  AppState.sharedInstance.activeSpot.hourlyPricing
        var doller = String()
        for (index, character) in price.enumerated() {
            if index < 4 {
                doller.append(character)
            }
        }
        var markerimg = UIImageView()
        let customView = UIView()
        customView.frame = CGRect.init(x: 0, y: 0, width: 60, height: 60)
        markerimg  = UIImageView(frame:CGRect(x:0, y:0, width:60, height:60));
        markerimg.image = UIImage(named:"markers")
        markerimg.backgroundColor = UIColor.clear
        customView.addSubview(markerimg)
        let lbl_marker = UILabel()
        lbl_marker.frame = CGRect(x: 0, y: (markerimg.frame.height/2)-25, width: markerimg.frame.width, height: 40)
        markerimg.addSubview(lbl_marker)
        lbl_marker.textAlignment = .center
        lbl_marker.numberOfLines = 1;
        
        
        lbl_marker.text = "$\(doller)"
        
        lbl_marker.minimumScaleFactor = 0.5;
        lbl_marker.adjustsFontSizeToFitWidth = true;
        lbl_marker.textColor = UIColor.black
        customView.backgroundColor = UIColor.clear
        marker.iconView = customView
        
        if spotcamera == true {
        let camera = GMSCameraPosition.camera(withLatitude: (AppState.sharedInstance.activeSpot.latitude), longitude: (AppState.sharedInstance.activeSpot.longitude), zoom:12)
        self.mapView.animate(to: camera)
        spotcamera = false
        }
    }
 }
    
   func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
    // MARK:- googleMapsDelegate
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        print("idle tap infor wirndow markers")
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
    
    }
    
    func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
        spotcamera = false
        self.locationManager.startUpdatingLocation()
        return true
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
      return true
    }
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        
    }
    
    //MARK:_ GMSAutocompleteViewController
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        dismiss(animated: true, completion: nil)
        mapView.clear()
        spotcamera = true
        AppState.sharedInstance.activeSpot.latitude = place.coordinate.latitude
        AppState.sharedInstance.activeSpot.longitude = place.coordinate.longitude
 
        let cordinate:[String: CLLocationCoordinate2D] = ["cordinate": place.coordinate]
        
       let geocoder = GMSGeocoder()
            geocoder.reverseGeocodeCoordinate(place.coordinate) { response , error in
            
          //Add this line
                if let address = response!.firstResult() {
                    
              let lines = address.lines! as [String]
                print(lines)
                print(address.thoroughfare)
                    if address.thoroughfare == nil{
                      self.addressField.text = address.subLocality
                        AppState.sharedInstance.activeSpot.address = address.subLocality!
                    }
                    else{
                        if address.thoroughfare == "Unnamed Road"{
                            self.addressField.text = address.subLocality
                            AppState.sharedInstance.activeSpot.address = address.subLocality!
                        }else{
                      self.addressField.text = address.thoroughfare
                     AppState.sharedInstance.activeSpot.address = address.thoroughfare!
                    }
                    }
                   
                self.townField.text = address.locality
                self.stateField.text = address.administrativeArea
                self.zipField.text = address.postalCode
                    
                    
                AppState.sharedInstance.activeSpot.town = address.locality!
                AppState.sharedInstance.activeSpot.state = address.administrativeArea!
                AppState.sharedInstance.activeSpot.zipCode = address.postalCode!
                self.locationManager.startUpdatingLocation()
                    
                    if ((AppState.sharedInstance.activeSpot.address != "") && (AppState.sharedInstance.activeSpot.town != "")) && ((AppState.sharedInstance.activeSpot.zipCode != "") && (AppState.sharedInstance.activeSpot.state != "")) {
                        self.nextButton.isEnabled = true
                    }
                    else {
                        self.nextButton.isEnabled = false
                    }
                }
            }
      }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print("Error: ", error.localizedDescription)
    }
    
    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    func method(arg: Bool, completion: (Bool) -> ()) {
        print("First line of code executed")
        completion(arg)
    }
 }

