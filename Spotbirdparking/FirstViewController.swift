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
import Stripe

class FirstViewController: UIViewController,CLLocationManagerDelegate,GMSMapViewDelegate,GMSAutocompleteViewControllerDelegate,UIPickerViewDataSource,UIPickerViewDelegate, STPPaymentContextDelegate{
    
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
    @IBOutlet weak var lbl1: UILabel!
    @IBOutlet weak var lbl2: UILabel!
    @IBOutlet weak var btn_cancel: UIButton!
    @IBOutlet weak var btn_done: UIButton!
    
    @IBOutlet weak var start_datepic: UIDatePicker!
    @IBOutlet weak var end_datepic: UIDatePicker!
    let dateFormatter = DateFormatter()
    
    @IBOutlet weak var timpic1: UIPickerView!
    @IBOutlet weak var timepic2: UIPickerView!
    
    fileprivate lazy var dateFormatter2: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd h:mm a"
       // formatter.timeZone = TimeZone.current
        return formatter
    }()
    
   
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
    var endChange = false
    
    // initialize highlighted spot to null
    var highlightedSpot: Spot!
    
    // Stripe setup
    var profileOptions: [ProfileTableOption]?
    let cellIdentifier = "profileTableCell"
    
    let config = STPPaymentConfiguration.shared()
    let customerContext = STPCustomerContext(keyProvider: MyAPIClient.sharedClient)
    
    let paymentContext = STPPaymentContext(customerContext: STPCustomerContext(keyProvider: MyAPIClient.sharedClient))
    
