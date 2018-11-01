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
import GooglePlaces

class FirstViewController: UIViewController,CLLocationManagerDelegate,GMSMapViewDelegate,UISearchBarDelegate,GMSAutocompleteViewControllerDelegate{
    
    @IBOutlet var mapView: GMSMapView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    // info window:-
    @IBOutlet weak var img_spot: UIImageView!
    @IBOutlet weak var lbl_price: UILabel!
    @IBOutlet weak var lbl_address: UILabel!
    @IBOutlet weak var btn_close: UIButton!
    @IBOutlet weak var btn_book: UIButton!
    @IBOutlet weak var btn_dtls: UIButton!
    @IBOutlet weak var view_info: CustomView!
    
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
    var arrPlaces = NSMutableArray(capacity: 100)
    let operationQueue = OperationQueue()
    let currentLat = 51.5033640
    let currentLong = -0.1276250
    // var LocationDataDelegate : LocationData! = nil
    var tblLocation : UITableView!
    //  var lblNodata = UILabel()
    var hud : MBProgressHUD = MBProgressHUD()
    var placesClient: GMSPlacesClient!
    let customView = UIView()
    var markerimg = UIImageView()
    let lbl_marker = UILabel()
    var curruntlat : Double?
    var curruntlong : Double?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //scheduledTimerWithTimeInterval()  // time
        img_spot.layer.borderWidth = 1
        img_spot.layer.masksToBounds = false
        img_spot.layer.cornerRadius = img_spot.frame.height/2
        img_spot.clipsToBounds = true
        view_info.isHidden = true
        btn_close.isHidden = true
        searchBar.backgroundColor = UIColor.clear
        
