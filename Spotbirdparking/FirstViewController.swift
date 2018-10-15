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

class FirstViewController: UIViewController,CLLocationManagerDelegate,GMSMapViewDelegate,UISearchBarDelegate,GMSAutocompleteViewControllerDelegate,UITableViewDelegate,UITableViewDataSource{
    
    @IBOutlet var mapView: GMSMapView!
    @IBOutlet weak var searchBar: UISearchBar!
    
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
 
    @IBOutlet weak var tblLoction: UITableView!
    var arrPlaces = NSMutableArray(capacity: 100)
    let operationQueue = OperationQueue()
    let currentLat = 51.5033640
    let currentLong = -0.1276250
   // var LocationDataDelegate : LocationData! = nil
    var tblLocation : UITableView!
 //   var lblNodata = UILabel()
    
   override func viewDidLoad() {
        super.viewDidLoad()
        //scheduledTimerWithTimeInterval()  // time
    searchBar.backgroundColor = UIColor.clear
        
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
//        lblNodata.frame = CGRect(x: 0, y: 80, width:
//            self.view.frame.size.width, height: self.view.frame.size.height-60)
        //lblNodata.text = "Please enter text to get your location"
    //    self.view.addSubview(lblNodata)
        searchBar.placeholder = "Search here"
 //      lblNodata.textAlignment = .center
        searchBar.delegate = self
             tblLoction.isHidden = true
    searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print("1245788995623")
        self.beginSearching(searchText: searchText)
    }
    
    func beginSearching(searchText:String) {
        if searchText.count == 0 {
            
            self.arrPlaces.removeAllObjects()
            tblLoction.isHidden = true
             searchBar.resignFirstResponder()
              iToast.makeText("Please enter text to get your location").show()
          //  lblNodata.isHidden = false
            return
        }
        
        operationQueue.addOperation { () -> Void in
            self.forwardGeoCoding(searchText: searchText)
        }
    }
    
    //MARK: - Search place from Google -
    func forwardGeoCoding(searchText:String) {
        googlePlacesResult(input: searchText) { (result) -> Void in
            let searchResult:NSDictionary = ["keyword":searchText,"results":result]
            if result.count > 0
            {
                let features = searchResult.value(forKey: "results") as! NSArray
                self.arrPlaces.removeAllObjects()
                self.arrPlaces = NSMutableArray(capacity: 100)
             
                
                print(features.count)
                for jk in 0...features.count-1
                {
                    let dict = features.object(at: jk) as! NSDictionary
                    self.arrPlaces.add(dict)
                }
                DispatchQueue.main.async(execute: {
                    if self.arrPlaces.count != 0
                    {
                        self.tblLoction.isHidden = false
               
                       // self.lblNodata.isHidden = true
                       self.tblLoction.reloadData()
                        print("if if if if if if if if if if if if if if if if if")
                    }
                    else
            {           print("else else else else else else else else else else else")
                        self.tblLoction.isHidden = true
                       // self.lblNodata.isHidden = false
                      iToast.makeText("Location Not Found").show()
                        self.tblLoction.reloadData()
                    }
                });
            }
        }
    }
    
    //MARK: - Google place API request -
    func googlePlacesResult(input: String, completion: @escaping (_ result: NSArray) -> Void) {
        let searchWordProtection = input.replacingOccurrences(of: " ", with: "");        if searchWordProtection.characters.count != 0 {
            let urlString = NSString(format: "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=%@&types=establishment|geocode&location=%@,%@&radius=&language=en&key=AIzaSyCvFxAOvA246L6Syk7Cl426254C-sMJGxk",input,"\(AppState.sharedInstance.lat)","\(AppState.sharedInstance.long)")
           // print(urlString)
            let url = NSURL(string: urlString.addingPercentEscapes(using: String.Encoding.utf8.rawValue)!)
          //  print(url!)
            let defaultConfigObject = URLSessionConfiguration.default
            let delegateFreeSession = URLSession(configuration: defaultConfigObject, delegate: nil, delegateQueue: OperationQueue.main)
            let request = NSURLRequest(url: url! as URL)
            let task =  delegateFreeSession.dataTask(with: request as URLRequest, completionHandler:
            {
                (data, response, error) -> Void in
                if let data = data
                {
                    do {
                        let jSONresult = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as! [String:AnyObject]
                        let results:NSArray = jSONresult["predictions"] as! NSArray
                        let status = jSONresult["status"] as! String
                        if status == "NOT_FOUND" || status == "REQUEST_DENIED"
                        {
//                            let userInfo:NSDictionary = ["error": jSONresult["status"]!]
//                            print(userInfo)
//                            let newError = NSError(domain: "API Error", code: 666, userInfo: (userInfo as! NSDictionary as! [String : Any]))
                        // let arr:NSArray = [newError]
                            iToast.makeText("Location Not Found").show()
                            let arr:NSArray = NSArray()
                            completion(arr)
                            return
                        }
                        else
                        {
                            completion(results)
                        }
                    }
                    catch
                    {
                        print("json error: \(error)")
                        
                    }
                }
                else if let error = error
                {
                    print(error)
                }
            })
            task.resume()
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrPlaces.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let tblCell = tableView.dequeueReusableCell(withIdentifier: "locationCell")
        if arrPlaces.count > 0{
            let dict = self.arrPlaces.object(at: indexPath.row) as! NSDictionary
        tblCell?.textLabel?.text = dict.value(forKey: "description") as? String
        tblCell?.textLabel?.numberOfLines = 0
        tblCell?.textLabel?.sizeToFit()
        }
        return tblCell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
//        if LocationDataDelegate != nil
//        {
//            let dict = arrPlaces.object(at: indexPath.row) as! NSDictionary
//            print(dict.value(forKey: "terms") as! NSArray)
//            let ArrSelected = dict.value(forKey: "terms") as! NSArray
//            LocationDataDelegate.didSelectLocationData(LocationData: ArrSelected)
//        }
//        self.dismiss(animated: true, completion: nil)
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
        AppState.sharedInstance.lat = userlatitude
        AppState.sharedInstance.long = userlongitude
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
    
 
    
}

