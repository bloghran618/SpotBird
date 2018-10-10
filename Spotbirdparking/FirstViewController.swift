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
import Alamofire
import Firebase
import Photos
import GooglePlaces
import GooglePlacePicker

class FirstViewController: UIViewController,CLLocationManagerDelegate,GMSMapViewDelegate,GMSAutocompleteViewControllerDelegate{
    
    @IBOutlet var mapView: GMSMapView!
    
    var locationManager = CLLocationManager()
    let CurrentLocMarker = GMSMarker()
    var timerAnimation: Timer!
    var refArtists: DatabaseReference!
    var userlatitude:Double  = Double()
    var userlongitude:Double  = Double()
    var markerlatitude:Double  = Double()
    var markerlongitude:Double  = Double()
    var arrspot:NSMutableArray = NSMutableArray()
    var timer = Timer()  // time
    var five = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //scheduledTimerWithTimeInterval()  // time
        
        //  getlatlong()
        
        self.mapView.delegate = self
        self.locationManager.delegate = self
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        CurrentLocMarker.map = self.mapView
        self.locationManager.startMonitoringSignificantLocationChanges()
        self.locationManager.startUpdatingLocation()
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        
        mapView.padding = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 20)
    }
    
    
    //    func scheduledTimerWithTimeInterval(){
    //        // Scheduling timer to Call the function "updateCounting" with the interval of 1 seconds
    //        timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.updateCounting), userInfo: nil, repeats: true)
    //    }
    //
    //    @objc func updateCounting(){
    //        NSLog("counting..")
    //
    //
    //    }
    
    @IBAction func btn_mapsearch(_ sender: Any) {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        present(autocompleteController, animated: true, completion: nil)
    }
    
    func getlatlong(){
        five = 0
        //   AppState.sharedInstance.userid == ""
        
        refArtists = Database.database().reference().child("Spots");
        refArtists.observe(DataEventType.value, with: { (snapshot) in
            
            if snapshot.childrenCount > 0 {
                for artists in snapshot.children.allObjects as! [DataSnapshot] {
                    let snapshotValue = snapshot.value as! NSDictionary
                    // print(snapshotValue.count)
                    if snapshotValue.count>0{
                        self.arrspot.removeAllObjects()
                        for (theKey, theValue) in snapshotValue {
                            //   print(theValue)
                            self.arrspot.add(theValue)
                        }
                        // print(self.arrspot)
                        //  print(self.arrspot.count)
                        self.loadEventsToMap(lat: self.userlatitude, long: self.userlongitude)
                    }
                }
            }
        })
    }
    
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
        userlatitude = (location?.coordinate.latitude)!
        userlongitude = (location?.coordinate.longitude)!
        //  print(location?.coordinate)
        let camera = GMSCameraPosition.camera(withLatitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!, zoom:12)
        
        //  self.mapView.animate(to: camera)
        mapView.camera = camera
        five = 0
        getlatlong()
        
        
        self.locationManager.stopUpdatingLocation()
        
    }
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
    // MARK:- googleMapsDelegate
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
    }
    
    func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
        
        mapView.clear()
        self.locationManager.startUpdatingLocation()
        return true
        
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        mapView.delegate = self
        if marker.title == "myLoc"
        {
            return true
        }
        mapView.animate(toLocation: ( marker.position))
        mapView.selectedMarker = marker
        return true
    }
    
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        
        markerlatitude = marker.position.latitude
        markerlongitude = marker.position.longitude
        
        let index:Int! = Int(marker.accessibilityLabel!)
        let customInfoWindow = Bundle.main.loadNibNamed("CustomInfoWindow", owner: self, options: nil)?[0] as! CustomInfoWindow
        customInfoWindow.lblTitle.text = (arrspot[index] as! NSDictionary).value(forKey: "address") as? String
        customInfoWindow.lblDetail.text = ((arrspot[index] as! NSDictionary).value(forKey: "city") as? String)! + ((arrspot[index] as! NSDictionary).value(forKey: "state") as? String)!
        
        customInfoWindow.btn_dr.addTarget(self, action: #selector(self.bookbtn1(_:)), for: .touchUpInside);
        self.setBorder(toLayer: customInfoWindow.imgBg.layer, borderColor: UIColor.clear, cornerRad: 30)
        
        customInfoWindow.imgBg.backgroundColor = UIColor.darkGray
        //
        //        customInfoWindow.img.backgroundColor =  UIColor.black
        
        return customInfoWindow
    }
    // marker action
    @objc func bookbtn1(_ sender : UIButton){
        
    }
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        fetchMapData(lat: markerlatitude, long: markerlongitude)
    }
    // MARK:_ Load Marker to map :-  Spot
    func loadEventsToMap(lat:Double,long:Double){
        
        for i in 0..<arrspot.count {
            
            let coordinate₀ = CLLocation(latitude: CLLocationDegrees(truncating: (arrspot.object(at: i) as! NSDictionary).value(forKey: "user_lat") as! NSNumber), longitude:CLLocationDegrees(truncating: (arrspot.object(at: i) as! NSDictionary).value(forKey: "user_long") as! NSNumber))
            let coordinate₁ = CLLocation(latitude: lat, longitude: long)
            
            let distacneinKM = (coordinate₀.distance(from: coordinate₁)/1000)
            
            if distacneinKM < 5 {
                print("dicstance ------<5 = \(distacneinKM)")
                print(five)
                five = five+1
                if five < 5 {
                    
                    let marker = GMSMarker()
                    
                    marker.position = CLLocationCoordinate2DMake(Double(truncating: (arrspot.object(at: i) as! NSDictionary).value(forKey: "user_lat") as! NSNumber), Double(truncating: (arrspot.object(at: i) as! NSDictionary).value(forKey: "user_long") as! NSNumber))
                    
                    
                    marker.map = self.mapView
                    marker.map = self.mapView
                    //   marker.icon = #imageLiteral(resourceName: "car")
                    
                    marker.snippet = "Test"
                    marker.infoWindowAnchor = CGPoint(x: 0.5, y: 0.2)
                    marker.accessibilityLabel = "\(i)"
                }
            }
        }
    }
    
    func draw(_ rect: CGRect ,img : UIImageView) {
        
        // Get Height and Width
        let layerHeight = img.frame.height
        let layerWidth = img.frame.width
        
        // Create Path
        let bezierPath = UIBezierPath()
        
        // Draw Points
        bezierPath.move(to: CGPoint(x: 0, y: layerHeight))
        bezierPath.addLine(to: CGPoint(x: layerWidth, y: layerHeight))
        bezierPath.addLine(to: CGPoint(x: layerWidth / 2, y: 0))
        bezierPath.addLine(to: CGPoint(x: 0, y: layerHeight))
        bezierPath.close()
        
        // Apply Color
        UIColor.green.setFill()
        bezierPath.fill()
        
        // Mask to Path
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = bezierPath.cgPath
        img.layer.mask = shapeLayer
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func fetchMapData(lat:Double,long:Double) {
        
        let directionURL = "https://maps.googleapis.com/maps/api/directions/json?" +
            "origin=\(userlatitude),\(userlongitude)&destination=\(lat),\(long)&" +
        "key=AIzaSyAuvDkP5Eo-SRLVsadPd89b_nR_vn3cchM"
        
        Alamofire.request(directionURL).responseJSON
            { response in
                
                
                
                if let JSON = response.result.value {
                    let mapResponse: [String: AnyObject] = JSON as! [String : AnyObject]
                    let routesArray = (mapResponse["routes"] as? Array) ?? []
                    let routes = (routesArray.first as? Dictionary<String, AnyObject>) ?? [:]
                    let overviewPolyline = (routes["overview_polyline"] as? Dictionary<String,AnyObject>) ?? [:]
                    let polypoints = (overviewPolyline["points"] as? String) ?? ""
                    let line  = polypoints
                    
                    self.drawRoute(encodedString: line, animated: false)
                }
        }
    }
    
    func drawRoute(encodedString: String, animated: Bool) {
        
        if let path = GMSMutablePath(fromEncodedPath: encodedString) {
            
            let polyline = GMSPolyline(path: path)
            polyline.strokeWidth = 5.0
            // polyline.strokeColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
            polyline.strokeColor = UIColor.black
            polyline.map = mapView
            
            if(animated){
                self.animatePolylinePath(path: path)
            }
        }
    }
    
    func animatePolylinePath(path: GMSMutablePath) {
        var pos: UInt = 0
        var animationPath = GMSMutablePath()
        let animationPolyline = GMSPolyline()
        self.timerAnimation = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            
            pos += 1
            if(pos >= path.count()){
                pos = 0
                animationPath = GMSMutablePath()
                animationPolyline.map = nil
            }
            animationPath.add(path.coordinate(at: pos))
            animationPolyline.path = animationPath
            animationPolyline.strokeColor = UIColor.blue
            animationPolyline.strokeWidth = 4
            animationPolyline.map = self.mapView
        }
    }
    
    func stopAnimatePolylinePath() {
        self.timerAnimation.invalidate()
    }
    
    func setBorder(toLayer : CALayer,borderColor : UIColor , cornerRad: Int)
    {
        toLayer.borderWidth = 1.0
        toLayer.borderColor = borderColor.cgColor
        toLayer.cornerRadius = CGFloat(cornerRad)
    }
    
    //MARK:_ GMSAutocompleteViewController
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        //        print("Place name: \(place.name)")
        //        print("Place name: \(place.coordinate)")
        //        print("Place address: \(String(describing: place.formattedAddress))")
        //        print("Place attributions: \(String(describing: place.attributions))")
        dismiss(animated: true, completion: nil)
        
        let cordinate:[String: CLLocationCoordinate2D] = ["cordinate": place.coordinate]
        
        place.coordinate.latitude
        place.coordinate.longitude
        
        mapView.clear()
        
        var markerView = UIImageView()
        markerView = UIImageView(image: UIImage.init(named: "current_location_icon"))
        markerView.frame.size.width = 30
        markerView.frame.size.height = 30
        self.CurrentLocMarker.iconView = markerView
        self.CurrentLocMarker.map = self.mapView
        
        let camera = GMSCameraPosition.camera(withLatitude: (place.coordinate.latitude), longitude: (place.coordinate.longitude), zoom:12)
        
        //  self.mapView.animate(to: camera)
        mapView.camera = camera
        five = 0
        loadEventsToMap(lat: place.coordinate.latitude, long:place.coordinate.longitude)
        
    }
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
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
    
    
    /*
     // MARK:_ DISTANCE :_
     func deg2rad(deg:Double) -> Double {
     return deg * M_PI / 180
     }
     
     
     func rad2deg(rad:Double) -> Double {
     return rad * 180.0 / M_PI
     }
     
     func distance(lat1:Double, lon1:Double, lat2:Double, lon2:Double, unit:String) -> Double {
     let theta = lon1 - lon2
     var dist = sin(deg2rad(deg: lat1)) * sin(deg2rad(deg: lat2)) + cos(deg2rad(deg: lat1)) * cos(deg2rad(deg: lat2)) * cos(deg2rad(deg: theta))
     dist = acos(dist)
     dist = rad2deg(rad: dist)
     dist = dist * 60 * 1.1515
     if (unit == "K") {
     dist = dist * 1.609344
     }
     else if (unit == "N") {
     dist = dist * 0.8684
     }
     
     print(dist)
     return dist
     }
     */
    
    
    
}

