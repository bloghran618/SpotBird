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
import Firebase


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
    @IBOutlet weak var btn_searchADD: UIButton!
    
    
    // MApview Outlets
//    @IBOutlet var mapView: GMSMapView!
    @IBOutlet weak var addrMapView: GMSMapView!
    
    var locationManager = CLLocationManager()
    let CurrentLocMarker = GMSMarker()
    var spotcamera = false
    var type = ""
    
    // Spots variables
    var spots = [Spot]()
    var spotsLoaded = false
    
    // boolean to check if we are editing a spot or addding a spot
    var editMode = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btn_searchADD.layer.cornerRadius = 2
//        btn_searchADD.layer.borderColor = UIColor.blue.cgColor
//        btn_searchADD.layer.borderWidth = 1
        
        self.addrMapView.delegate = self
        self.locationManager.delegate = self
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        CurrentLocMarker.map = self.addrMapView
        addrMapView.settings.myLocationButton = true
        self.locationManager.startMonitoringSignificantLocationChanges()
        self.locationManager.startUpdatingLocation()
        
        self.txt_email.delegate = self
        
        self.hideKeyboardWhenTappedAround()
        
        //   txt_email.layer.borderWidth = 2
        //   txt_email.layer.borderColor = UIColor.cyan.cgColor
        
        view_btm.layer.cornerRadius = 5
        view_btm.layer.masksToBounds = true
//        view_btm.layer.borderWidth = 1
//        view_btm.layer.borderColor = UIColor.black.cgColor
        nextButton.isEnabled = false
        view_types.layer.cornerRadius = 6
        view_types.layer.masksToBounds = true
