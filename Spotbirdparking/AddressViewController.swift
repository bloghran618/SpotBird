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
    
    @IBOutlet weak var txt_email: UITextField!
    @IBOutlet weak var btn_spot_type: UIButton!
    @IBOutlet weak var view_btm: UIView!
    @IBOutlet weak var nextButton: UIBarButtonItem!
    
    @IBOutlet weak var btn1: UIButton!
    @IBOutlet weak var btn2: UIButton!
    @IBOutlet weak var btn3: UIButton!
    @IBOutlet weak var bnt4: UIButton!
    @IBOutlet weak var view_types: UIView!
    
    
    // MApview Outlets
    @IBOutlet var mapView: GMSMapView!
    
    var locationManager = CLLocationManager()
    let CurrentLocMarker = GMSMarker()
    
    var spotcamera = false
    
    var type = ""
    
    
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
        
        self.txt_email.delegate = self
        
        self.hideKeyboardWhenTappedAround()
        
        
        txt_email.layer.borderWidth = 2
        txt_email.layer.borderColor = UIColor.cyan.cgColor
        
        view_btm.layer.cornerRadius = 5
        view_btm.layer.masksToBounds = true
        view_btm.layer.borderWidth = 1
        view_btm.layer.borderColor = UIColor.black.cgColor
        nextButton.isEnabled = false
        
        
        
        view_types.layer.cornerRadius = 6
        view_types.layer.masksToBounds = true
        view_types.layer.borderWidth = 1
        view_types.layer.borderColor = UIColor.black.cgColor
        
        
       
        
        if ((AppState.sharedInstance.activeSpot.address == "") && (AppState.sharedInstance.activeSpot.town == "")) && ((AppState.sharedInstance.activeSpot.zipCode == "") && (AppState.sharedInstance.activeSpot.state == "")) {
            nextButton.isEnabled = false
        }
        else{
            nextButton.isEnabled = true
        }
        
        txt_email.text = (UserDefaults.standard.value(forKey: "logindata") as! NSDictionary).value(forKey: "email") as? String
        
        if AppState.sharedInstance.activeSpot.spot_type == ""{
            borders(button: btn1)
            borders(button: btn2)
            borders(button: btn3)
            borders(button: bnt4)
        }
        else if AppState.sharedInstance.activeSpot.spot_type == "Garage"{
            btn1.setTitleColor(UIColor.white, for: .normal)
            btn1.layer.backgroundColor = UIColor.black.cgColor
            borders(button: btn2)
            borders(button: btn3)
            borders(button: bnt4)
        }
        else if AppState.sharedInstance.activeSpot.spot_type == "Lot"{
            btn3.setTitleColor(UIColor.white, for: .normal)
            btn3.layer.backgroundColor = UIColor.black.cgColor
            borders(button: btn1)
            borders(button: btn2)
            borders(button: bnt4)
        }
        else if AppState.sharedInstance.activeSpot.spot_type == "Street"{
            btn2.setTitleColor(UIColor.white, for: .normal)
            btn2.layer.backgroundColor = UIColor.black.cgColor
            borders(button: btn1)
            borders(button: btn3)
            borders(button: bnt4)
        }else{
            bnt4.setTitleColor(UIColor.white, for: .normal)
            bnt4.layer.backgroundColor = UIColor.black.cgColor
            borders(button: btn1)
            borders(button: btn3)
            borders(button: btn2)
        }
        
    }
    
    func borders(button:UIButton){
        button.layer.cornerRadius = 5
        button.layer.masksToBounds = true
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.backgroundColor = UIColor.white.cgColor
        button.setTitleColor(UIColor.black, for: .normal)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.mapView.layer.borderWidth = 1
        self.mapView.layer.borderColor = UIColor(red:222/255, green:225/255, blue:227/255, alpha: 1).cgColor
        
    }
    
    
    
    // select Spot type -
    @IBAction func btn_TYPE(_ sender: Any) {
        
        if (sender as AnyObject).titleLabel?.text == "Garage"{
            btn1.setTitleColor(UIColor.white, for: .normal)
            btn1.layer.backgroundColor = UIColor.black.cgColor
            type = "Garage"
            borders(button: btn2)
            borders(button: btn3)
            borders(button: bnt4)
        }
        else if (sender as AnyObject).titleLabel?.text == "Lot"{
            btn3.setTitleColor(UIColor.white, for: .normal)
            btn3.layer.backgroundColor = UIColor.black.cgColor
            type = "Lot"
            borders(button: btn1)
            borders(button: btn2)
            borders(button: bnt4)
        }
        else if (sender as AnyObject).titleLabel?.text == "Street"{
            btn2.setTitleColor(UIColor.white, for: .normal)
            btn2.layer.backgroundColor = UIColor.black.cgColor
            type = "Street"
            borders(button: btn1)
            borders(button: btn3)
            borders(button: bnt4)
        }else{
            bnt4.setTitleColor(UIColor.white, for: .normal)
            bnt4.layer.backgroundColor = UIColor.black.cgColor
            type = "Other"
            borders(button: btn1)
            borders(button: btn3)
            borders(button: btn2)
        }
        AppState.sharedInstance.activeSpot.spot_type = type
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
        
        nextButton.isEnabled = false
        
        return true
    }
    
    // Behavior when you click outside of the text box
    func textFieldDidEndEditing(_ textField: UITextField) {
        
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
        
        spotcamera = true
        AppState.sharedInstance.activeSpot.latitude = String(place.coordinate.latitude)
        AppState.sharedInstance.activeSpot.longitude =  String(place.coordinate.longitude)
        var makeaddress = String()
        
        for component in place.addressComponents!  {
            
            
            if component.type == "street_number" {
                makeaddress.append("\(component.name),")
            }
            if component.type == "route" {
                makeaddress.append("\(component.name),")
            }
            if component.type == "neighborhood" {
                makeaddress.append("\(component.name),")
            }
            
            if component.type == "locality" {
                
                AppState.sharedInstance.activeSpot.town = component.name
            }
            if component.type == "administrative_area_level_1" {
                
                AppState.sharedInstance.activeSpot.state = component.name
            }
            if component.type == "postal_code" {
                
                AppState.sharedInstance.activeSpot.zipCode = component.name
            }
            
        }
        
        if makeaddress.last == ","
        {
            makeaddress.removeLast()
        }
        
        
        if makeaddress == "" {
            let cordinate:[String: CLLocationCoordinate2D] = ["cordinate": place.coordinate]
            let geocoder = GMSGeocoder()
            geocoder.reverseGeocodeCoordinate(place.coordinate) { response , error in
                
                //Add this line
                if let address = response!.firstResult() {
                    print(address)
                    
                    if AppState.sharedInstance.activeSpot.zipCode == ""{
                        
                        AppState.sharedInstance.activeSpot.zipCode = address.postalCode!
                    }
                    let lines = address.lines! as [String]
                    if address.thoroughfare == nil{
                        if address.subLocality != nil{
                            
                            AppState.sharedInstance.activeSpot.address = address.subLocality!
                        }
                    }
                    else{
                        if address.thoroughfare == "Unnamed Road"{
                            if address.subLocality != nil{
                                
                                AppState.sharedInstance.activeSpot.address = address.subLocality!
                            }
                        }else{
                            AppState.sharedInstance.activeSpot.address = address.thoroughfare!
                        }
                    }
                }
            }
        }
        
        
        mapView.clear()
        self.CurrentLocMarker.position = (place.coordinate)
        self.CurrentLocMarker.title = AppState.sharedInstance.activeSpot.town
        var markerView = UIImageView()
        markerView = UIImageView(image: UIImage.init(named: "current_location_icon"))
        markerView.frame.size.width = 30
        markerView.frame.size.height = 30
        self.CurrentLocMarker.iconView = markerView
        self.CurrentLocMarker.map = self.mapView
        
        let camera = GMSCameraPosition.camera(withLatitude: (place.coordinate.latitude), longitude: (place.coordinate.longitude), zoom:12)
        //  self.mapView.animate(to: camera)
        mapView.camera = camera
        
        self.nextButton.isEnabled = true
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