//    let stripePublishableKey = "pk_test_TV3DNqRM8DCQJEcvMGpayRRj"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
         AppState.sharedInstance.activeSpot.getSpots()
        
     
        
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
        //self.locationManager.requestWhenInUseAuthorization()
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
        end_datepic.minimumDate = calendar.date(byAdding: .hour, value: 3, to:  Date())
        // list load
        
        Date_VIew.layer.cornerRadius = 5;
        Date_VIew.layer.masksToBounds = true;
        Date_VIew.layer.borderWidth = 1
        Date_VIew.layer.borderColor = UIColor.blue.cgColor
        
        btn_cancel.layer.cornerRadius = 5;
        btn_cancel.layer.masksToBounds = true;
        btn_cancel.layer.borderWidth = 2
        btn_cancel.layer.borderColor = UIColor.darkGray.cgColor
        
        btn_done.layer.cornerRadius = 5;
        btn_done.layer.masksToBounds = true;
        btn_done.layer.borderWidth = 2
        btn_done.layer.borderColor = UIColor.darkGray.cgColor
        
        lbl1.layer.cornerRadius = 5;
        lbl1.layer.masksToBounds = true;
        lbl1.layer.borderWidth = 2
        lbl1.layer.borderColor = UIColor.darkGray.cgColor
        
        lbl2.layer.cornerRadius = 5;
        lbl2.layer.masksToBounds = true;
        lbl2.layer.borderWidth = 2
        lbl2.layer.borderColor = UIColor.darkGray.cgColor
      }
    
     func viewWillAppear(animated: Bool) {
        //debug:
        MyAPIClient.sharedClient.createCustomerID()
        MyAPIClient.sharedClient.createAccountID()
        super.viewWillAppear(animated)
    }
    
    func timearrayset()  {
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:a"
        let stringdate = dateFormatter.string(from: Date())
    
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
        
       
        /*
        print(picker.date)
       
        let myStringafd = dateFormatter2.string(from: picker.date)
        print(myStringafd)
        
        if myStringafd.contains("AM")
        {
            if format1 == "AM"
            {
                start_date = dateFormatter2.date(from: myStringafd)!
            }else
            {
                let replaced = myStringafd.replacingOccurrences(of: "AM", with: "PM")
                start_date = dateFormatter2.date(from: replaced)!
            }
            print(start_date!)
        }else
        {
            if format1 == "PM"
            {
                start_date = dateFormatter2.date(from: myStringafd)

            }else
            {
                let replaced = myStringafd.replacingOccurrences(of: "PM", with: "AM")
                start_date = dateFormatter2.date(from: replaced)!
            }
            print(start_date)
            
         }
        
        print(start_date)  */
        
//        dateFormatter.dateFormat = "EEE, MMM d, yyyy - h:mm a"
//        dateFormatter.timeZone = NSTimeZone.local
//        let timeStamp = dateFormatter.string(from: start_date!)
//        print(timeStamp)
//
//        let timearr = timeStamp.components(separatedBy: " ")
//        let timearr1 = timearr[5].components(separatedBy: ":")
//        let hour = timearr1[0]
//        let minute = timearr1[1]
//        let symbol = (timearr[6])
//
//        dateFormatter.dateFormat = "dd-MM-yyyy"
//        let datenew = dateFormatter.string(from: start_date!)
//        print(datenew)
        
       print(start_date)
       
       
        
      }
   
    
    // end date-
    @objc func EnddatePickerChanged(picker: UIDatePicker) {
        
        endChange = true
     /*
      dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:a"
        var str = dateFormatter2.string(from: picker.date)
        
        if str.contains("AM")
        {
            if format2 == "AM"
            {
                end_date = dateFormatter2.date(from: str)!
            }else
            {
                let replaced = str.replacingOccurrences(of: "AM", with: "PM")
                end_date = dateFormatter2.date(from: replaced)!
            }
            print(end_date!)
        }else
        {
            if format2 == "PM"
            {
                end_date = dateFormatter2.date(from: str)!
                
            }else
            {
                let replaced = str.replacingOccurrences(of: "PM", with: "AM")
                end_date = dateFormatter2.date(from: replaced)!
            }
            print(end_date!)
        }
         */
      
       
    }
    
    // MARK:_ BTn Date searching
    @IBAction func btn_Date_search(_ sender: UIButton) {
        view_info.isHidden = true
        btn_close.isHidden = true
        if Date_VIew.isHidden == true{
        // Date_VIew.isHidden = false
            
            UIView.transition(with: Date_VIew, duration: 0.3, options: .transitionCurlDown, animations: {
                self.Date_VIew.isHidden = false
            })
            
        }
        else{
            Date_VIew.isHidden = true
        }
        start_datepic.date = Date()
        end_datepic.date = Date()
    }
    
    // MARK:_ BTn Date searching close
    @IBAction func btn_Date_search_close(_ sender: UIButton) {
        Date_VIew.isHidden = true
        start_datepic.date = Date()
        end_datepic.date = Date()
    }
    
    // MARK:_ BTn Date searching Done
    @IBAction func btn_Date_search_done(_ sender: UIButton) {
        
        var time1 = Bool()
       
        // start date time check today
            let myStringafd = dateFormatter2.string(from: start_datepic.date)
            print(myStringafd)
            if myStringafd.contains("AM")
            {
                if format1 == "AM"
                {
                    start_date = dateFormatter2.date(from: myStringafd)!
                }else
                {
                    let replaced = myStringafd.replacingOccurrences(of: "AM", with: "PM")
                    start_date = dateFormatter2.date(from: replaced)!
                }
                print(start_date!)
            }else
            {
                if format1 == "PM"
                {
                    start_date = dateFormatter2.date(from: myStringafd)!
                    
                }else
                {
                    let replaced = myStringafd.replacingOccurrences(of: "PM", with: "AM")
                    start_date = dateFormatter2.date(from: replaced)!
                }
                print(start_date!)
            }
        
      if (datetostring(dates: start_date!)) == (datetostring(dates: Date())) {
        
         let usertime = datetotime(userdate: dateconvert(userdate: start_date!))
         print(usertime)
        
        let Datesystmem = datetotime(userdate: dateconvert(userdate: Date()))
        print(Datesystmem)
        
        if usertime != Datesystmem && usertime < Datesystmem {
            time1 = true
        }
     }
        
        print(time1)
        var firsttime = Bool()
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:a"
        if endChange == false {
            print(start_date)
            print(end_date)
            
            let addhour = calendar.date(byAdding: .hour, value: 3, to: start_date!)
            end_date = addhour!
            print(addhour)
            print(end_date)
        }
        
        // End date time check today
        if endChange == true {
            var str = dateFormatter2.string(from: end_datepic.date)
            
            if str.contains("AM")
            {
                if format2 == "AM"
                {
                    end_date = dateFormatter2.date(from: str)!
                }else
                {
                    let replaced = str.replacingOccurrences(of: "AM", with: "PM")
                    end_date = dateFormatter2.date(from: replaced)!
                }
                print(end_date!)
            }
                
            else
            {
                if format2 == "PM"
                {
                    end_date = dateFormatter2.date(from: str)!
                    
                }else
                {
                    let replaced = str.replacingOccurrences(of: "PM", with: "AM")
                    end_date = dateFormatter2.date(from: replaced)!
                }
                print(end_date!)
            }
            
        }
        
        start_date = dateconvert(userdate: start_date!)
        end_date = dateconvert(userdate: end_date!)
    
        if time1 == true{
              time1 = false
              let alert = UIAlertController(title: "Spotbirdparking", message: "Invalid Start TIME", preferredStyle: .alert)
              alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
              self.present(alert, animated: true, completion: nil)
         }
         else if (datetostring(dates: end_date!))  < (datetostring(dates: start_date!)) && (datetostring(dates: start_date!)) != (datetostring(dates: end_date!))
         {
            let alert = UIAlertController(title: "Spotbirdparking", message: "Start date greater than End date.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else if (datetostring(dates: end_date!)) == (datetostring(dates: start_date!)) && end_date!.time < start_date!.time {
            let alert = UIAlertController(title: "Spotbirdparking", message: "End Time greater than Start date.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
       else{
            dateFormatter.dateFormat = "EEE, MMM d, yyyy - h:mm a"
            let localtime1 = dateFormatter2.string(from: start_date!)
            let localtime2 = dateFormatter2.string(from: end_date!)
            arr_search_spot.removeAllObjects()
            
            var arr_date = [Date]()
            var arr_day = [String]()
            var date = start_datepic.date
            while date <= end_datepic.date{
               arr_date.append(date)
               date = calendar.date(byAdding: .day, value: 1, to: date)!
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
            
            print(arr_day)
            print(datedaydict)
            
            
          for i in 0..<arrspot.count{
                for j in 0..<arr_day.count{
                    let dict_spot = arrspot.object(at: i) as! NSDictionary
                    
                    var localTimeZoneName: String { return TimeZone.current.identifier }
                    print(localTimeZoneName)
                    
                     if arr_day[j] == "Sunday" {
                        if (arrspot.object(at: i) as! NSDictionary).value(forKey: "sunswitch") as! Bool == true{
                            
                            let arrsun = datedaydict.value(forKey: "Sunday") as! NSArray
                            for m in 0..<arrsun.count{

                                let sunStartTime = dateconvertServer(userdate: dict_spot.value(forKey: "sunStartTime") as! String)
                                let sunEndTime = dateconvertServer(userdate: dict_spot.value(forKey: "sunEndTime")  as! String)
                                
                                let server_start1 = datetotime(userdate: sunStartTime)
                                let server_end1 = datetotime(userdate: sunEndTime)
                                print("server   - \(server_start1)")     // server
                                print("server     - \(server_end1)")     // server
                                
                                let user_start = datetotime(userdate: start_date!)
                                let user_end = datetotime(userdate: end_date!)
                                
                                print("user_start   - \(user_start)")     // user
                                print("user_end     - \(user_end)")     // user
                                
                                
                                if user_start >= server_start1 && user_end <= server_end1{
                                    arr_search_spot.add(arrspot.object(at: i))
                                }
                                
                            }
                        }
                    }
                   if arr_day[j] == "Monday" {
                        if (arrspot.object(at: i) as! NSDictionary).value(forKey: "monswitch") as! Bool == true{
                            
                            let arrmun = datedaydict.value(forKey: "Monday") as! NSArray
                            for m in 0..<arrmun.count{
                                
                                let Munday_start = dateconvertServer(userdate: dict_spot.value(forKey: "monStartTime") as! String)
                               let Munday_end = dateconvertServer(userdate: dict_spot.value(forKey: "monEndTime")  as! String)
                                
                                let server_start1 = datetotime(userdate: Munday_start)
                                let server_end1 = datetotime(userdate: Munday_end)
                                print("server   - \(server_start1)")     // server
                                print("server     - \(server_end1)")     // server
                                
                                let user_start = datetotime(userdate: start_date!)
                                let user_end = datetotime(userdate: end_date!)
                                
                                print("user_start   - \(user_start)")     // user
                                print("user_end     - \(user_end)")     // user
                                
                                
                                if user_start >= server_start1 && user_end <= server_end1{
                                    arr_search_spot.add(arrspot.object(at: i))
                                }
                              
                            }
                        }
                    }
                    if arr_day[j] == "Tuesday" {
                        if (arrspot.object(at: i) as! NSDictionary).value(forKey: "tueswitch") as! Bool == true{
                            
                            let arrthue = datedaydict.value(forKey: "Tuesday") as! NSArray
                            for m in 0..<arrthue.count{
                                
                                let tueStartTime = dateconvertServer(userdate: dict_spot.value(forKey: "tueStartTime") as! String)
                                let tueEndTime = dateconvertServer(userdate: dict_spot.value(forKey: "tueEndTime")  as! String)
                                
                                let server_start1 = datetotime(userdate: tueStartTime)
                                let server_end1 = datetotime(userdate: tueEndTime)
                                print("server   - \(server_start1)")     // server
                                print("server     - \(server_end1)")     // server
                                
                                let user_start = datetotime(userdate: start_date!)
                                let user_end = datetotime(userdate: end_date!)
                                
                                print("user_start   - \(user_start)")     // user
                                print("user_end     - \(user_end)")     // user
                                
                                if user_start >= server_start1 && user_end <= server_end1{
                                    arr_search_spot.add(arrspot.object(at: i))
                                }
                             }
                        }
                     }
                    if arr_day[j] == "Wednesday" {
                        if (arrspot.object(at: i) as! NSDictionary).value(forKey: "wedswitch") as! Bool == true{
                            
                            let arrwed = datedaydict.value(forKey: "Wednesday") as! NSArray
                            for m in 0..<arrwed.count{
                                
                     let wedStartTime = dateconvertServer(userdate: dict_spot.value(forKey: "wedStartTime") as! String)
                     let wedEndTime = dateconvertServer(userdate: dict_spot.value(forKey: "wedEndTime")  as! String)
                                
                                let server_start1 = datetotime(userdate: wedStartTime)
                                let server_end1 = datetotime(userdate: wedEndTime)
                                print("server   - \(server_start1)")     // server
                                print("server     - \(server_end1)")     // server
                                
                                let user_start = datetotime(userdate: start_date!)
                                let user_end = datetotime(userdate: end_date!)
                                
                                print("user_start   - \(user_start)")     // user
                                print("user_end     - \(user_end)")     // user
                                
                                if user_start >= server_start1 && user_end <= server_end1{
                                    arr_search_spot.add(arrspot.object(at: i))
                                }
                             }
                        }
                     }
                    if arr_day[j] == "Thursday" {
                       
                        if (arrspot.object(at: i) as! NSDictionary).value(forKey: "thuswitch") as! Bool == true{
                            
                        let arrThu = datedaydict.value(forKey: "Thursday") as! NSArray
                        for m in 0..<arrThu.count{
                             
                        let thuStartTime = dateconvertServer(userdate: dict_spot.value(forKey: "thuStartTime") as! String)
                        let thuEndTime = dateconvertServer(userdate: dict_spot.value(forKey: "thuEndTime")  as! String)
                      
                            let server_start1 = datetotime(userdate: thuStartTime)
                            let server_end1 = datetotime(userdate: thuEndTime)
                            print("server   - \(server_start1)")     // server
                            print("server     - \(server_end1)")     // server
                            
                            let user_start = datetotime(userdate: start_date!)
                            let user_end = datetotime(userdate: end_date!)
                            
                            print("user_start   - \(user_start)")     // user
                            print("user_end     - \(user_end)")     // user
                            
                            if user_start >= server_start1 && user_end <= server_end1{
                                arr_search_spot.add(arrspot.object(at: i))
                            }
                          }
                        }
                    }
                    if arr_day[j] == "Friday" {
                        if (arrspot.object(at: i) as! NSDictionary).value(forKey: "friswitch") as! Bool == true{
                            
                            let arrFri = datedaydict.value(forKey: "Friday") as! NSArray
                            for m in 0..<arrFri.count{
                               
                                print(dict_spot.value(forKey: "friStartTime") as! String)
                                print(dict_spot.value(forKey: "friEndTime")  as! String)
                                
                                let friStartTime = dateconvertServer(userdate: dict_spot.value(forKey: "friStartTime") as! String)
                                let friEndTime = dateconvertServer(userdate: dict_spot.value(forKey: "friEndTime")  as! String)
                                print(friStartTime)
                                print(friEndTime)
                                
                                let server_start1 = datetotime(userdate: friStartTime)
                                let server_end1 = datetotime(userdate: friEndTime)
                                print("server   - \(server_start1)")     // server
                                print("server     - \(server_end1)")     // server
                                
                                let user_start = datetotime(userdate: start_date!)
                                let user_end = datetotime(userdate: end_date!)
                                
                                print("user_start   - \(user_start)")     // user
                                print("user_end     - \(user_end)")     // user
                                
                                if user_start >= server_start1 && user_end <= server_end1{
                                    arr_search_spot.add(arrspot.object(at: i))
                                }
                            }
                        }
                    }
                    if arr_day[j] == "Saturday" {
                        if (arrspot.object(at: i) as! NSDictionary).value(forKey: "satswitch") as! Bool == true{
                            let arrsat = datedaydict.value(forKey: "Saturday") as! NSArray
                            for m in 0..<arrsat.count{
                                let satStartTime = dateconvertServer(userdate: dict_spot.value(forKey: "satStartTime") as! String)
                                let satEndTime = dateconvertServer(userdate: dict_spot.value(forKey: "satEndTime")  as! String)
                                
                                let server_start1 = datetotime(userdate: satStartTime)
                                let server_end1 = datetotime(userdate: satEndTime)
                                print("server   - \(server_start1)")     // server
                                print("server     - \(server_end1)")     // server
                                
                                let user_start = datetotime(userdate: start_date!)
                                let user_end = datetotime(userdate: end_date!)
                                
                                print("user_start   - \(user_start)")     // user
                                print("user_end     - \(user_end)")     // user
                                
                                if user_start >= server_start1 && user_end <= server_end1{
                                    arr_search_spot.add(arrspot.object(at: i))
                                }
                            }
                        }
                    }
                }
            }
        print(arr_search_spot)
            // Search Data load marker:-
            Search_Spot()
          Date_VIew.isHidden = true
         }
        endChange = false
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
        
        // debug line, should be removed
        print("Lets do some booking!")

        // create reservation to be sent to the parker
        let parkerReservation = Reservation(
            startDateTime: Reservation.dateToString(date: start_datepic.date),
            endDateTime: Reservation.dateToString(date: end_datepic.date),
            parkOrRent: "Park",
            spot: self.highlightedSpot,
            parkerID: AppState.sharedInstance.userid
            )
        
        // create reservation to be sent to the spot owner
        let ownerReservation = Reservation(
            startDateTime: Reservation.dateToString(date: start_datepic.date),
            endDateTime: Reservation.dateToString(date: end_datepic.date),
            parkOrRent: "Rent",
            spot: self.highlightedSpot,
            parkerID: AppState.sharedInstance.userid
        )
        
        // get source for payment
        let source = AppState.sharedInstance.user.customertoken
    
        // get destination for payment
        let ownerID = self.highlightedSpot.owner_ids
        AppState.sharedInstance.appStateRoot.child("User").child(ownerID).observeSingleEvent(of: .value, with: { (snapshot) in
            let userDict = snapshot.value as! [String: Any]
            let destination = userDict["accountToken"] as! String
            print("Destination is: \(destination)")
            
            // get integer value for amount for payment
            let amount = Int((NumberFormatter().number(from: (parkerReservation?.price)!)!.floatValue) * 100)
            print("Price (cents): \(amount)")
            
            // make payment
            self.setPaymentContext(price: amount)
            self.paymentContext.requestPayment()
            //            MyAPIClient.sharedClient.spotPurchase(sourceID: source, destinationID: destination, amount: amount)
//            { (token, error) in
//                if let error = error {
//                    print(error)
//                    let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
//                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
//                    self.present(alert, animated: true, completion: nil)
//                }
//                else {
//                    print("We have sent a payment")
//                }
//            }
        })
        
        print("Some quick debug/learning")
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
         self.locationManager.stopUpdatingLocation()
        getlatlong()
       
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
        
        print("We did tap a marker")
        
        let index:Int! = Int(marker.accessibilityLabel!)
            print("Index is: \(String(index))")
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
            
            // specify which spot is highlighted
            // Should I do this asynchronously?
            self.highlightedSpot = Spot(address: ((arrspot.object(at: index) as! NSDictionary).value(forKey: "address") as?  String) ?? "",
                                        town: (arrspot.object(at: index) as! NSDictionary).value(forKey: "city") as?  String ?? "",
                                        state: (arrspot.object(at: index) as! NSDictionary).value(forKey: "state") as?  String ?? "",
                                        zipCode: (arrspot.object(at: index) as! NSDictionary).value(forKey: "zipcode") as?  String ?? "",
                                        spotImage: (arrspot.object(at: index) as! NSDictionary).value(forKey: "image") as?  String ?? "",
                                        description: (arrspot.object(at: index) as! NSDictionary).value(forKey: "description") as?  String ?? "",
                                        monStartTime: (arrspot.object(at: index) as! NSDictionary).value(forKey: "monStartTime") as?  String ?? "",
                                        monEndTime: (arrspot.object(at: index) as! NSDictionary).value(forKey: "monEndTime") as?  String ?? "",
                                        tueStartTime: (arrspot.object(at: index) as! NSDictionary).value(forKey: "tueStartTime") as?  String ?? "",
                                        tueEndTime: (arrspot.object(at: index) as! NSDictionary).value(forKey: "tueEndTime") as?  String ?? "",
                                        wedStartTime: (arrspot.object(at: index) as! NSDictionary).value(forKey: "wedStartTime") as?  String ?? "",
                                        wedEndTime: (arrspot.object(at: index) as! NSDictionary).value(forKey: "wedEndTime") as?  String ?? "",
                                        thuStartTime: (arrspot.object(at: index) as! NSDictionary).value(forKey: "thuStartTime") as?  String ?? "",
                                        thuEndTime: (arrspot.object(at: index) as! NSDictionary).value(forKey: "thuEndTime") as?  String ?? "",
                                        friStartTime: (arrspot.object(at: index) as! NSDictionary).value(forKey: "friStartTime") as?  String ?? "",
                                        friEndTime: (arrspot.object(at: index) as! NSDictionary).value(forKey: "friEndTime") as?  String ?? "",
                                        satStartTime: (arrspot.object(at: index) as! NSDictionary).value(forKey: "satStartTime") as?  String ?? "",
                                        satEndTime: (arrspot.object(at: index) as! NSDictionary).value(forKey: "satEndTime") as?  String ?? "",
                                        sunStartTime: (arrspot.object(at: index) as! NSDictionary).value(forKey: "sunStartTime") as?  String ?? "",
                                        sunEndTime: (arrspot.object(at: index) as! NSDictionary).value(forKey: "sunEndTime") as?  String ?? "",
                                        monOn: (arrspot.object(at: index) as! NSDictionary).value(forKey: "monSwitch") as?  Bool ?? false,
                                        tueOn: (arrspot.object(at: index) as! NSDictionary).value(forKey: "tueSwitch") as?  Bool ?? false,
                                        wedOn: (arrspot.object(at: index) as! NSDictionary).value(forKey: "wedSwitch") as?  Bool ?? false,
                                        thuOn: (arrspot.object(at: index) as! NSDictionary).value(forKey: "thuSwitch") as?  Bool ?? false,
                                        friOn: (arrspot.object(at: index) as! NSDictionary).value(forKey: "friSwitch") as?  Bool ?? false,
                                        satOn: (arrspot.object(at: index) as! NSDictionary).value(forKey: "satSwitch") as?  Bool ?? false,
                                        sunOn: (arrspot.object(at: index) as! NSDictionary).value(forKey: "sunSwitch") as?  Bool ?? false,
                                        hourlyPricing: (arrspot.object(at: index) as! NSDictionary).value(forKey: "hourlyPricing") as?  String ?? "",
                                        dailyPricing: (arrspot.object(at: index) as! NSDictionary).value(forKey: "dailyPricing") as?  String ?? "",
                                        weeklyPricing: (arrspot.object(at: index) as! NSDictionary).value(forKey: "weeklyPricing") as?  String ?? "",
                                        monthlyPricing: (arrspot.object(at: index) as! NSDictionary).value(forKey: "monthlyPricing") as?  String ?? "",
                                        weeklyOn: (arrspot.object(at: index) as! NSDictionary).value(forKey: "weeklyOn") as?  Bool ?? false,
                                        monthlyOn: (arrspot.object(at: index) as! NSDictionary).value(forKey: "monthlyOn") as?  Bool ?? false,
                                        index: index,
                                        approved: true,
                                        spotImages: img_spot.image ?? UIImage(named: "white")!,
                                        spots_id: (arrspot.object(at: index) as! NSDictionary).value(forKey: "id") as?  String ?? "",
                                        latitude: (arrspot.object(at: index) as! NSDictionary).value(forKey: "latitude") as?  String ?? "",
                                        longitude: (arrspot.object(at: index) as! NSDictionary).value(forKey: "longitude") as?  String ?? "",
                                        spottype: (arrspot.object(at: index) as! NSDictionary).value(forKey: "spot_type") as?  String ?? "",
                                        owner_id: (arrspot.object(at: index) as! NSDictionary).value(forKey: "owner_id") as?  String ?? "",
                                        Email: (arrspot.object(at: index) as! NSDictionary).value(forKey: "Email") as?  String ?? "", baseprice: (arrspot.object(at: index) as! NSDictionary).value(forKey: "basePricing") as?  String ?? "")
        
        // debug lines, can get rid of eventually
        print("Highlighted Spot Address is: \(self.highlightedSpot.address)")
        print("Highlighted Spot Email is: \(self.highlightedSpot.Email)")
        
        return true
    }
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        fetchMapData(lat: markerlatitude, long: markerlongitude)
    }
    
    // GET ALL SPOT ON MAP
    func getlatlong(){
        
        Spinner.start()
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
                   
                     for tag in 0 ..< self.arrspot.count {
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
                     Spinner.stop()
                }
              }
            else{
               Spinner.stop()
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
      Spinner.start()
        for i in 0..<arrspot.count {
            
            let lat1 = (self.arrspot.object(at: i) as! NSDictionary).value(forKey: "user_lat") as! String
            let long1 = (self.arrspot.object(at: i) as! NSDictionary).value(forKey: "user_long") as! String
            let lats = (lat1 as NSString).doubleValue
            let longs = (long1 as NSString).doubleValue
            let coordinate₀ = CLLocation(latitude: CLLocationDegrees(lats), longitude:CLLocationDegrees(longs))
            
           //  let coordinate₀ = CLLocation(latitude: CLLocationDegrees(truncating: (arrspot.object(at: i) as! NSDictionary).value(forKey: "user_lat") as! NSNumber), longitude:CLLocationDegrees(truncating: (arrspot.object(at: i) as! NSDictionary).value(forKey: "user_long") as! NSNumber))
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
              //  Spinner.stop()
            }
            else{
          //    Spinner.stop()
                
             }
         }
         Spinner.stop()
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
        let today = Date()
        
        if pickerView == timpic1{
            format1 = timearray[row]
        }
        if pickerView == timepic2{
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
    
    func dateconvertServer(userdate:String) -> Date {
        var today:Date?
        let endIndex1 = userdate.index(userdate.endIndex, offsetBy: -6)
        let str1 = userdate.substring(to: endIndex1)
        let str2 = userdate.dropFirst(6)
        let serverdate = "\(str1).\(str2)"
        
        print(serverdate)  // 12:AM
        
        let timearr = userdate.components(separatedBy: ":")
        let hour = Int(timearr[0])
        let minutestring =  (timearr[1])
        let arrminute = minutestring.components(separatedBy: " ")
        let minute =  Int(arrminute[0])
        
        if serverdate.contains("12.AM"){ // 00:00
        today = Calendar.current.date(bySettingHour: 00, minute: minute!, second: 0, of: Date())!
        }
        if serverdate.contains("01.AM"){  // 01:00
         today = Calendar.current.date(bySettingHour: 01, minute: minute!, second: 0, of: Date())!
        }
        if serverdate.contains("02.AM"){ // 02:00
         today = Calendar.current.date(bySettingHour: 02, minute: minute!, second: 0, of: Date())!
        }
        if serverdate.contains("03.AM"){ // 03:00
        today = Calendar.current.date(bySettingHour: 03, minute: minute!, second: 0, of: Date())!
        }
        if serverdate.contains("04.AM"){ // 04:00
        today = Calendar.current.date(bySettingHour: 04, minute: minute!, second: 0, of: Date())!
        }
        if serverdate.contains("05.AM"){ // 05:00
         today = Calendar.current.date(bySettingHour: 05, minute: minute!, second: 0, of: Date())!
        }
        if serverdate.contains("06.AM"){  // 06:00
         today = Calendar.current.date(bySettingHour: 06, minute: minute!, second: 0, of: Date())!
        }
        if serverdate.contains("07.AM"){  // 07:00
         today = Calendar.current.date(bySettingHour: 07, minute: minute!, second: 0, of: Date())!
        }
        if serverdate.contains("08.AM"){  // 08:00
         today = Calendar.current.date(bySettingHour: 08, minute: minute!, second: 0, of: Date())!
        }
        if serverdate.contains("09.AM"){  // 09:00
        today = Calendar.current.date(bySettingHour: 09, minute: minute!, second: 0, of: Date())!
        }
        if serverdate.contains("10.AM"){  // 10:00
         today = Calendar.current.date(bySettingHour: 10, minute: minute!, second: 0, of: Date())!
        }
        if serverdate.contains("11.AM"){  // 11:00
        today = Calendar.current.date(bySettingHour: 11, minute: minute!, second: 0, of: Date())!
        }
        if serverdate.contains("12.PM"){  // 12:00
            today = Calendar.current.date(bySettingHour: 12, minute: minute!, second: 0, of: Date())!
        }
        if serverdate.contains("01.PM"){  // 13:00
           today = Calendar.current.date(bySettingHour: 13, minute: minute!, second: 0, of: Date())!
        }
        if serverdate.contains("02.PM"){   // 14:00
            today = Calendar.current.date(bySettingHour: 14, minute: minute!, second: 0, of: Date())!
        }
        if serverdate.contains("03.PM"){   // 15:00
        today = Calendar.current.date(bySettingHour: 15, minute: minute!, second: 0, of: Date())!
        }
        if serverdate.contains("04.PM"){   // 16:00
        today = Calendar.current.date(bySettingHour: 16, minute: minute!, second: 0, of: Date())!
        }
        if serverdate.contains("05.PM"){   // 17:00
        today = Calendar.current.date(bySettingHour: 17, minute: minute!, second: 0, of: Date())!
        }
        if serverdate.contains("06.PM"){   // 18:00
        today = Calendar.current.date(bySettingHour: 18, minute: minute!, second: 0, of: Date())!
        }
        if serverdate.contains("07.PM"){   // 19:00
        today = Calendar.current.date(bySettingHour: 19, minute: minute!, second: 0, of: Date())!
        }
        if serverdate.contains("08.PM"){   // 20:00
        today = Calendar.current.date(bySettingHour: 20, minute: minute!, second: 0, of: Date())!
        }
        if serverdate.contains("09.PM"){  // 21:00
        today = Calendar.current.date(bySettingHour: 21, minute: minute!, second: 0, of: Date())!
        }
        if serverdate.contains("10.PM"){  // 22:00
        today = Calendar.current.date(bySettingHour: 22, minute: minute!, second: 0, of: Date())!
        }
        if serverdate.contains("11.PM"){  // 23:00
        today = Calendar.current.date(bySettingHour: 23, minute: minute!, second: 0, of: Date())!
        }
        
        print(today)
        
        let CurrentTimeZone = NSTimeZone(abbreviation: "UTC")
        let SystemTimeZone = NSTimeZone.system as NSTimeZone
        let currentGMTOffset: Int? = CurrentTimeZone?.secondsFromGMT(for: today!)
        let SystemGMTOffset: Int = SystemTimeZone.secondsFromGMT(for: today!)
        let interval = TimeInterval((SystemGMTOffset - currentGMTOffset!))
        let userdata = Date(timeInterval: interval, since: today!)
        
       return userdata
        
    }
    
    func dateconvert(userdate:Date) -> Date{
        let CurrentTimeZone = NSTimeZone(abbreviation: "UTC")
        let SystemTimeZone = NSTimeZone.system as NSTimeZone
        let currentGMTOffset: Int? = CurrentTimeZone?.secondsFromGMT(for: userdate)
        let SystemGMTOffset: Int = SystemTimeZone.secondsFromGMT(for: userdate)
        let interval = TimeInterval((SystemGMTOffset - currentGMTOffset!))
        let userdata = Date(timeInterval: interval, since: userdate)
        return userdata
    }
    
    func datetotime(userdate:Date) -> String{
    
    print(userdate)
        
    dateFormatter.timeZone = NSTimeZone(abbreviation: "UTC") as! TimeZone
    dateFormatter.amSymbol = "AM"
    dateFormatter.pmSymbol = "PM"
    dateFormatter.dateFormat = "HH"
    let time = dateFormatter.string(from: userdate) //pass Date here
    print(time)
    return time
    }
    
    
    func datetostring(dates:Date) -> Date{
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let myString = formatter.string(from: dates)
        let yourDate = formatter.date(from: myString)
        return yourDate!
    }
    
    
    // MARK: STPPaymentContextDelegate
    
    func paymentContext(_ paymentContext: STPPaymentContext, didCreatePaymentResult paymentResult: STPPaymentResult, completion: @escaping STPErrorBlock) {
        print("run didCreatePaymentResult paymentContext()")
        MyAPIClient.sharedClient.completeCharge(paymentResult,
                                                amount: self.paymentContext.paymentAmount,
                                                shippingAddress: self.paymentContext.shippingAddress,
                                                shippingMethod: self.paymentContext.selectedShippingMethod,
                                                completion: completion)
    }
    
    func paymentContext(_ paymentContext: STPPaymentContext, didFinishWith status: STPPaymentStatus, error: Error?) {
        print("run didFinishWith paymentContext()")
        let title: String
        let message: String
        switch status {
        case .error:
            title = "Error"
            message = error?.localizedDescription ?? ""
        case .success:
            title = "Success"
            message = "You bought a SPOT!"
        case .userCancellation:
            return
        }
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(action)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func paymentContextDidChange(_ paymentContext: STPPaymentContext) {
        print("run paymentContextDidChange()")
        
    }
    
    func paymentContext(_ paymentContext: STPPaymentContext, didFailToLoadWithError error: Error) {
        print("run didFailToLoadWithError paymentContext()")
        print("Error: \(error)")
        let alertController = UIAlertController(
            title: "Error",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
            // Need to assign to _ because optional binding loses @discardableResult value
            // https://bugs.swift.org/browse/SR-1681
            _ = self.navigationController?.popViewController(animated: true)
        })
        let retry = UIAlertAction(title: "Retry", style: .default, handler: { action in
            self.paymentContext.retryLoading()
        })
        alertController.addAction(cancel)
        alertController.addAction(retry)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func setPaymentContext(price: Int) {
        self.paymentContext.delegate = self
        self.paymentContext.hostViewController = self
        self.paymentContext.paymentAmount = price
        print(self.paymentContext.paymentAmount)
        print(self.paymentContext.hostViewController)
    }
    
    
}

extension Date {
    var time: Time {
        return Time(self)
    }
    
    enum NSComparisonResult : Int {
        case OrderedAscending
        case OrderedSame
        case OrderedDescending
    }
}