//        view_types.layer.borderWidth = 1
//        view_types.layer.borderColor = UIColor.black.cgColor
//
        if ((AppState.sharedInstance.activeSpot.address == "") && (AppState.sharedInstance.activeSpot.town == "")) && ((AppState.sharedInstance.activeSpot.zipCode == "") && (AppState.sharedInstance.activeSpot.state == "")) {
            nextButton.isEnabled = false
        }
        else{
            nextButton.isEnabled = true
        }
        
        if AppState.sharedInstance.activeSpot.Email != ""{
            txt_email.text = AppState.sharedInstance.activeSpot.Email
        }
        else{
            txt_email.text = (UserDefaults.standard.value(forKey: "logindata") as! NSDictionary).value(forKey: "") as? String
        }
        
        AppState.sharedInstance.activeSpot.Email = (txt_email.text)!
        
        if AppState.sharedInstance.activeSpot.spot_type == ""{
            
        }
        else if AppState.sharedInstance.activeSpot.spot_type == "Garage"{
            btn1.setImage(UIImage.init(named: "garageParkingSelected"), for: .normal)
        }
        else if AppState.sharedInstance.activeSpot.spot_type == "Street"{
            btn2.setImage(UIImage.init(named: "streetParkingSelected"), for: .normal)
        }
        else if AppState.sharedInstance.activeSpot.spot_type == "Lot"{
            btn3.setImage(UIImage.init(named: "lotParkingSelected"), for: .normal)
        }
        else{
            bnt4.setImage(UIImage.init(named: "drivewayParkingSelected"), for: .normal)
        }
        
        // check if we are in edit mode or add mode
        if (AppState.sharedInstance.activeSpot.longitude == "0" && AppState.sharedInstance.activeSpot.latitude == "0") {
            editMode = false
        }
        else {
            editMode = true
        }
        
        // update "Search Google Maps" banner if in edit mode
        if (editMode) {
            self.btn_searchADD.setTitle("\(AppState.sharedInstance.activeSpot.address)", for: .normal)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.getAllSpots()
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
//        self.mapView.layer.borderWidth = 1
//        self.mapView.layer.borderColor = UIColor(red:222/255, green:225/255, blue:227/255, alpha: 1).cgColor
        
    }
    
    // select Spot type -
    @IBAction func btn_TYPE(_ sender: Any) {
        
          nextButton.isEnabled = true
        
        // garageParking, garageParkingSelected, streetParking, streetParkingSelected, lotParking, lotParkingSelected, drivewayParking, drivewayParkingSelected
        
        if (sender as AnyObject).titleLabel?.text == "Garage"{
            type = "Garage"
            btn1.setImage(UIImage.init(named: "garageParkingSelected"), for: .normal)
            
            btn2.setImage(UIImage.init(named: "streetParking"), for: .normal)
            btn3.setImage(UIImage.init(named: "lotParking"), for: .normal)
            bnt4.setImage(UIImage.init(named: "drivewayParking"), for: .normal)
        }
        else if (sender as AnyObject).titleLabel?.text == "Street"{
            type = "Street"
            btn2.setImage(UIImage.init(named: "streetParkingSelected"), for: .normal)
            
            btn3.setImage(UIImage.init(named: "lotParking"), for: .normal)
            bnt4.setImage(UIImage.init(named: "drivewayParking"), for: .normal)
            btn1.setImage(UIImage.init(named: "garageParking"), for: .normal)
        }
        else if (sender as AnyObject).titleLabel?.text == "Lot"{
            type = "Lot"
            btn3.setImage(UIImage.init(named: "lotParkingSelected"), for: .normal)
            
            bnt4.setImage(UIImage.init(named: "drivewayParking"), for: .normal)
            btn1.setImage(UIImage.init(named: "garageParking"), for: .normal)
            btn2.setImage(UIImage.init(named: "streetParking"), for: .normal)
        }
        else{
            type = "Driveway"
            bnt4.setImage(UIImage.init(named: "drivewayParkingSelected"), for: .normal)
            
            btn1.setImage(UIImage.init(named: "garageParking"), for: .normal)
            btn2.setImage(UIImage.init(named: "streetParking"), for: .normal)
            btn3.setImage(UIImage.init(named: "lotParking"), for: .normal)
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
        
       // nextButton.isEnabled = false
        return true
    }
    
    // Behavior when you click outside of the text box
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text != ""{
             AppState.sharedInstance.activeSpot.Email = textField.text!
       }
    }
    
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    func getAllSpots(){
        
        // reference database
        let ref = Database.database().reference().child("All_Spots")
        ref.observe(DataEventType.value, with: { (snapshot) in
            for artists in snapshot.children.allObjects as! [DataSnapshot] {
//                print("The artists is: \(artists)")
                let snapshotValue = snapshot.value as! NSDictionary
                let dictdata = ((snapshot.value as! NSDictionary).value(forKey: (artists as! DataSnapshot).key)) as! NSDictionary
                for(key, spot) in dictdata {
                    // get each public spot
                    print("The spot as a dict is: \(spot)")
                    self.spots.append(Spot(
                        address: (spot as! NSDictionary).value(forKey: "address") as! String,
                        town: (spot as! NSDictionary).value(forKey: "city") as! String,
                        state: (spot as! NSDictionary).value(forKey: "state") as! String,
                        zipCode: (spot as! NSDictionary).value(forKey: "zipcode") as! String,
                        spotImage: "", description: "", monStartTime: "", monEndTime: "", tueStartTime: "", tueEndTime: "", wedStartTime: "", wedEndTime: "", thuStartTime: "", thuEndTime: "", friStartTime: "", friEndTime: "", satStartTime: "", satEndTime: "", sunStartTime: "", sunEndTime: "", monOn: false, tueOn: false, wedOn: false, thuOn: false, friOn: false, satOn: false, sunOn: false, hourlyPricing: "", dailyPricing: "", weeklyPricing: "", monthlyPricing: "", weeklyOn: false, monthlyOn: false, index: 0, approved: false, spotImages: UIImage(named: "white")!, spots_id: "", latitude: "", longitude: "", spottype: "", owner_id: "", Email: "", baseprice: "")!)
                }
            }
            self.spotsLoaded = true
        })
    }
    
    // User clicks "Next", check that there is a spot and it is not already listed
    @IBAction func NextButtonClicked(_ sender: Any) {
        
        // check if there is an active spot
        if (AppState.sharedInstance.activeSpot.address == "") {
            // present an alert to the user to let them know they did not select a spot
            let alert = UIAlertController(title: "No Spot", message: "Please use the 'Spot Address' bar to find a spot", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
        }
        else {
            var doesSpotExist = false
            
            if (!self.editMode) {
                // check if the active spot address matches with any existing spots in the database
                print("Number Spots: \n\n\(self.spots.count)")
                for spot in self.spots {
                    print("Spot.address: \(spot.address)")
                    print("Spot.town: \(spot.town)")
                    if (AppState.sharedInstance.activeSpot.address == spot.address &&
                        AppState.sharedInstance.activeSpot.town == spot.town &&
                        AppState.sharedInstance.activeSpot.zipCode == spot.zipCode) &&
                        AppState.sharedInstance.activeSpot.state == spot.state {
                        
                        doesSpotExist = true
                    }
                }
            }
            
            if doesSpotExist {
                // present an alert to the user to let them know the spot exists
                let alert = UIAlertController(title: "Spot Exists", message: "This spot already exists in our database, please list a new spot", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true)
            }
            else {
                // if the spot does not exist, go to the next screen
                self.performSegue(withIdentifier: "provideImageSegue", sender: self)
            }
        }
    }
}

// ADD NEW FUNCTIONALITY MAP : -
extension AddressViewController {
    // MARK:- locationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = locations.last
        self.CurrentLocMarker.position = (location?.coordinate)!
      //  self.CurrentLocMarker.title = "myLoc"
        var markerView = UIImageView()
        markerView = UIImageView(image: UIImage.init(named: "current_location_icon"))
        markerView.frame.size.width = 30
        markerView.frame.size.height = 30
        self.CurrentLocMarker.iconView = markerView
        self.CurrentLocMarker.map = self.addrMapView
        
