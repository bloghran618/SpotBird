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
    
    let timeformat = ["AM","PM"]
    
//    var start_date : String?
//    var end_date : String?
    
    var start_date = Date()
    var end_date:Date?
    
    var format1 = "PM"
    var format2 = "PM"
    
   
    
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        //  mapView.isMyLocationEnabled = true
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
        //dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        //dateFormatter.timeZone = TimeZone.current
        
        
        
        //         start_datepic.minimumDate = Date()
        //         end_datepic.minimumDate = Date()
        
        
        
    }
    
    // start date-
    @objc func startdatePickerChanged(picker: UIDatePicker) {
         dateFormatter.dateFormat = "dd,mm,yyyy h:mm a"
         let myStringafd = dateFormatter.string(from: start_date)
         print(myStringafd)
     
        
        if format1 == "AM"{
        let replaced = myStringafd.replacingOccurrences(of: "AM", with: "PM")
            start_date = dateFormatter.date(from: replaced)!
        }
        else{
         let replaced = myStringafd.replacingOccurrences(of: "PM", with: "AM")
          start_date = dateFormatter.date(from: replaced)!
        }
        
      
        
        
        start_date = picker.date
        print(start_date)
        
        
        
        
  }
    
    
    
    // end date-
    @objc func EnddatePickerChanged(picker: UIDatePicker) {
          end_date = picker.date
        dateFormatter.dateFormat = "dd,mm,yyyy h:mm a"
        let str = dateFormatter.string(from: end_date!)
        print(str)
        
        
        if format2 == "AM"{
            let replaced = str.replacingOccurrences(of: "AM", with: "PM")
            end_date = dateFormatter.date(from: replaced)!
        }
        else{
            let replaced = str.replacingOccurrences(of: "PM", with: "AM")
            end_date = dateFormatter.date(from: replaced)!
        }
      
        print(end_date)
       
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
            arr_search_spot.removeAllObjects()
            
            if end_date == nil{
                let addhour = calendar.date(byAdding: .hour, value: 3, to: start_date)
                end_date = addhour!
                print(end_date)
                
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
            
            print(arr_day)
            
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
             print(arrsunday)
             print(arrmonday)
             print(arrtuesday)
             print(arrwednesday)
             print(arrthuesday)
             print(arrfriday)
             print(arrsatarday)
             print(datedaydict)
                
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
            let timeformats = DateFormatter()
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
                                
                              
                                let monStartTime =  dict_spot.value(forKey: "monStartTime") as! String
                                let monEndTime =  dict_spot.value(forKey: "monEndTime")  as! String
                                
                                let timearr = monStartTime.components(separatedBy: ":")
                                let hour = Int(timearr[0])
                                let minutestring =  (timearr[1])
                                
                                let arrminute = minutestring.components(separatedBy: " ")
                                let minute =  Int(arrminute[0])
                                
                                let Start = Calendar.current.date(bySettingHour: hour!, minute: minute!, second: 0, of: Date())!
                                
                                let CurrentTimeZone1 = NSTimeZone(abbreviation: "GMT")
                                let SystemTimeZone1 = NSTimeZone.system as NSTimeZone
                                let currentGMTOffset1: Int? = CurrentTimeZone1?.secondsFromGMT(for: Start)
                                let SystemGMTOffset1: Int = SystemTimeZone1.secondsFromGMT(for: Start)
                                let interval1 = TimeInterval((SystemGMTOffset1 - currentGMTOffset1!))
                                let Munday_start = Date(timeInterval: interval1, since: Start)
                                print("Current time zone Today Date : \(Munday_start)")
                                
                                let timearr1 = monEndTime.components(separatedBy: ":")
                                let hour1 = Int(timearr1[0])
                                let minutestring1 =  (timearr1[1])
                                
                                let arrminute1 = minutestring1.components(separatedBy: " ")
                                let minute1 =  Int(arrminute1[0])
                                let End = Calendar.current.date(bySettingHour: hour1!, minute: minute1!, second: 0, of: Date())!
                                
                                let currentGMTOffset2: Int? = CurrentTimeZone1?.secondsFromGMT(for: End)
                                let SystemGMTOffset2: Int = SystemTimeZone1.secondsFromGMT(for: End)
                                let interval2 = TimeInterval((SystemGMTOffset2 - currentGMTOffset2!))
                                let Munday_end = Date(timeInterval: interval2, since: End)
                                print("Current time zone Today Date : \(Munday_end)")
                                
                                let currentGMTOffset3: Int? = CurrentTimeZone1?.secondsFromGMT(for: start_date)
                                let SystemGMTOffset3: Int = SystemTimeZone1.secondsFromGMT(for: start_date)
                                let interval3 = TimeInterval((SystemGMTOffset2 - currentGMTOffset2!))
                                let user_start = Date(timeInterval: interval2, since: start_date)
                                print("Current time zone Today Date : \(user_start)")
                                
                                let currentGMTOffset4: Int? = CurrentTimeZone1?.secondsFromGMT(for: end_date!)
                                let SystemGMTOffset4: Int = SystemTimeZone1.secondsFromGMT(for: end_date!)
                                let interval4 = TimeInterval((SystemGMTOffset4 - currentGMTOffset4!))
                                let user_end = Date(timeInterval: interval4, since: end_date!)
                                  print("Current time zone Today Date : \(user_end)")
                                
                                print("user_start\(user_start)")
                                print("user_end\(user_end)")
                                
                                print("Munday_start\(Munday_start)")
                                print("Munday_end\(Munday_end)")
                                
                               
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
                                
                              if user_start < Munday_start && user_end > Munday_end{
                                    arr_search_spot.add(arrspot.object(at: i))
                                    print(arr_search_spot)
                                    
                                }
                                
                                /*
                                
                                let dateToday = Date()
                                print(dateToday)

                                // create dateFormatter with UTC time format
                                let dateFormatter = DateFormatter()
                                dateFormatter.dateFormat = "yyyy-MM-dd' 'HH:mm:ss"
                                dateFormatter.timeZone = NSTimeZone.local

                                let date = dateFormatter.date(from: dateFormatter.string(from: dateToday))// create   date from string

                                // change to a readable time format and change to local time zone
                                dateFormatter.dateFormat = "EEE, MMM d, yyyy - h:mm a"
                                dateFormatter.timeZone = NSTimeZone.local
                                let timeStamp = dateFormatter.string(from: date!)
                                let datee  = dateFormatter.date(from: timeStamp)
                                print(timeStamp)
                                
                                let monStartTime =  dict_spot.value(forKey: "monStartTime") as! String
                                let monEndTime =  dict_spot.value(forKey: "monEndTime")  as! String

                                let timearr = monStartTime.components(separatedBy: ":")
                                let hour = Int(timearr[0])
                                let minutestring =  (timearr[1])

                                 let arrminute = minutestring.components(separatedBy: " ")
                                 let minute =  Int(arrminute[0])

                                let Start = Calendar.current.date(bySettingHour: hour!, minute: minute!, second: 0, of: Date())!

                                let timearr1 = monEndTime.components(separatedBy: ":")
                                let hour1 = Int(timearr1[0])
                                let minutestring1 =  (timearr1[1])

                                let arrminute1 = minutestring1.components(separatedBy: " ")
                                let minute1 =  Int(arrminute1[0])

                                let End = Calendar.current.date(bySettingHour: hour1!, minute: minute1!, second: 0, of: Date())!

                                formatter.dateFormat = "dd,mm,yyy h:mm a"
                                formatter.timeZone = TimeZone.current
                                let dbstart =  formatter.string(from: Start)
                                print(dbstart)

                                let dbend =  formatter.string(from: End)
                                print(dbend)

                                let sa = formatter.date(from: dbend)
                                print(sa)
//
                              */
                                

                                
                                
                                
                                
                                
                                
                                
//                                var time1 = "08:15:12"
//                                var time2 = "18:12:08"
//
//                                var formatter = DateFormatter()
//                                formatter.dateFormat = "HH:mm:ss"
//
//                                var date1: Date? = formatter.date(from: time1)
//                                var date2: Date? = formatter.date(from: time2)
//
//                                var result: ComparisonResult? = nil
//                                if let aDate2 = date2 {
//                                    result = date1?.compare(aDate2)
//                                }
//                                if result == .orderedDescending {
//                                    print("date1 is later than date2")
//                                } else if result == .orderedAscending {
//                                    print("date2 is later than date1")
//                                } else {
//                                    print("date1 is equal to date2")
//                                }
                                
                                
//                                 let dateMunday = Date()
//                                 formatter.dateFormat = "HH:mm"
//                                 formatter.calendar = NSCalendar.current
//                                 formatter.timeZone = TimeZone.current
//                                 let mundaymain = formatter.string(from: dateMunday)
//
//                                let monStartTime =  dict_spot.value(forKey: "monStartTime") as! String
//                                let monEndTime =  dict_spot.value(forKey: "monEndTime")  as! String
//
//                                timeformats.dateFormat = "h:mm a"
//                                let st1 = timeformats.date(from: monStartTime)
//                                let ed1 = timeformats.date(from: monStartTime)
//                                timeformats.dateFormat = "HH:mm"
//                                let Start = timeformats.string(from: st1!)
//                                let End = timeformats.string(from: ed1!)
//
//                                print(Start)
//                                print(End)
//                                print(mundaymain)
                                

//                                if mundaymain > Start && mundaymain < End
//                                  {
//                                 arr_search_spot.add(arrspot.object(at: i))
//                                  print(arr_search_spot)
//
//                                  }
                                
                                
                               
                                
                                
                                
//                                // let dateSunday =  datedaydict.value(forKey: "Sunday") as!  Date
//                                formatter.dateFormat = "HH.mm a"
//                                let munday = formatter.string(from: dateMunday)
//
//                                let monStartTime =  dict_spot.value(forKey: "monStartTime")
//                                let monEndTime =  dict_spot.value(forKey: "monEndTime")
//
//                                formatter.dateFormat = "h:mm a"
//                                let datestart = formatter.date(from: monStartTime as! String)
//                                let dateend = formatter.date(from: monEndTime as! String)
//
//                                formatter.dateFormat = "HH.mm"
//                                let Start_Munday = formatter.string(from: datestart!)
//                                let End_munday = formatter.string(from: dateend!)
//
//                                let mundaymain = (munday as NSString).floatValue
//                                let Start = (Start_Munday as NSString).floatValue
//                                let End = (End_munday as NSString).floatValue
//
//                                print(mundaymain)
//                                print(Start)
//                                print(End)
//
//
//                                if mundaymain > Start && mundaymain < End
//                                {
//                                    arr_search_spot.add(arrspot.object(at: i))
//                                    print(arr_search_spot)
//
//                                }
                                
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
    
    // GET ALL SPOT ON MAP
    func getlatlong(){
        five = 0
        print("SAAas")
        
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
                if self.arrspot.count > 0 {
                    print(self.arrspot)
                    print(self.arrspot.count)
                    
                    
                    
                    for i in 0 ..< self.arrspot.count {
                        let marker = GMSMarker()
                        
                        let lat1 = (self.arrspot.object(at: i) as! NSDictionary).value(forKey: "user_lat") as! String
                        let long1 = (self.arrspot.object(at: i) as! NSDictionary).value(forKey: "user_long") as! String
                        let lat = (lat1 as NSString).doubleValue
                        let long = (long1 as NSString).doubleValue
                        
                        marker.position = CLLocationCoordinate2DMake(lat, long)
                        marker.map = self.mapView
                        let price = (self.arrspot.object(at: i) as! NSDictionary).value(forKey: "hourlyPricing") as! String
                        var doller = String()
                        for (index, character) in price.enumerated() {
                            if index < 4 {
                                doller.append(character)
                            }
                            
                        }
                        
                        print(doller)
                        
                        //  let doller = (price as NSString).integerValue
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
                        
                        lbl_marker.text = "$\(doller)"
                        lbl_marker.minimumScaleFactor = 0.5;
                        lbl_marker.adjustsFontSizeToFitWidth = true;
                        
                        lbl_marker.textColor = UIColor.black
                        customView.backgroundColor = UIColor.clear
                        marker.iconView = customView
                    }
                }
            }
        })
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
                    
                    //                    marker.position = CLLocationCoordinate2DMake(Double(truncating: (arrspot.object(at: i) as! NSDictionary).value(forKey: "user_lat") as! NSNumber), Double(truncating: (arrspot.object(at: i) as! NSDictionary).value(forKey: "user_long") as! NSNumber))
                    marker.map = self.mapView
                    marker.map = self.mapView
                    
                    let price = (self.arrspot.object(at: i) as! NSDictionary).value(forKey: "hourlyPricing") as! String
                    var doller = String()
                    for (index, character) in price.enumerated() {
                        if index < 4 {
                            doller.append(character)
                        }
                        
                    }
                    
                    print(doller)
                    //  let doller = (price as NSString).integerValue
                    //marker.title = "$\(doller)"
                    //     marker.snippet
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
                
                
                //            marker.position = CLLocationCoordinate2DMake(Double(truncating: (self.arr_search_spot.object(at: i) as! NSDictionary).value(forKey: "user_lat") as! NSNumber), Double(truncating: (self.arr_search_spot.object(at: i) as! NSDictionary).value(forKey: "user_long") as! NSNumber))
                marker.map = self.mapView
                let price = (self.arr_search_spot.object(at: i) as! NSDictionary).value(forKey: "hourlyPricing") as! String
                var doller = String()
                for (index, character) in price.enumerated() {
                    if index < 4 {
                        doller.append(character)
                    }
                    
                }
                
                print(doller)
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
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return timeformat.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int){
        if pickerView == timpic1{
           format1 = timeformat[row]
        }
        if pickerView == timpic1{
           format2 = timeformat[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return timeformat[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var pickerLabel = view as? UILabel;
        if (pickerLabel == nil)
        {
            pickerLabel = UILabel()
            pickerLabel?.font = UIFont(name: "Montserrat", size: 14)
            pickerLabel?.textAlignment = NSTextAlignment.left
        }
        pickerLabel?.text = "     \(timeformat[row])"
        return pickerLabel!;
    }
   

}
