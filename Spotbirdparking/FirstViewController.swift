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

class FirstViewController: UIViewController,CLLocationManagerDelegate,GMSMapViewDelegate,GMSAutocompleteViewControllerDelegate,UIPickerViewDataSource,UIPickerViewDelegate{
    
    @IBOutlet var mapView: GMSMapView!
    // info window:-
    @IBOutlet weak var img_spot: UIImageView!
    @IBOutlet weak var lbl_price: UILabel!
    @IBOutlet weak var lbl_address: UILabel!
    @IBOutlet weak var btn_close: UIButton!
    @IBOutlet weak var btn_book: UIButton!
    @IBOutlet weak var btn_dtls: UIButton!
    @IBOutlet weak var btn_search_click: UIButton!
    @IBOutlet weak var btn_calander: UIButton!
    @IBOutlet weak var view_info: CustomView!

    // DATE SEARCHing
    @IBOutlet weak var Date_VIew: UIView!
    @IBOutlet weak var start_datepic: UIDatePicker!
    @IBOutlet weak var end_datepic: UIDatePicker!
    let dateFormatter = DateFormatter()
    
    @IBOutlet weak var timpic1: UIPickerView!
    @IBOutlet weak var timepic2: UIPickerView!
    
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
    var cooridnates = CLLocationCoordinate2D()
    var arr_search_spot:NSMutableArray = NSMutableArray()
    var timearray = [String]()
    var start_date:Date?
    var end_date:Date?
    
    var format1 = ""
    var format2 = ""
    let calendar = Calendar.current
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dismissKeyboard()
        //scheduledTimerWithTimeInterval()  // time
        
        btn_search_click.layer.cornerRadius = (btn_search_click.frame.height/2-6)
        btn_search_click.layer.borderWidth = 1
        
        
        
        img_spot.layer.borderWidth = 1
        img_spot.layer.masksToBounds = false
        img_spot.layer.cornerRadius = img_spot.frame.height/2
        img_spot.clipsToBounds = true
        view_info.isHidden = true
        btn_close.isHidden = true
        