        if spotcamera == false {
            let camera = GMSCameraPosition.camera(withLatitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!, zoom:18)
            self.addrMapView.animate(to: camera)
        }
        self.locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
    // MARK:- googleMapsDelegate
    func addrMapView(_ addrMapView: GMSMapView, idleAt position: GMSCameraPosition) {
        print("idle tap infor wirndow markers")
    }
    
    func addrMapView(_ addrMapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        
    }
    
    func didTapMyLocationButton(for addrMapView: GMSMapView) -> Bool {
        spotcamera = false
        self.locationManager.startUpdatingLocation()
        return true
    }
    
    func addrMapView(_ addrMapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        return true
    }
    
    func addrMapView(_ addrMapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        
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
            AppState.sharedInstance.activeSpot.address =  makeaddress.replacingOccurrences(of: ",", with: " ")
            self.btn_searchADD.setTitle("\(AppState.sharedInstance.activeSpot.address)", for: .normal)
        }
       
        if makeaddress == "" {
            let cordinate:[String: CLLocationCoordinate2D] = ["cordinate": place.coordinate]
            let geocoder = GMSGeocoder()
            geocoder.reverseGeocodeCoordinate(place.coordinate) { response , error in
                
                //Add this line
                if let address = response!.firstResult() {
                    print(address)
                    
                    if AppState.sharedInstance.activeSpot.zipCode == ""{
                       if (address.postalCode != nil)
                       {
                        print(address.postalCode as Any)
                        AppState.sharedInstance.activeSpot.zipCode = address.postalCode!
                        }
                    }
                    let lines = address.lines! as [String]
                    if address.thoroughfare == nil{
                        if address.subLocality != nil{
                            
                            AppState.sharedInstance.activeSpot.address = address.subLocality!
                            // self.title = "\(AppState.sharedInstance.activeSpot.address) \(AppState.sharedInstance.activeSpot.town)"
                            let addressfull = "\(AppState.sharedInstance.activeSpot.address) \(AppState.sharedInstance.activeSpot.town)"
                            self.btn_searchADD.setTitle("\(addressfull.replacingOccurrences(of: ",", with: ""))", for: .normal)
                        }
                    }
                    else{
                        if address.thoroughfare == "Unnamed Road"{
                            if address.subLocality != nil{
                                
                                AppState.sharedInstance.activeSpot.address = address.subLocality!
                                //    self.title  = "\(AppState.sharedInstance.activeSpot.address) \(AppState.sharedInstance.activeSpot.town)"
                                //   self.btn_searchADD.setTitle("\(AppState.sharedInstance.activeSpot.address) \(AppState.sharedInstance.activeSpot.town)", for: .normal)
                                let addressfull = "\(AppState.sharedInstance.activeSpot.address) \(AppState.sharedInstance.activeSpot.town)"
                                self.btn_searchADD.setTitle("\(addressfull.replacingOccurrences(of: ",", with: ""))", for: .normal)
                            }
                            else{
                                AppState.sharedInstance.activeSpot.address = address.locality!
                                //  self.btn_searchADD.setTitle("\(AppState.sharedInstance.activeSpot.address)", for: .normal)
                                let addressfull = "\(AppState.sharedInstance.activeSpot.address)"
                                self.btn_searchADD.setTitle("\(addressfull.replacingOccurrences(of: ",", with: ""))", for: .normal)
                            }
                        }else{
                            AppState.sharedInstance.activeSpot.address = address.thoroughfare!
                            //  self.title  = "\(AppState.sharedInstance.activeSpot.address) \(AppState.sharedInstance.activeSpot.town)"
                            let addressfull = "\(AppState.sharedInstance.activeSpot.address) \(AppState.sharedInstance.activeSpot.town)"
                            self.btn_searchADD.setTitle("\(addressfull.replacingOccurrences(of: ",", with: ""))", for: .normal)
                            
                        }
                    }
                }
            }
        }
        
        addrMapView.clear()
        self.CurrentLocMarker.position = (place.coordinate)
    //  self.CurrentLocMarker.title = AppState.sharedInstance.activeSpot.town
        var markerView = UIImageView()
        markerView = UIImageView(image: UIImage.init(named: "current_location_icon"))
        markerView.frame.size.width = 30
        markerView.frame.size.height = 30
        self.CurrentLocMarker.iconView = markerView
        self.CurrentLocMarker.map = self.addrMapView
        
        let camera = GMSCameraPosition.camera(withLatitude: (place.coordinate.latitude), longitude: (place.coordinate.longitude), zoom:18)
    //  self.mapView.animate(to: camera)
        addrMapView.camera = camera
        
        if txt_email.text != ""{
            self.nextButton.isEnabled = true
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

