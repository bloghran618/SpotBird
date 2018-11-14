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
    
    // DATE SEARCHing
    @IBOutlet weak var Date_VIew: UIView!
    
    @IBOutlet weak var start_datepic: UIDatePicker!
    @IBOutlet weak var end_datepic: UIDatePicker!
    let dateFormatter = DateFormatter()
    
    
    var start_date : String?
    var end_date : String?
    
    
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
    var tblLocation : UITableView!
    var hud : MBProgressHUD = MBProgressHUD()
    var placesClient: GMSPlacesClient!
    
    var curruntlat : Double?
    var curruntlong : Double?
    
    var Userlat : Double?
    var Userlong : Double?
    
    var arr_search_spot:NSMutableArray = NSMutableArray()
    
    
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
        Date_VIew.isHidden = true
        start_datepic.addTarget(self, action: #selector(startdatePickerChanged(picker:)), for: .valueChanged)
        end_datepic.addTarget(self, action: #selector(EnddatePickerChanged(picker:)), for: .valueChanged)
        dateFormatter.dateFormat = "MMM, dd, YYYY, H:mm:ss"
        //dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.timeZone = TimeZone.current
        
    }
    // start date-
    @objc func startdatePickerChanged(picker: UIDatePicker) {
        
        start_date = dateFormatter.string(from: picker.date)
        let dt = dateFormatter.string(from: picker.date)
        
    }
    
    // end date-
    @objc func EnddatePickerChanged(picker: UIDatePicker) {
        
        end_date = dateFormatter.string(from: picker.date)
    }
    
    // MARK:_ BTn Date searching
    @IBAction func btn_Date_search(_ sender: UIButton) {
        Date_VIew.isHidden = false
        
    }
    
    // MARK:_ BTn Date searching close
    @IBAction func btn_Date_search_close(_ sender: UIButton) {
        Date_VIew.isHidden = true
        
    }
    
    // MARK:_ BTn Date searching Done
    @IBAction func btn_Date_search_done(_ sender: UIButton) {
        let calendar = Calendar.current
        if  start_date == nil{
            let alert = UIAlertController(title: "Spotbirdparking", message: "Please Select Start Date.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else if start_datepic.date > end_datepic.date {
            let alert = UIAlertController(title: "Spotbirdparking", message: "Start date greater than End date.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
        }
        else{
            
            if end_date == nil{
                let addhour = calendar.date(byAdding: .hour, value: 3, to: start_datepic.date)
                end_date = dateFormatter.string(from: addhour!)
                
            }
            
            var arr_date = [Date]()
            var arr_day = [String]()
            while start_datepic.date <= end_datepic.date {
                arr_date.append(start_datepic.date)
                start_datepic.date = calendar.date(byAdding: .day, value: 1, to: start_datepic.date)!
            }
            if arr_date.count>0 {
                for i in 0..<arr_date.count{
                    let dateformats = DateFormatter()
                    //  dateformats.timeZone = TimeZone(abbreviation: "UTC")
                    dateformats.timeZone = TimeZone.current
                    dateformats.dateFormat  = "EEEE"       //"EE" to get short style
                    let dayInWeek = dateformats.string(from: arr_date[i])
                    
                    arr_day.append(dayInWeek)
                }
            }
           
            
            var datedaydict = NSMutableDictionary()
            
            var arrsunday = [Date]()
            var arrmonday = [Date]()
            var arrtuesday = [Date]()
            var arrwednesday = [Date]()
            var arrthuesday = [Date]()
            var arrfriday = [Date]()
            var arrsatarday = [Date]()
         
            for i in 0..<arr_date.count
            {
                if arr_day[i] == ("Sunday")
                {
                 arrsunday.append(arr_date[i])
                }
                if arr_day[i] == "Monday" {
                  arrmonday.append(arr_date[i])
                }
                if arr_day[i] == "Tuesday" {
                 arrtuesday.append(arr_date[i])
                 }
                 if arr_day[i] == "Wednesday" {
                   arrwednesday.append(arr_date[i])
                 }
                if arr_day[i] == "Thursday" {
                    arrthuesday.append(arr_date[i])
                }
                if arr_day[i] == "Friday" {
                    arrfriday.append(arr_date[i])
                }
                if arr_day[i] == "Saturday" {
                    arrsatarday.append(arr_date[i])
                }
             
             // datedaydict.setValue(arr_date[i], forKey: arr_day[i])
            
            }
            
            if arrsunday.count>0
            {
               datedaydict.setValue(arrsunday, forKey: "Sunday")
            }
            if arrmonday.count>0{
               datedaydict.setValue(arrmonday, forKey: "Monday")
            }
            if arrtuesday.count>0 {
               datedaydict.setValue(arrtuesday, forKey: "Tuesday")
            }
            if arrwednesday.count>0 {
               datedaydict.setValue(arrwednesday, forKey: "Wednesday")
            }
            if arrthuesday.count>0 {
               datedaydict.setValue(arrthuesday, forKey: "Thursday")
            }
            if arrfriday.count>0 {
               datedaydict.setValue(arrfriday, forKey: "Friday")
            }
            if arrsatarday.count>0 {
               datedaydict.setValue(arrsatarday, forKey: "Saturday")
            }
            
            print(arr_date.count)
            print(arr_day.count)
            print(datedaydict)
            
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm a"
            formatter.timeZone = TimeZone.current
            
            for i in 0..<arrspot.count{
                
                for j in 0..<arr_day.count{
                    
                    let dict_spot = arrspot.object(at: i) as! NSDictionary
                    if arr_day[j] == "Sunday" {
                        if (arrspot.object(at: i) as! NSDictionary).value(forKey: "sunswitch") as! Bool == true{
                            
                            let arrsun = datedaydict.value(forKey: "Sunday") as! NSArray
                            print(arrsun)
                            
                            for m in 0..<arrsun.count{
                            let dateSunday =  arrsun[m] as! Date
                             print(dateSunday)
                            
                           // let dateSunday =  datedaydict.value(forKey: "Sunday") as!  Date
                            formatter.dateFormat = "HH.mm"
                             let Sunday = formatter.string(from: dateSunday)
                             print(Sunday)
                            
                            var sunStartTime =  dict_spot.value(forKey: "sunStartTime") as! String
                            var sunEndTime =  dict_spot.value(forKey: "sunEndTime") as! String
                            
                            print(sunStartTime)
                            
                            formatter.dateFormat = "h:mm a"
                            let datestart = formatter.date(from: sunStartTime)
                            let dateend = formatter.date(from: sunEndTime)
                            print(datestart)
                            print(dateend)
                            
                            formatter.dateFormat = "HH.mm"
                            let Start_Sunday = formatter.string(from: datestart!)
                            let End_Sunday = formatter.string(from: dateend!)
                            print(Start_Sunday)
                            print(End_Sunday)
                            
                            
                let SundayMain = (Sunday as NSString).floatValue
                let Start = (Start_Sunday as NSString).floatValue
                let End = (End_Sunday as NSString).floatValue
                            
               print(SundayMain)
               print(Start)
               print(End)
                           
                           
                    if SundayMain > Start && SundayMain < End
                    {
                    arr_search_spot.add(arrspot.object(at: i))
                    print(arr_search_spot)
                        
                    }
                            
                }
             }
         }
                    
                    if arr_day[j] == "Monday" {
                        if (arrspot.object(at: i) as! NSDictionary).value(forKey: "monswitch") as! Bool == true{
                            
                       let arrmun = datedaydict.value(forKey: "Monday") as! NSArray
                            print(arrmun)
                            
                            for m in 0..<arrmun.count{
                                let dateMunday =  arrmun[m] as! Date
                                print(dateMunday)
                                
                                // let dateSunday =  datedaydict.value(forKey: "Sunday") as!  Date
                                formatter.dateFormat = "HH.mm"
                                let munday = formatter.string(from: dateMunday)
                               
                                let monStartTime =  dict_spot.value(forKey: "monStartTime")
                                let monEndTime =  dict_spot.value(forKey: "monEndTime")
                                
                                formatter.dateFormat = "h:mm a"
                                let datestart = formatter.date(from: monStartTime as! String)
                                let dateend = formatter.date(from: monEndTime as! String)
                             
                                formatter.dateFormat = "HH.mm"
                                let Start_Munday = formatter.string(from: datestart!)
                                let End_munday = formatter.string(from: dateend!)
                               
                                let mundaymain = (munday as NSString).floatValue
                                let Start = (Start_Munday as NSString).floatValue
                                let End = (End_munday as NSString).floatValue
                                
                                print(mundaymain)
                                print(Start)
                                print(End)
                                
                                
                                if mundaymain > Start && mundaymain < End
                                {
                                    arr_search_spot.add(arrspot.object(at: i))
                                    print(arr_search_spot)
                                    
                                }
                                
                            }
                            
                        }
                        
                    }
                    if arr_day[j] == "Tuesday" {
                        if (arrspot.object(at: i) as! NSDictionary).value(forKey: "tueswitch") as! Bool == true{
                            
                          
                            
                            let arrthue = datedaydict.value(forKey: "Tuesday") as! NSArray
                            print(arrthue)
                            
                            for m in 0..<arrthue.count{
                                let dateTuesday =  arrthue[m] as! Date
                                print(dateTuesday)
                                
                               formatter.dateFormat = "HH.mm"
                                let Tuesday = formatter.string(from: dateTuesday)
                                
                                let tueStartTime =  dict_spot.value(forKey: "tueStartTime")
                                let tueEndTime =  dict_spot.value(forKey: "tueEndTime")
                                
                                formatter.dateFormat = "h:mm a"
                                let datestart = formatter.date(from: tueStartTime as! String)
                                let dateend = formatter.date(from: tueEndTime as! String)
                                
                                formatter.dateFormat = "HH.mm"
                                let Start_Tuesday = formatter.string(from: datestart!)
                                let End_Tuesday = formatter.string(from: dateend!)
                                
                                let Tuesdaymain = (Tuesday as NSString).floatValue
                                let Start = (Start_Tuesday as NSString).floatValue
                                let End = (End_Tuesday as NSString).floatValue
                                
                                print(Tuesdaymain)
                                print(Start)
                                print(End)
                                
                                
                                if Tuesdaymain > Start && Tuesdaymain < End
                                {
                                    arr_search_spot.add(arrspot.object(at: i))
                                    print(arr_search_spot)
                                    
                                }
                                
                            }
                            
                        }
                        
                    }
                    if arr_day[j] == "Wednesday" {
                        if (arrspot.object(at: i) as! NSDictionary).value(forKey: "wedswitch") as! Bool == true{
                            
                            let arrwed = datedaydict.value(forKey: "Wednesday") as! NSArray
                            print(arrwed)
                            
                            for m in 0..<arrwed.count{
                                let datewed =  arrwed[m] as! Date
                                print(datewed)
                                
                                formatter.dateFormat = "HH.mm"
                                let wednesday = formatter.string(from: datewed)
                                
                                let wedStartTime =  dict_spot.value(forKey: "wedStartTime")
                                let wedEndTime =  dict_spot.value(forKey: "wedEndTime")
                                
                                formatter.dateFormat = "h:mm a"
                                let datestart = formatter.date(from: wedStartTime as! String)
                                let dateend = formatter.date(from: wedEndTime as! String)
                                
                                formatter.dateFormat = "HH.mm"
                                let Start_Wednesday = formatter.string(from: datestart!)
                                let End_Wednesday = formatter.string(from: dateend!)
                                
                                let wednesdaymain = (wednesday as NSString).floatValue
                                let Start = (Start_Wednesday as NSString).floatValue
                                let End = (End_Wednesday as NSString).floatValue
                                
                                print(wednesdaymain)
                                print(Start)
                                print(End)
                                
                                
                                if wednesdaymain > Start && wednesdaymain < End
                                {
                                    arr_search_spot.add(arrspot.object(at: i))
                                    print(arr_search_spot)
                                    
                                }
                                
                            }
                        }
                        
                    }
                    if arr_day[j] == "Thursday" {
                        if (arrspot.object(at: i) as! NSDictionary).value(forKey: "thuswitch") as! Bool == true{
                            
                            let arrThu = datedaydict.value(forKey: "Thursday") as! NSArray
                            print(arrThu)
                            
                            for m in 0..<arrThu.count{
                                let dateThu =  arrThu[m] as! Date
                                print(dateThu)
                                
                                formatter.dateFormat = "HH.mm"
                                let Thursday = formatter.string(from: dateThu)
                                
                                let thuStartTime =  dict_spot.value(forKey: "thuStartTime")
                                let thuEndTime =  dict_spot.value(forKey: "thuEndTime")
                                
                                formatter.dateFormat = "h:mm a"
                                let datestart = formatter.date(from: thuStartTime as! String)
                                let dateend = formatter.date(from: thuEndTime as! String)
                                
                                formatter.dateFormat = "HH.mm"
                                let Start_Thursday = formatter.string(from: datestart!)
                                let End_Thursday = formatter.string(from: dateend!)
                                
                                let wednesdaymain = (Thursday as NSString).floatValue
                                let Start = (Start_Thursday as NSString).floatValue
                                let End = (End_Thursday as NSString).floatValue
                                
                                print(wednesdaymain)
                                print(Start)
                                print(End)
                                
                                
                                if wednesdaymain > Start && wednesdaymain < End
                                {
                                    arr_search_spot.add(arrspot.object(at: i))
                                    print(arr_search_spot)
                                }
                            }
                         }
                     }
                    if arr_day[j] == "Friday" {
                        if (arrspot.object(at: i) as! NSDictionary).value(forKey: "friswitch") as! Bool == true{
                            
                           let arrFri = datedaydict.value(forKey: "Friday") as! NSArray
                            print(arrFri)
                            
                            for m in 0..<arrFri.count{
                                let dateFri =  arrFri[m] as! Date
                                print(dateFri)
                                
                                formatter.dateFormat = "HH.mm"
                                let Friday = formatter.string(from: dateFri)
                                
                                let friStartTime =  dict_spot.value(forKey: "friStartTime")
                                let friEndTime =  dict_spot.value(forKey: "friEndTime")
                                
                                formatter.dateFormat = "h:mm a"
                                let datestart = formatter.date(from: friStartTime as! String)
                                let dateend = formatter.date(from: friEndTime as! String)
                                
                                formatter.dateFormat = "HH.mm"
                                let Start_Friday = formatter.string(from: datestart!)
                                let End_Friday = formatter.string(from: dateend!)
                                
                                let Fridaymain = (Friday as NSString).floatValue
                                let Start = (Start_Friday as NSString).floatValue
                                let End = (End_Friday as NSString).floatValue
                                
                                print(Fridaymain)
                                print(Start)
                                print(End)
                                
                                
                                if Fridaymain > Start && Fridaymain < End
                                {
                                    arr_search_spot.add(arrspot.object(at: i))
                                    print(arr_search_spot)
                                }
                            }
                            
                        }
                     }
                    if arr_day[j] == "Saturday" {
                        if (arrspot.object(at: i) as! NSDictionary).value(forKey: "satswitch") as! Bool == true{
                            let monStartTime =  dict_spot.value(forKey: "satStartTime")
                            let monEndTime =  dict_spot.value(forKey: "satEndTime")
                            
                            let arrsat = datedaydict.value(forKey: "Saturday") as! NSArray
                            print(arrsat)
                            
                            for m in 0..<arrsat.count{
                                let datesat =  arrsat[m] as! Date
                                print(datesat)
                                
                                formatter.dateFormat = "HH.mm"
                                let Saturday = formatter.string(from: datesat)
                                
                                let satStartTime =  dict_spot.value(forKey: "satStartTime")
                                let satEndTime =  dict_spot.value(forKey: "satEndTime")
                                
                                formatter.dateFormat = "h:mm a"
                                let datestart = formatter.date(from: satStartTime as! String)
                                let dateend = formatter.date(from: satEndTime as! String)
                                
                                formatter.dateFormat = "HH.mm"
                                let Start_Friday = formatter.string(from: datestart!)
                                let End_Friday = formatter.string(from: dateend!)
                                
                                let Saturdaymain = (Saturday as NSString).floatValue
                                let Start = (Start_Friday as NSString).floatValue
                                let End = (End_Friday as NSString).floatValue
                                
                                print(Saturdaymain)
                                print(Start)
                                print(End)
                                
                                
                                if Saturdaymain > Start && Saturdaymain < End
                                {
                                    arr_search_spot.add(arrspot.object(at: i))
                                    print(arr_search_spot)
                                }
                            }
                            
                            
                        }
                        
                    }
                }
             }
            
            // Search Data load marker:-
           Search_Spot()
           }
   
        
        
        
        Date_VIew.isHidden = true
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
        mapView.clear()
        
        five = 0
        refArtists = Database.database().reference().child("All_Spots");
        refArtists.observe(DataEventType.value, with: { (snapshot) in
            
            if snapshot.childrenCount > 0 {
                self.arrspot.removeAllObjects()
                for artists in snapshot.children.allObjects as! [DataSnapshot] {
                    let snapshotValue = snapshot.value as! NSDictionary
                    print(snapshotValue)
                    
                    let dictdata = ((snapshot.value as! NSDictionary).value(forKey: (artists as! DataSnapshot).key)) as! NSDictionary
                    print(dictdata)
                    if dictdata.count>0{
                        
                        for (theKey, theValue) in dictdata {
                            //   print(theValue)
                            self.arrspot.add(theValue)
                        }
                        //self.loadEventsToMap(lat: self.userlatitude, long: self.userlongitude)
                        
                    }
                }
                
                for i in 0..<self.arrspot.count {
                    print(self.arrspot)
                    let marker = GMSMarker()
                    marker.position = CLLocationCoordinate2DMake(Double(truncating: (self.arrspot.object(at: i) as! NSDictionary).value(forKey: "user_lat") as! NSNumber), Double(truncating: (self.arrspot.object(at: i) as! NSDictionary).value(forKey: "user_long") as! NSNumber))
                    marker.map = self.mapView
                    let price = (self.arrspot.object(at: i) as! NSDictionary).value(forKey: "hourlyPricing") as! String
                    let doller = (price as NSString).integerValue
                    // marker.title = "$\(doller)"
                    //   marker.snippet
                    marker.infoWindowAnchor = CGPoint(x: 0.5, y: 0.2)
                    marker.accessibilityLabel = "\(i)"
                    
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
                    lbl_marker.minimumScaleFactor = 0.5;
                    lbl_marker.adjustsFontSizeToFitWidth = true;
                    lbl_marker.text = "$\(doller)"
                    lbl_marker.textColor = UIColor.black
                    customView.backgroundColor = UIColor.clear
                    marker.iconView = customView
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
        
        if  Userlat != marker.position.latitude && Userlong != marker.position.longitude{
        
        let index:Int! = Int(marker.accessibilityLabel!)
        let price  = (arrspot.object(at: index) as! NSDictionary).value(forKey: "hourlyPricing") as?  String
        let doller = (price! as NSString).integerValue
        
//        if curruntlat == marker.position.latitude && curruntlong == marker.position.longitude{
//
//            mapView.clear()
//            locationManager.startUpdatingLocation()
//            view_info.isHidden = true
//            btn_close.isHidden = true
//
//        }
//        else{
//
//            //            markerimg.image = #imageLiteral(resourceName: "marker_blue")
//            //            let lbl_marker = UILabel()
//            //            lbl_marker.frame = CGRect(x: 0, y: (self.markerimg.frame.height/2)-25, width: self.markerimg.frame.width, height: 40)
//            //            lbl_marker.textColor = UIColor.white
//            //            lbl_marker.text = "$\(doller)"
//            //            self.markerimg.addSubview(lbl_marker)
//            //
//            //            viewchange.addSubview(markerimg)
//            //            mapView.selectedMarker = marker
//            let imgdata = marker.iconView
//            imgdata?.backgroundColor = UIColor.red
//            marker.iconView = imgdata
//
//            view_info.isHidden = false
//            btn_close.isHidden = false
//        }
            view_info.isHidden = false
            btn_close.isHidden = false
        curruntlat = marker.position.latitude
        curruntlong = marker.position.longitude
        
        lbl_price.text = "$\(doller)"
        lbl_address.text = (arrspot.object(at: index) as! NSDictionary).value(forKey: "address") as?  String
        let imgurl = (arrspot.object(at: index) as! NSDictionary).value(forKey: "image") as!  String
        img_spot.sd_setImage(with: URL(string: imgurl), placeholderImage: #imageLiteral(resourceName: "Placeholder"))
        
    
    }
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
    
    
    // Search Filter Spot -
    func Search_Spot() {
        
        if arr_search_spot.count > 0 {
        mapView.clear()
        for i in 0..<self.arr_search_spot.count {
      
            let marker = GMSMarker()
            marker.position = CLLocationCoordinate2DMake(Double(truncating: (self.arr_search_spot.object(at: i) as! NSDictionary).value(forKey: "user_lat") as! NSNumber), Double(truncating: (self.arr_search_spot.object(at: i) as! NSDictionary).value(forKey: "user_long") as! NSNumber))
            marker.map = self.mapView
            let price = (self.arr_search_spot.object(at: i) as! NSDictionary).value(forKey: "hourlyPricing") as! String
            let doller = (price as NSString).integerValue
            // marker.title = "$\(doller)"
            //   marker.snippet
            marker.infoWindowAnchor = CGPoint(x: 0.5, y: 0.2)
            marker.accessibilityLabel = "\(i)"
            
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
            lbl_marker.minimumScaleFactor = 0.5;
            lbl_marker.adjustsFontSizeToFitWidth = true;
             lbl_marker.text = "$\(doller)"
           
            lbl_marker.textColor = UIColor.black
            customView.backgroundColor = UIColor.clear
            marker.iconView = customView
        }
        }
        else{
            let alertController = UIAlertController(title: "Spotbird", message: "Spot Not Found!", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
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
        Userlat = place.coordinate.latitude
        Userlong = place.coordinate.longitude
        
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





//                            let Sundaystart = formatter.string(from: datestart!)
//                            print(Sundaystart)
//
//
//                            let dateend = formatter.date(from: sunEndTime)
//                            let Sundayend = formatter.string(from: dateend!)
//                            print(Sundayend)
//


//                            formatter.dateFormat = "hh.mm"
//                            let SundayDate24 = formatter.string(from: dateSunday)
//                            print(SundayDate24)
//                            let SundayMain = (SundayDate24 as NSString).floatValue
//  print(SundayMain)


/*
 var sunStartTime =  dict_spot.value(forKey: "sunStartTime") as! String
 var sunEndTime =  dict_spot.value(forKey: "sunEndTime") as! String
 
 let date = formatter.date(from: sunStartTime)
 let Sundaystart = formatter.string(from: date!)
 
 let dates = formatter.date(from: sunEndTime)
 let Sundayend = formatter.string(from: dates!)
 
 sunStartTime.removeLast()
 sunStartTime.removeLast()
 sunEndTime.removeLast()
 sunEndTime.removeLast()
 
 let Sundaystart24 = (Sundaystart as NSString).floatValue
 let Sundayend24 = (Sundayend as NSString).floatValue
 
 print(" OLD -\(sunStartTime)")
 print(" OLD -\(sunEndTime)")
 print(" OLD -\(SundayMain)")
 
 print(" CHANGE -\(SundayMain)")
 print(" CHANGE -\(Sundaystart24)")
 print(" CHANGE -\(Sundayend24)")v  kuauiabta tsfas
 
 
 
 
 if SundayMain > Sundaystart24 && SundayMain < Sundayend24 {
 print("RIghts")
 }
 else{
 print("TIME NOT MATCH")
 }  */

//                       let start = formatter.string(from: s!)
//                       let End = formatter.string(from: d!)

//                       print(Sunday_main)
//                       print(start)
//                       print(End)
//
//                       guard let Sundayon = formatter.date(from: start) else {
//                            fatalError()
//                        }
//                      //  print(Sundayon)
//                        formatter.dateFormat = "h:mm a"
//                        let sun = formatter.string(from: Sundayon)
//                        print(sun)
//                        let Sunday_ = formatter.date(from: sun)
//                        print(Sunday_)
//
//                        guard let Sundayonend = formatter.date(from: start) else {
//                            fatalError()
//                        }
//                        print(Sundayonend)
//                        formatter.dateFormat = "h:mm a"
//                        let sunend = formatter.string(from: Sundayonend)
//                        print(sunend)
//                        let Sundayend_ = formatter.date(from: sunend)
//                        print(Sundayend_)


