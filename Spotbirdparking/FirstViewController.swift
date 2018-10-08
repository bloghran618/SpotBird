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

class FirstViewController: UIViewController,CLLocationManagerDelegate,GMSMapViewDelegate{
   
    //MARK: Properties
    @IBOutlet weak var ProfileNameTextField: UITextField!
    
    @IBOutlet var mapView: GMSMapView!
    
    var locationManager = CLLocationManager()
    let CurrentLocMarker = GMSMarker()
    var timerAnimation: Timer!
    var refArtists: DatabaseReference!
    
    let arrlat = [22.7244,22.7555,22.7814,75.8937]
    let arrlong = [75.8839,75.8978,75.9035,22.7533]
    
    var userlatitude:Double  = Double()
    var userlongitude:Double  = Double()
    
    var markerlatitude:Double  = Double()
    var markerlongitude:Double  = Double()
    
    var arrspot:NSMutableArray = NSMutableArray()
    var timer = Timer()  // time
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //scheduledTimerWithTimeInterval()  // time
        
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
   
    }
    
    func getlatlong(){
        
//   AppState.sharedInstance.userid == ""
        
     refArtists = Database.database().reference().child("Spots");
     refArtists.observe(DataEventType.value, with: { (snapshot) in
     
     if snapshot.childrenCount > 0 {
     for artists in snapshot.children.allObjects as! [DataSnapshot] {
     let snapshotValue = snapshot.value as! NSDictionary
     print(snapshotValue.count)
     if snapshotValue.count>0{
     self.arrspot.removeAllObjects()
     for (theKey, theValue) in snapshotValue {
     print(theValue)
     self.arrspot.add(theValue)
     }
     print(self.arrspot)
     print(self.arrspot.count)
     
     if self.arrspot.count>0{
     self.loadEventsToMap()
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
     print(location?.coordinate)
     let camera = GMSCameraPosition.camera(withLatitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!, zoom:12)
     
     //  self.mapView.animate(to: camera)
     mapView.camera = camera
     
     
     self.locationManager.stopUpdatingLocation()
     loadEventsToMap()
     
     }
     
     func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
     print(error.localizedDescription)
     }
     
     // MARK:- googleMapsDelegate
     func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
     print("marker.position")
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
       
        customInfoWindow.imgBg.backgroundColor = UIColor.brown
//        
//        customInfoWindow.img.backgroundColor =  UIColor.black
        
       return customInfoWindow
    }
    
    @objc func bookbtn1(_ sender : UIButton){
   
    }
     
   func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
    fetchMapData(lat: markerlatitude, long: markerlongitude)
     }
     
     func loadEventsToMap(){
     
     for i in 0..<arrspot.count {
     
     let marker = GMSMarker()
     
     marker.position = CLLocationCoordinate2DMake(Double(truncating: (arrspot.object(at: i) as! NSDictionary).value(forKey: "user_lat") as! NSNumber), Double(truncating: (arrspot.object(at: i) as! NSDictionary).value(forKey: "user_long") as! NSNumber))
     
     print(marker.position)
     marker.map = self.mapView
     marker.map = self.mapView
    // marker.icon = #imageLiteral(resourceName: "car")
 
     marker.snippet = "Test"
     marker.infoWindowAnchor = CGPoint(x: 0.5, y: 0.2)
     marker.accessibilityLabel = "\(i)"
     }
     }
    
      @IBAction func btn_getdirection(_ sender: Any) {
        
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
     
     print(response)
     
     if let JSON = response.result.value {
     
     let mapResponse: [String: AnyObject] = JSON as! [String : AnyObject]
     
     let routesArray = (mapResponse["routes"] as? Array) ?? []
     
     let routes = (routesArray.first as? Dictionary<String, AnyObject>) ?? [:]
     
     let overviewPolyline = (routes["overview_polyline"] as? Dictionary<String,AnyObject>) ?? [:]
     let polypoints = (overviewPolyline["points"] as? String) ?? ""
     let line  = polypoints
     
        self.drawRoute(encodedString: line, animated: true)
     }
     }
     
     }
    
     
     func drawRoute(encodedString: String, animated: Bool) {
     
     if let path = GMSMutablePath(fromEncodedPath: encodedString) {
     
     let polyline = GMSPolyline(path: path)
     polyline.strokeWidth = 5.0
     // polyline.strokeColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
     polyline.strokeColor = UIColor.red
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
     self.timerAnimation = Timer.scheduledTimer(withTimeInterval: 0.80, repeats: true) { timer in
     
     pos += 1
     if(pos >= path.count()){
     pos = 0
     animationPath = GMSMutablePath()
     animationPolyline.map = nil
     }
     animationPath.add(path.coordinate(at: pos))
     animationPolyline.path = animationPath
     animationPolyline.strokeColor = UIColor.blue
     animationPolyline.strokeWidth = 3
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
    
    
    
    // Handle the user's selection.

    
    
}