        self.mapView.delegate = self
        self.locationManager.delegate = self
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        CurrentLocMarker.map = self.mapView
        self.locationManager.startMonitoringSignificantLocationChanges()
        self.locationManager.startUpdatingLocation()
     //   mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        
        mapView.padding = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 20)
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
        
        timearrayset()
      start_datepic.minimumDate = Date()
      end_datepic.minimumDate = Date()
    }
    
    func timearrayset()  {
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:a"
        var stringdate = dateFormatter.string(from: Date())
        
        if stringdate.contains("PM"){
            timearray.append("PM")
            timearray.append("AM")
            format1 = "PM"
            format2 = "PM"
        }
        else{
            timearray.append("AM")
            timearray.append("PM")
            format1 = "AM"
            format2 = "AM"
        }
        
    }
    
    // start date-
    @objc func startdatePickerChanged(picker: UIDatePicker) {
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:a"
      //   dateFormatter.dateFormat = "EEE, MMM d, yyyy - h:mm a"
        var myStringafd = dateFormatter.string(from: picker.date)
        
        if format1 == "AM"{
            let replaced = myStringafd.replacingOccurrences(of: "AM", with: "PM")
            start_date = dateFormatter.date(from: replaced)!
        }
        else{
            let replaced = myStringafd.replacingOccurrences(of: "PM", with: "AM")
            start_date = dateFormatter.date(from: replaced)!
        }
      }
    
    // end date-
    @objc func EnddatePickerChanged(picker: UIDatePicker) {
      dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:a"
        var str = dateFormatter.string(from: picker.date)
        if format2 == "AM"{
            let replaced = str.replacingOccurrences(of: "AM", with: "PM")
            end_date = dateFormatter.date(from: str)!
        }
        else{
            let replaced = str.replacingOccurrences(of: "PM", with: "AM")
            end_date = dateFormatter.date(from: str)!
        }
        
    }
    
    // MARK:_ BTn Date searching
    @IBAction func btn_Date_search(_ sender: UIButton) {
        view_info.isHidden = true
        btn_close.isHidden = true
        
        if Date_VIew.isHidden == true{
            Date_VIew.isHidden = false
        }
        else{
            Date_VIew.isHidden = true
        }
    }
    
    // MARK:_ BTn Date searching close
    @IBAction func btn_Date_search_close(_ sender: UIButton) {
        Date_VIew.isHidden = true
    }
    
    // MARK:_ BTn Date searching Done
    @IBAction func btn_Date_search_done(_ sender: UIButton) {
        
        if start_date == nil {
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:a"
        var myStringafd = dateFormatter.string(from: start_datepic.date)
        
        if format1 == "AM"{
            let replaced = myStringafd.replacingOccurrences(of: "AM", with: "PM")
            start_date = dateFormatter.date(from: replaced)!
        }
        else{
            let replaced = myStringafd.replacingOccurrences(of: "PM", with: "AM")
            start_date = dateFormatter.date(from: replaced)!
        }
        print(start_date)
        }
        if end_date == nil{
            print(start_date)
            print(end_date)
            
            let addhour = calendar.date(byAdding: .hour, value: 3, to: start_date!)
            end_date = addhour!
            print(addhour)
            print(end_date)
        }
        
        var dateorder = ""
        switch start_date!.compare(end_date!) {
        case .orderedAscending:
            print("orderedAscending")
            dateorder = "orderedAscending"
             break
            
        case .orderedDescending:
             print("orderedDescending")
             dateorder = "orderedDescending"
             break;
            
        case .orderedSame:
             print("orderedSame")
             dateorder = "orderedSame"
             break
        }
       
        
        if dateorder != "orderedAscending" {
            let alert = UIAlertController(title: "Spotbirdparking", message: "Start date greater than End date.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)

        }
        else{
            arr_search_spot.removeAllObjects()
            
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
            
          for i in 0..<arrspot.count{
                for j in 0..<arr_day.count{
                    let dict_spot = arrspot.object(at: i) as! NSDictionary
                    
                    var localTimeZoneName: String { return TimeZone.current.identifier }
                    print(localTimeZoneName)
                    
                    let CurrentTimeZone = NSTimeZone(abbreviation: "GMT")
                    let SystemTimeZone = NSTimeZone.system as NSTimeZone
                    
//                    let CurrentTimeZone = TimeZone.current
//                    let SystemTimeZone = NSTimeZone.system as NSTimeZone
                    
                    if arr_day[j] == "Sunday" {
                        if (arrspot.object(at: i) as! NSDictionary).value(forKey: "sunswitch") as! Bool == true{
                            
                            let arrsun = datedaydict.value(forKey: "Sunday") as! NSArray
                            for m in 0..<arrsun.count{

                                var sunStartTime =  dict_spot.value(forKey: "sunStartTime") as! String
                                var sunEndTime =  dict_spot.value(forKey: "sunEndTime") as! String

                                let timearr = sunStartTime.components(separatedBy: ":")
                                let hour = Int(timearr[0])
                                let minutestring =  (timearr[1])
                                let arrminute = minutestring.components(separatedBy: " ")
                                let minute =  Int(arrminute[0])
                                let Start = Calendar.current.date(bySettingHour: hour!, minute: minute!, second: 0, of: Date())!

                                let currentGMTOffset1: Int? = CurrentTimeZone?.secondsFromGMT(for: Start)
                                let SystemGMTOffset1: Int = SystemTimeZone.secondsFromGMT(for: Start)
                                let interval1 = TimeInterval((SystemGMTOffset1 - currentGMTOffset1!))
                                let Munday_start = Date(timeInterval: interval1, since: Start)

                                let timearr1 = sunEndTime.components(separatedBy: ":")
                                let hour1 = Int(timearr1[0])
                                let minutestring1 =  (timearr1[1])
                                let arrminute1 = minutestring1.components(separatedBy: " ")
                                let minute1 =  Int(arrminute1[0])
                                let End = Calendar.current.date(bySettingHour: hour1!, minute: minute1!, second: 0, of: Date())!

                                let currentGMTOffset2: Int? = CurrentTimeZone?.secondsFromGMT(for: End)
                                let SystemGMTOffset2: Int = SystemTimeZone.secondsFromGMT(for: End)
                                let interval2 = TimeInterval((SystemGMTOffset2 - currentGMTOffset2!))
                                let Munday_end = Date(timeInterval: interval2, since: End)

                                let currentGMTOffset3: Int? = CurrentTimeZone?.secondsFromGMT(for: start_date!)
                                let SystemGMTOffset3: Int = SystemTimeZone.secondsFromGMT(for: start_date!)
                                let interval3 = TimeInterval((SystemGMTOffset2 - currentGMTOffset2!))
                                let user_start = Date(timeInterval: interval2, since: start_date!)

                                let currentGMTOffset4: Int? = CurrentTimeZone?.secondsFromGMT(for: end_date!)
                                let SystemGMTOffset4: Int = SystemTimeZone.secondsFromGMT(for: end_date!)
                                let interval4 = TimeInterval((SystemGMTOffset4 - currentGMTOffset4!))
                                let user_end = Date(timeInterval: interval4, since: end_date!)


                                if user_start < Munday_start && user_end < Munday_end{
                                    arr_search_spot.add(arrspot.object(at: i))
                                }

                            }
                        }
                    }
                   if arr_day[j] == "Monday" {
                        if (arrspot.object(at: i) as! NSDictionary).value(forKey: "monswitch") as! Bool == true{
                            
                            let arrmun = datedaydict.value(forKey: "Monday") as! NSArray
                            for m in 0..<arrmun.count{
                                
                                let monStartTime =  dict_spot.value(forKey: "monStartTime") as! String
                                let monEndTime =  dict_spot.value(forKey: "monEndTime")  as! String
                                
                                let timearr = monStartTime.components(separatedBy: ":")
                                let hour = Int(timearr[0])
                                let minutestring =  (timearr[1])
                                let arrminute = minutestring.components(separatedBy: " ")
                                let minute =  Int(arrminute[0])
                                let Start = Calendar.current.date(bySettingHour: hour!, minute: minute!, second: 0, of: Date())!
                                
                                let currentGMTOffset1: Int? = CurrentTimeZone?.secondsFromGMT(for: Start)
                                let SystemGMTOffset1: Int = SystemTimeZone.secondsFromGMT(for: Start)
                                let interval1 = TimeInterval((SystemGMTOffset1 - currentGMTOffset1!))
                                let Munday_start = Date(timeInterval: interval1, since: Start)
                                
                                let timearr1 = monEndTime.components(separatedBy: ":")
                                let hour1 = Int(timearr1[0])
                                let minutestring1 =  (timearr1[1])
                                let arrminute1 = minutestring1.components(separatedBy: " ")
                                let minute1 =  Int(arrminute1[0])
                                let End = Calendar.current.date(bySettingHour: hour1!, minute: minute1!, second: 0, of: Date())!
                                
                                let currentGMTOffset2: Int? = CurrentTimeZone?.secondsFromGMT(for: End)
                                let SystemGMTOffset2: Int = SystemTimeZone.secondsFromGMT(for: End)
                                let interval2 = TimeInterval((SystemGMTOffset2 - currentGMTOffset2!))
                                let Munday_end = Date(timeInterval: interval2, since: End)
                                
                                let currentGMTOffset3: Int? = CurrentTimeZone?.secondsFromGMT(for: start_date!)
                                let SystemGMTOffset3: Int = SystemTimeZone.secondsFromGMT(for: start_date!)
                                let interval3 = TimeInterval((SystemGMTOffset2 - currentGMTOffset2!))
                                let user_start = Date(timeInterval: interval2, since: start_date!)
                                
                                let currentGMTOffset4: Int? = CurrentTimeZone?.secondsFromGMT(for: end_date!)
                                let SystemGMTOffset4: Int = SystemTimeZone.secondsFromGMT(for: end_date!)
                                let interval4 = TimeInterval((SystemGMTOffset4 - currentGMTOffset4!))
                                let user_end = Date(timeInterval: interval4, since: end_date!)
                                
                                if user_start < Munday_start {
                                    print("Munday_start\(Munday_start)")
                                }else{
                                    print("Munday_start\(user_start)")
                                }
                                
                                if user_end < Munday_end {
                                    print("Munday_start\(Munday_end)")
                                }
                                else{
                                    print("Munday_start\(user_end)")
                                }
                                
                                if user_start < Munday_start && user_end < Munday_end{
                                    arr_search_spot.add(arrspot.object(at: i))
                                }
                            }
                        }
                    }
                    if arr_day[j] == "Tuesday" {
                        if (arrspot.object(at: i) as! NSDictionary).value(forKey: "tueswitch") as! Bool == true{
                            
                            let arrthue = datedaydict.value(forKey: "Tuesday") as! NSArray
                            for m in 0..<arrthue.count{
                                
                                let tueStartTime =  dict_spot.value(forKey: "tueStartTime") as! String
                                let tueEndTime =  dict_spot.value(forKey: "tueEndTime") as! String
                                
                                let timearr = tueStartTime.components(separatedBy: ":")
                                let hour = Int(timearr[0])
                                let minutestring =  (timearr[1])
                                let arrminute = minutestring.components(separatedBy: " ")
                                let minute =  Int(arrminute[0])
                                let Start = Calendar.current.date(bySettingHour: hour!, minute: minute!, second: 0, of: Date())!
                                
                                let currentGMTOffset1: Int? = CurrentTimeZone?.secondsFromGMT(for: Start)
                                let SystemGMTOffset1: Int = SystemTimeZone.secondsFromGMT(for: Start)
                                let interval1 = TimeInterval((SystemGMTOffset1 - currentGMTOffset1!))
                                let Munday_start = Date(timeInterval: interval1, since: Start)
                                
                                let timearr1 = tueEndTime.components(separatedBy: ":")
                                let hour1 = Int(timearr1[0])
                                let minutestring1 =  (timearr1[1])
                                let arrminute1 = minutestring1.components(separatedBy: " ")
                                let minute1 =  Int(arrminute1[0])
                                let End = Calendar.current.date(bySettingHour: hour1!, minute: minute1!, second: 0, of: Date())!
                                
                                let currentGMTOffset2: Int? = CurrentTimeZone?.secondsFromGMT(for: End)
                                let SystemGMTOffset2: Int = SystemTimeZone.secondsFromGMT(for: End)
                                let interval2 = TimeInterval((SystemGMTOffset2 - currentGMTOffset2!))
                                let Munday_end = Date(timeInterval: interval2, since: End)
                                
                                let currentGMTOffset3: Int? = CurrentTimeZone?.secondsFromGMT(for: start_date!)
                                let SystemGMTOffset3: Int = SystemTimeZone.secondsFromGMT(for: start_date!)
                                let interval3 = TimeInterval((SystemGMTOffset2 - currentGMTOffset2!))
                                let user_start = Date(timeInterval: interval2, since: start_date!)
                                
                                let currentGMTOffset4: Int? = CurrentTimeZone?.secondsFromGMT(for: end_date!)
                                let SystemGMTOffset4: Int = SystemTimeZone.secondsFromGMT(for: end_date!)
                                let interval4 = TimeInterval((SystemGMTOffset4 - currentGMTOffset4!))
                                let user_end = Date(timeInterval: interval4, since: end_date!)
                                
                                if user_start < Munday_start && user_end < Munday_end{
                                    arr_search_spot.add(arrspot.object(at: i))
                                }
                                
                            }
                            
                        }
                        
                    }
                    if arr_day[j] == "Wednesday" {
                        if (arrspot.object(at: i) as! NSDictionary).value(forKey: "wedswitch") as! Bool == true{
                            
                            let arrwed = datedaydict.value(forKey: "Wednesday") as! NSArray
                            for m in 0..<arrwed.count{
                                
                                let wedStartTime =  dict_spot.value(forKey: "wedStartTime") as! String
                                let wedEndTime =  dict_spot.value(forKey: "wedEndTime") as! String
                                
                                let timearr = wedStartTime.components(separatedBy: ":")
                                let hour = Int(timearr[0])
                                let minutestring =  (timearr[1])
                                let arrminute = minutestring.components(separatedBy: " ")
                                let minute =  Int(arrminute[0])
                                let Start = Calendar.current.date(bySettingHour: hour!, minute: minute!, second: 0, of: Date())!
                                
                                let currentGMTOffset1: Int? = CurrentTimeZone?.secondsFromGMT(for: Start)
                                let SystemGMTOffset1: Int = SystemTimeZone.secondsFromGMT(for: Start)
                                let interval1 = TimeInterval((SystemGMTOffset1 - currentGMTOffset1!))
                                let Munday_start = Date(timeInterval: interval1, since: Start)
                                
                                let timearr1 = wedEndTime.components(separatedBy: ":")
                                let hour1 = Int(timearr1[0])
                                let minutestring1 =  (timearr1[1])
                                let arrminute1 = minutestring1.components(separatedBy: " ")
                                let minute1 =  Int(arrminute1[0])
                                let End = Calendar.current.date(bySettingHour: hour1!, minute: minute1!, second: 0, of: Date())!
                                
                                let currentGMTOffset2: Int? = CurrentTimeZone?.secondsFromGMT(for: End)
                                let SystemGMTOffset2: Int = SystemTimeZone.secondsFromGMT(for: End)
                                let interval2 = TimeInterval((SystemGMTOffset2 - currentGMTOffset2!))
                                let Munday_end = Date(timeInterval: interval2, since: End)
                                
                                let currentGMTOffset3: Int? = CurrentTimeZone?.secondsFromGMT(for: start_date!)
                                let SystemGMTOffset3: Int = SystemTimeZone.secondsFromGMT(for: start_date!)
                                let interval3 = TimeInterval((SystemGMTOffset2 - currentGMTOffset2!))
                                let user_start = Date(timeInterval: interval2, since: start_date!)
                                
                                let currentGMTOffset4: Int? = CurrentTimeZone?.secondsFromGMT(for: end_date!)
                                let SystemGMTOffset4: Int = SystemTimeZone.secondsFromGMT(for: end_date!)
                                let interval4 = TimeInterval((SystemGMTOffset4 - currentGMTOffset4!))
                                let user_end = Date(timeInterval: interval4, since: end_date!)
                                
                                
                                if user_start < Munday_start && user_end < Munday_end{
                                    arr_search_spot.add(arrspot.object(at: i))
                                }
                            }
                        }
                        
                    }
                    if arr_day[j] == "Thursday" {
                        if (arrspot.object(at: i) as! NSDictionary).value(forKey: "thuswitch") as! Bool == true{
                            
                            let arrThu = datedaydict.value(forKey: "Thursday") as! NSArray
                            for m in 0..<arrThu.count{
                                let thuStartTime =  dict_spot.value(forKey: "thuStartTime") as! String
                                let thuEndTime =  dict_spot.value(forKey: "thuEndTime")  as! String
                                
                                let timearr = thuStartTime.components(separatedBy: ":")
                                let hour = Int(timearr[0])
                                let minutestring =  (timearr[1])
                                let arrminute = minutestring.components(separatedBy: " ")
                                let minute =  Int(arrminute[0])
                                let Start = Calendar.current.date(bySettingHour: hour!, minute: minute!, second: 0, of: Date())!
                                
                                let currentGMTOffset1: Int? = CurrentTimeZone?.secondsFromGMT(for: Start)
                                let SystemGMTOffset1: Int = SystemTimeZone.secondsFromGMT(for: Start)
                                let interval1 = TimeInterval((SystemGMTOffset1 - currentGMTOffset1!))
                                let Munday_start = Date(timeInterval: interval1, since: Start)
                                
                                let timearr1 = thuEndTime.components(separatedBy: ":")
                                let hour1 = Int(timearr1[0])
                                let minutestring1 =  (timearr1[1])
                                let arrminute1 = minutestring1.components(separatedBy: " ")
                                let minute1 =  Int(arrminute1[0])
                                let End = Calendar.current.date(bySettingHour: hour1!, minute: minute1!, second: 0, of: Date())!
                                
                                let currentGMTOffset2: Int? = CurrentTimeZone?.secondsFromGMT(for: End)
                                let SystemGMTOffset2: Int = SystemTimeZone.secondsFromGMT(for: End)
                                let interval2 = TimeInterval((SystemGMTOffset2 - currentGMTOffset2!))
                                let Munday_end = Date(timeInterval: interval2, since: End)
                                
                                let currentGMTOffset3: Int? = CurrentTimeZone?.secondsFromGMT(for: start_date!)
                                let SystemGMTOffset3: Int = SystemTimeZone.secondsFromGMT(for: start_date!)
                                let interval3 = TimeInterval((SystemGMTOffset2 - currentGMTOffset2!))
                                let user_start = Date(timeInterval: interval2, since: start_date!)
                                
                                let currentGMTOffset4: Int? = CurrentTimeZone?.secondsFromGMT(for: end_date!)
                                let SystemGMTOffset4: Int = SystemTimeZone.secondsFromGMT(for: end_date!)
                                let interval4 = TimeInterval((SystemGMTOffset4 - currentGMTOffset4!))
                                let user_end = Date(timeInterval: interval4, since: end_date!)
                                
                                
                                if user_start < Munday_start && user_end < Munday_end{
                                    arr_search_spot.add(arrspot.object(at: i))
                                }
                            }
                        }
                    }
                    if arr_day[j] == "Friday" {
                        if (arrspot.object(at: i) as! NSDictionary).value(forKey: "friswitch") as! Bool == true{
                            
                            let arrFri = datedaydict.value(forKey: "Friday") as! NSArray
                            for m in 0..<arrFri.count{
                                let friStartTime =  dict_spot.value(forKey: "friStartTime") as! String
                                let friEndTime =  dict_spot.value(forKey: "friEndTime") as! String
                                
                                let timearr = friStartTime.components(separatedBy: ":")
                                let hour = Int(timearr[0])
                                let minutestring =  (timearr[1])
                                let arrminute = minutestring.components(separatedBy: " ")
                                let minute =  Int(arrminute[0])
                                let Start = Calendar.current.date(bySettingHour: hour!, minute: minute!, second: 0, of: Date())!
                                
                                let currentGMTOffset1: Int? = CurrentTimeZone?.secondsFromGMT(for: Start)
                                let SystemGMTOffset1: Int = SystemTimeZone.secondsFromGMT(for: Start)
                                let interval1 = TimeInterval((SystemGMTOffset1 - currentGMTOffset1!))
                                let Munday_start = Date(timeInterval: interval1, since: Start)
                                
                                let timearr1 = friEndTime.components(separatedBy: ":")
                                let hour1 = Int(timearr1[0])
                                let minutestring1 =  (timearr1[1])
                                let arrminute1 = minutestring1.components(separatedBy: " ")
                                let minute1 =  Int(arrminute1[0])
                                let End = Calendar.current.date(bySettingHour: hour1!, minute: minute1!, second: 0, of: Date())!
                                
                                let currentGMTOffset2: Int? = CurrentTimeZone?.secondsFromGMT(for: End)
                                let SystemGMTOffset2: Int = SystemTimeZone.secondsFromGMT(for: End)
                                let interval2 = TimeInterval((SystemGMTOffset2 - currentGMTOffset2!))
                                let Munday_end = Date(timeInterval: interval2, since: End)
                                
                                let currentGMTOffset3: Int? = CurrentTimeZone?.secondsFromGMT(for: start_date!)
                                let SystemGMTOffset3: Int = SystemTimeZone.secondsFromGMT(for: start_date!)
                                let interval3 = TimeInterval((SystemGMTOffset2 - currentGMTOffset2!))
                                let user_start = Date(timeInterval: interval2, since: start_date!)
                                
                                let currentGMTOffset4: Int? = CurrentTimeZone?.secondsFromGMT(for: end_date!)
                                let SystemGMTOffset4: Int = SystemTimeZone.secondsFromGMT(for: end_date!)
                                let interval4 = TimeInterval((SystemGMTOffset4 - currentGMTOffset4!))
                                let user_end = Date(timeInterval: interval4, since: end_date!)
                                
                                if user_start < Munday_start && user_end < Munday_end{
                                    arr_search_spot.add(arrspot.object(at: i))
                                }
                            }
                        }
                    }
                    if arr_day[j] == "Saturday" {
                        if (arrspot.object(at: i) as! NSDictionary).value(forKey: "satswitch") as! Bool == true{
                            let arrsat = datedaydict.value(forKey: "Saturday") as! NSArray
                            for m in 0..<arrsat.count{
                                let satStartTime =  dict_spot.value(forKey: "satStartTime") as! String
                                let satEndTime =  dict_spot.value(forKey: "satEndTime")  as! String
                                
                                let timearr = satStartTime.components(separatedBy: ":")
                                let hour = Int(timearr[0])
                                let minutestring =  (timearr[1])
                                let arrminute = minutestring.components(separatedBy: " ")
                                let minute =  Int(arrminute[0])
                                let Start = Calendar.current.date(bySettingHour: hour!, minute: minute!, second: 0, of: Date())!
                                
                                let currentGMTOffset1: Int? = CurrentTimeZone?.secondsFromGMT(for: Start)
                                let SystemGMTOffset1: Int = SystemTimeZone.secondsFromGMT(for: Start)
                                let interval1 = TimeInterval((SystemGMTOffset1 - currentGMTOffset1!))
                                let Munday_start = Date(timeInterval: interval1, since: Start)
                                
                                let timearr1 = satEndTime.components(separatedBy: ":")
                                let hour1 = Int(timearr1[0])
                                let minutestring1 =  (timearr1[1])
                                let arrminute1 = minutestring1.components(separatedBy: " ")
                                let minute1 =  Int(arrminute1[0])
                                let End = Calendar.current.date(bySettingHour: hour1!, minute: minute1!, second: 0, of: Date())!
                                
                                let currentGMTOffset2: Int? = CurrentTimeZone?.secondsFromGMT(for: End)
                                let SystemGMTOffset2: Int = SystemTimeZone.secondsFromGMT(for: End)
                                let interval2 = TimeInterval((SystemGMTOffset2 - currentGMTOffset2!))
                                let Munday_end = Date(timeInterval: interval2, since: End)
                                
                                let currentGMTOffset3: Int? = CurrentTimeZone?.secondsFromGMT(for: start_date!)
                                let SystemGMTOffset3: Int = SystemTimeZone.secondsFromGMT(for: start_date!)
                                let interval3 = TimeInterval((SystemGMTOffset2 - currentGMTOffset2!))
                                let user_start = Date(timeInterval: interval2, since: start_date!)
                                
                                let currentGMTOffset4: Int? = CurrentTimeZone?.secondsFromGMT(for: end_date!)
                                let SystemGMTOffset4: Int = SystemTimeZone.secondsFromGMT(for: end_date!)
                                let interval4 = TimeInterval((SystemGMTOffset4 - currentGMTOffset4!))
                                let user_end = Date(timeInterval: interval4, since: end_date!)
                                
                                if user_start < Munday_start && user_end < Munday_end{
                                    arr_search_spot.add(arrspot.object(at: i))
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
        view_info.isHidden = true
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        present(autocompleteController, animated: true, completion: nil)
    }
    
    // MARK:- locationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = locations.last
        self.CurrentLocMarker.position = (location?.coordinate)!
        cooridnates = (location?.coordinate)!
        self.CurrentLocMarker.title = "myLoc"
        var markerView = UIImageView()
        markerView = UIImageView(image: UIImage.init(named: "current_location_icon"))
        markerView.frame.size.width = 30
        markerView.frame.size.height = 30
        self.CurrentLocMarker.iconView = markerView
        self.CurrentLocMarker.map = self.mapView
        userlatitude = (location?.coordinate.latitude)!
        userlongitude = (location?.coordinate.longitude)!
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
    
    // GET ALL SPOT ON MAP
    func getlatlong(){
        var weekday = [String]()
        let dateformats = DateFormatter()
        dateformats.timeZone = TimeZone.current
        dateformats.dateFormat  = "EEEE"
        let dayInWeek = dateformats.string(from: Date())
        print(dayInWeek)
        
        five = 0
        refArtists = Database.database().reference().child("All_Spots");
        refArtists.observe(DataEventType.value, with: { (snapshot) in
            self.mapView.clear()
            self.CurrentLocMarker.position = self.cooridnates
            self.CurrentLocMarker.title = "myLoc"
            var markerView = UIImageView()
            markerView = UIImageView(image: UIImage.init(named: "current_location_icon"))
            markerView.frame.size.width = 30
            markerView.frame.size.height = 30
            self.CurrentLocMarker.iconView = markerView
            self.CurrentLocMarker.map = self.mapView
            
            if snapshot.childrenCount > 0 {
                self.arrspot.removeAllObjects()
                for artists in snapshot.children.allObjects as! [DataSnapshot] {
                    let snapshotValue = snapshot.value as! NSDictionary
                    let dictdata = ((snapshot.value as! NSDictionary).value(forKey: (artists as! DataSnapshot).key)) as! NSDictionary
                    if dictdata.count>0{
                        
                        for (theKey, theValue) in dictdata {
                            
                            print(theKey)
                            print(theValue)
                        
                           self.arrspot.add(theValue)
                          
                        }
                        //self.loadEventsToMap(lat: self.userlatitude, long: self.userlongitude)
                    }
                }
                
                var spot_array:NSMutableArray = NSMutableArray()
                if self.arrspot.count > 0 {
                   
                    
                    for i in 0 ..< self.arrspot.count {
                        
                        if dayInWeek == "Monday"{
                            if (self.arrspot.object(at: i) as! NSDictionary).value(forKey: "monswitch") as! Bool == true{
                            self.get_todaySpots(tag: i)
                            }
                            if (self.arrspot.object(at: i) as! NSDictionary).value(forKey: "tueswitch") as! Bool == true{
                             self.get_todaySpots(tag: i)
                            }
                            if (self.arrspot.object(at: i) as! NSDictionary).value(forKey: "wedswitch") as! Bool == true{
                               self.get_todaySpots(tag: i)
                            }
                            if (self.arrspot.object(at: i) as! NSDictionary).value(forKey: "thuswitch") as! Bool == true{
                            self.get_todaySpots(tag: i)
                            }
                            if (self.arrspot.object(at: i) as! NSDictionary).value(forKey: "friswitch") as! Bool == true{
                          self.get_todaySpots(tag: i)
                            }
                            if (self.arrspot.object(at: i) as! NSDictionary).value(forKey: "satswitch") as! Bool == true{
                             self.get_todaySpots(tag: i)
                            }
                            if (self.arrspot.object(at: i) as! NSDictionary).value(forKey: "sunswitch") as! Bool == true{
                              self.get_todaySpots(tag: i)
                            }
                        }
                        else if dayInWeek == "Tuesday"{
                            if (self.arrspot.object(at: i) as! NSDictionary).value(forKey: "tueswitch") as! Bool == true{
                              self.get_todaySpots(tag: i)
                            }
                            if (self.arrspot.object(at: i) as! NSDictionary).value(forKey: "wedswitch") as! Bool == true{
                             self.get_todaySpots(tag: i)
                            }
                            if (self.arrspot.object(at: i) as! NSDictionary).value(forKey: "thuswitch") as! Bool == true{
                             self.get_todaySpots(tag: i)
                            }
                            if (self.arrspot.object(at: i) as! NSDictionary).value(forKey: "friswitch") as! Bool == true{
                               self.get_todaySpots(tag: i)
                            }
                            if (self.arrspot.object(at: i) as! NSDictionary).value(forKey: "satswitch") as! Bool == true{
                                self.get_todaySpots(tag: i)
                            }
                            if (self.arrspot.object(at: i) as! NSDictionary).value(forKey: "sunswitch") as! Bool == true{
                              self.get_todaySpots(tag: i)
                            }
                        }
                        else if dayInWeek == "Wednesday"{
                                
                                if (self.arrspot.object(at: i) as! NSDictionary).value(forKey: "wedswitch") as! Bool == true{
                                   self.get_todaySpots(tag: i)
                                }
                                if (self.arrspot.object(at: i) as! NSDictionary).value(forKey: "thuswitch") as! Bool == true{
                                     self.get_todaySpots(tag: i)
                                }
                                if (self.arrspot.object(at: i) as! NSDictionary).value(forKey: "friswitch") as! Bool == true{
                                  self.get_todaySpots(tag: i)
                                }
                                if (self.arrspot.object(at: i) as! NSDictionary).value(forKey: "satswitch") as! Bool == true{
                                    self.get_todaySpots(tag: i)
                                }
                                if (self.arrspot.object(at: i) as! NSDictionary).value(forKey: "sunswitch") as! Bool == true{
                                         self.get_todaySpots(tag: i)
                            }
                            
                        }
                        else if dayInWeek == "Thursday"{
                                    if (self.arrspot.object(at: i) as! NSDictionary).value(forKey: "thuswitch") as! Bool == true{
                                         self.get_todaySpots(tag: i)
                                    }
                                    if (self.arrspot.object(at: i) as! NSDictionary).value(forKey: "friswitch") as! Bool == true{
                                            self.get_todaySpots(tag: i)
                                    }
                                    if (self.arrspot.object(at: i) as! NSDictionary).value(forKey: "satswitch") as! Bool == true{
                                             self.get_todaySpots(tag: i)
                                    }
                                    if (self.arrspot.object(at: i) as! NSDictionary).value(forKey: "sunswitch") as! Bool == true{
                                            self.get_todaySpots(tag: i)
                            }
                            
                        }
                        else if dayInWeek == "Friday"{
                                        if (self.arrspot.object(at: i) as! NSDictionary).value(forKey: "friswitch") as! Bool == true{
                                             self.get_todaySpots(tag: i)
                                        }
                                        if (self.arrspot.object(at: i) as! NSDictionary).value(forKey: "satswitch") as! Bool == true{
                                           self.get_todaySpots(tag: i)
                                        }
                                        if (self.arrspot.object(at: i) as! NSDictionary).value(forKey: "sunswitch") as! Bool == true{
                                              self.get_todaySpots(tag: i)
                                        }
                        }
                        else if dayInWeek == "Saturday"{
                                            if (self.arrspot.object(at: i) as! NSDictionary).value(forKey: "satswitch") as! Bool == true{
                                                  self.get_todaySpots(tag: i)
                                            }
                                            if (self.arrspot.object(at: i) as! NSDictionary).value(forKey: "sunswitch") as! Bool == true{
                                                self.get_todaySpots(tag: i)
                                            }
                         }
                        else {
                       if (self.arrspot.object(at: i) as! NSDictionary).value(forKey: "sunswitch") as! Bool == true{
                        self.get_todaySpots(tag: i)
                            
                        }
                        }
                     }
                }
              }
        })
    }
    
    func get_todaySpots(tag:Int)
    {
        let marker = GMSMarker()
        let lat1 = (self.arrspot.object(at: tag) as! NSDictionary).value(forKey: "user_lat") as! String
        let long1 = (self.arrspot.object(at: tag) as! NSDictionary).value(forKey: "user_long") as! String
        let lat = (lat1 as NSString).doubleValue
        let long = (long1 as NSString).doubleValue
        marker.position = CLLocationCoordinate2DMake(lat, long)
        marker.map = self.mapView
        let price = (self.arrspot.object(at: tag) as! NSDictionary).value(forKey: "hourlyPricing") as! String
        var doller = String()
        for (index, character) in price.enumerated() {
            if index < 4 {
                doller.append(character)
            }
        }
        marker.infoWindowAnchor = CGPoint(x: 0.5, y: 0.2)
        marker.accessibilityLabel = "\(tag)"
        
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
    }
    
    // MARK:_ Load Marker to map :-  Spot
    func loadEventsToMap(lat:Double,long:Double){
        
        // mapView.isMyLocationEnabled  = false
        
        for i in 0..<arrspot.count {
            
            let lat1 = (self.arrspot.object(at: i) as! NSDictionary).value(forKey: "user_lat") as! String
            let long1 = (self.arrspot.object(at: i) as! NSDictionary).value(forKey: "user_long") as! String
            let lats = (lat1 as NSString).doubleValue
            let longs = (long1 as NSString).doubleValue
            let coordinate₀ = CLLocation(latitude: CLLocationDegrees(lats), longitude:CLLocationDegrees(longs))
            
            
            //            let coordinate₀ = CLLocation(latitude: CLLocationDegrees(truncating: (arrspot.object(at: i) as! NSDictionary).value(forKey: "user_lat") as! NSNumber), longitude:CLLocationDegrees(truncating: (arrspot.object(at: i) as! NSDictionary).value(forKey: "user_long") as! NSNumber))
            let coordinate₁ = CLLocation(latitude: lat, longitude: long)
            let distacneinKM = (coordinate₀.distance(from: coordinate₁)/1000)
            if distacneinKM < 5 {
                print("dicstance ------<5 = \(distacneinKM)")
                print(five)
                five = five+1
                if five < 5 {
                    
                    let marker = GMSMarker()
                    
                    let lat1 = (self.arrspot.object(at: i) as! NSDictionary).value(forKey: "user_lat") as! String
                    let long1 = (self.arrspot.object(at: i) as! NSDictionary).value(forKey: "user_long") as! String
                    let lat = (lat1 as NSString).doubleValue
                    let long = (long1 as NSString).doubleValue
                    
                    marker.position = CLLocationCoordinate2DMake(lat, long)
                    marker.map = self.mapView
                    marker.map = self.mapView
                    
                    let price = (self.arrspot.object(at: i) as! NSDictionary).value(forKey: "hourlyPricing") as! String
                    var doller = String()
                    for (index, character) in price.enumerated() {
                        if index < 4 {
                            doller.append(character)
                        }
                        
                    }
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
                    lbl_marker.text = "$\(doller)"
                    lbl_marker.minimumScaleFactor = 0.5;
                    lbl_marker.adjustsFontSizeToFitWidth = true;
                    lbl_marker.textColor = UIColor.black
                    customView.backgroundColor = UIColor.clear
                    marker.iconView = customView
                    
                }
            }
        }
    }
    
    
    // Search Filter Spot -
    func Search_Spot() {
        
        if arr_search_spot.count > 0 {
            mapView.clear()
            
            self.CurrentLocMarker.position = self.cooridnates
            self.CurrentLocMarker.title = "myLoc"
            var markerView = UIImageView()
            markerView = UIImageView(image: UIImage.init(named: "current_location_icon"))
            markerView.frame.size.width = 30
            markerView.frame.size.height = 30
            self.CurrentLocMarker.iconView = markerView
            self.CurrentLocMarker.map = self.mapView
            
            for i in 0..<self.arr_search_spot.count {
                
                let marker = GMSMarker()
                let lat1 = (self.arr_search_spot.object(at: i) as! NSDictionary).value(forKey: "user_lat") as! String
                let long1 = (self.arr_search_spot.object(at: i) as! NSDictionary).value(forKey: "user_long") as! String
                let lat = (lat1 as NSString).doubleValue
                let long = (long1 as NSString).doubleValue
                
                marker.position = CLLocationCoordinate2DMake(lat, long)
                marker.map = self.mapView
                let price = (self.arr_search_spot.object(at: i) as! NSDictionary).value(forKey: "hourlyPricing") as! String
                var doller = String()
                for (index, character) in price.enumerated() {
                    if index < 4 {
                        doller.append(character)
                    }
                }
                // let doller = (price as NSString).integerValue
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
            mapView.clear()
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
        completion(arg)
    }
    
    
    // UIPICKERVIEW:_
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return timearray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int){
        if pickerView == timpic1{
            format1 = timearray[row]
        }
        if pickerView == timpic1{
            format2 = timearray[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return timearray[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var pickerLabel = view as? UILabel;
        if (pickerLabel == nil)
        {
            pickerLabel = UILabel()
            pickerLabel?.font = UIFont(name: "Montserrat", size: 14)
            pickerLabel?.textAlignment = NSTextAlignment.left
        }
        pickerLabel?.text = "     \(timearray[row])"
        return pickerLabel!;
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