        getlatlong()
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
        searchBar.placeholder = "Search here"
        searchBar.delegate = self
        searchBar.resignFirstResponder()
        method(arg: true, completion: { (success) -> Void in
            print("Second line of code executed")
            if success { // this will be equal to whatever value is set in this method call
                print("true")
            } else {
                print("false")
            }
        })
    }
    
    // MARK:_ BTn close
    @IBAction func btn_close(_ sender: UIButton) {
        view_info.isHidden = true
        btn_close.isHidden = true
    }
    
    // MARK:_ BTn details
    @IBAction func btn_Details(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Spotbirdparking", message: "Not Available...!", preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(defaultAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    // MARK:_ BTn booknow
    @IBAction func btn_booknow(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Spotbirdparking", message: "Not Available...!", preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(defaultAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    // MARK:_ BTn Autocomplete loation search
    @IBAction func autocompleteClicked(_ sender: UIButton) {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        present(autocompleteController, animated: true, completion: nil)
    }
    
    // GET ALL SPOT ON MAP
    func getlatlong(){
        
        five = 0
        refArtists = Database.database().reference().child("All_Spots");
        refArtists.observe(DataEventType.value, with: { (snapshot) in
            
            if snapshot.childrenCount > 0 {
                for artists in snapshot.children.allObjects as! [DataSnapshot] {
                    let snapshotValue = snapshot.value as! NSDictionary
                    print(snapshotValue)
                    
                    let dictdata = ((snapshot.value as! NSDictionary).value(forKey: (artists as! DataSnapshot).key)) as! NSDictionary
                    print(dictdata)
                    if dictdata.count>0{
                        self.arrspot.removeAllObjects()
                        for (theKey, theValue) in dictdata {
                            //   print(theValue)
                            self.arrspot.add(theValue)
                        }
                        //self.loadEventsToMap(lat: self.userlatitude, long: self.userlongitude)
                        for i in 0..<self.arrspot.count {
                            let marker = GMSMarker()
                            marker.position = CLLocationCoordinate2DMake(Double(truncating: (self.arrspot.object(at: i) as! NSDictionary).value(forKey: "user_lat") as! NSNumber), Double(truncating: (self.arrspot.object(at: i) as! NSDictionary).value(forKey: "user_long") as! NSNumber))
                            marker.map = self.mapView
                            let price = (self.arrspot.object(at: i) as! NSDictionary).value(forKey: "hourlyPricing") as! String
                            let doller = (price as NSString).integerValue
                            // marker.title = "$\(doller)"
                            //   marker.snippet
                            marker.infoWindowAnchor = CGPoint(x: 0.5, y: 0.2)
                            marker.accessibilityLabel = "\(i)"
                            
                            self.customView.frame = CGRect.init(x: 0, y: 0, width: 60, height: 60)
                            self.markerimg  = UIImageView(frame:CGRect(x:0, y:0, width:60, height:60));
                            self.markerimg.image = UIImage(named:"markers")
                            self.markerimg.backgroundColor = UIColor.clear
                            self.customView.addSubview(self.markerimg)
                            
                            // let label = UILabel(frame: CGRect(x: 0, y: (self.markerimg.frame.height/2)-25, width: self.markerimg.frame.width, height: 40))
                            self.lbl_marker.frame = CGRect(x: 0, y: (self.markerimg.frame.height/2)-25, width: self.markerimg.frame.width, height: 40)
                            
                            self.lbl_marker.textAlignment = .center
                            self.lbl_marker.numberOfLines = 1;
                            self.lbl_marker.minimumScaleFactor = 0.5;
                            self.lbl_marker.adjustsFontSizeToFitWidth = true;
                            self.lbl_marker.text = "$\(doller)"
                            //  label.text = "ASWQQWDGEVCTE"
                            self.lbl_marker.textColor = UIColor.black
                            
                            self.markerimg.addSubview(self.lbl_marker)
                            marker.iconView = self.customView
                            
                        }
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
        AppState.sharedInstance.lat = userlatitude
        AppState.sharedInstance.long = userlongitude
        print(location?.coordinate)
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
        print("idle tap infor wirndow markers")
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        view_info.isHidden = true
        btn_close.isHidden = true
    }
    
    func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
        mapView.clear()
        self.locationManager.startUpdatingLocation()
        return true
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        
        if curruntlat == marker.position.latitude && curruntlong == marker.position.longitude{
            mapView.clear()
            locationManager.startUpdatingLocation()
            view_info.isHidden = true
            btn_close.isHidden = true
            
        }
        else{
            marker.iconView?.removeFromSuperview()
            let viewchange = UIView()
            viewchange.frame = CGRect.init(x: 0, y: 0, width: 80, height: 80)
            markerimg.image = #imageLiteral(resourceName: "marker_blue")
            lbl_marker.textColor = UIColor.white
            viewchange.addSubview(markerimg)
            //mapView.selectedMarker = marker
            marker.iconView = viewchange
            view_info.isHidden = false
            btn_close.isHidden = false
        }
        curruntlat = marker.position.latitude
        curruntlong = marker.position.longitude
        
        let index:Int! = Int(marker.accessibilityLabel!)
        let price  = (arrspot.object(at: index) as! NSDictionary).value(forKey: "hourlyPricing") as?  String
        let doller = (price! as NSString).integerValue
        lbl_price.text = "$\(doller)"
        lbl_address.text = (arrspot.object(at: index) as! NSDictionary).value(forKey: "address") as?  String
        let imgurl = (arrspot.object(at: index) as! NSDictionary).value(forKey: "image") as!  String
        img_spot.sd_setImage(with: URL(string: imgurl), placeholderImage: #imageLiteral(resourceName: "emptySpot"))
        
        return true
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
                    
                    let price = (self.arrspot.object(at: i) as! NSDictionary).value(forKey: "hourlyPricing") as! String
                    let doller = (price as NSString).integerValue
                    //marker.title = "$\(doller)"
                    //     marker.snippet
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
    
    // AIzaSyBXzbFQ7U9PRS-vrl5RR6es5qOeZ4KuKSg ,AIzaSyCvFxAOvA246L6Syk7Cl426254C-sMJGxk,AIzaSyC29rKRcHlAik1UyLD0jYtjC1KIXIRbEkA
    func fetchMapData(lat:Double,long:Double) {
        let directionURL = "https://maps.googleapis.com/maps/api/directions/json?" +
            "origin=\(userlatitude),\(userlongitude)&destination=\(lat),\(long)&" +
        "key=AIzaSyCCPLZoH8d2j7rMFcDufb3S3ueUvO-c8vU"
        
        Alamofire.request(directionURL).responseJSON
            { response in
                print(response)
                if let JSON = response.result.value {
                    let mapResponse: [String: AnyObject] = JSON as! [String : AnyObject]
                    let routesArray = (mapResponse["routes"] as? Array) ?? []
                    let routes = (routesArray.first as? Dictionary<String, AnyObject>) ?? [:]
                    let overviewPolyline = (routes["overview_polyline"] as? Dictionary<String,AnyObject>) ?? [:]
                    let polypoints = (overviewPolyline["points"] as? String) ?? ""
                    self.drawRoute(encodedString: polypoints, animated: false)
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
        dismiss(animated: true, completion: nil)
        
        let cordinate:[String: CLLocationCoordinate2D] = ["cordinate": place.coordinate]
        mapView.clear()
        
        self.CurrentLocMarker.position = CLLocationCoordinate2DMake(place.coordinate.latitude, place.coordinate.longitude)
        self.CurrentLocMarker.map = self.mapView
        self.CurrentLocMarker.title = "myLoc"
        var markerView = UIImageView()
        markerView = UIImageView(image: UIImage.init(named: "current_location_icon"))
        markerView.frame.size.width = 30
        markerView.frame.size.height = 30
        self.CurrentLocMarker.iconView = markerView
        let camera = GMSCameraPosition.camera(withLatitude: (place.coordinate.latitude), longitude: (place.coordinate.longitude), zoom:self.mapView.camera.zoom)
        mapView.camera = camera
        //self.mapView.animate(to: camera)
        five = 0
        loadEventsToMap(lat: place.coordinate.latitude, long:place.coordinate.longitude)
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


