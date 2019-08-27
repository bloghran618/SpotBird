//
//  FirstViewController.swift
//  Spotbirdparking
//
//  Created by mac on 13/04/19.
//  Copyright © 2019 Spotbird. All rights reserved.
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

class FirstViewController: UIViewController,CLLocationManagerDelegate,GMSMapViewDelegate,GMSAutocompleteViewControllerDelegate,UIPickerViewDataSource,UIPickerViewDelegate, STPPaymentContextDelegate {
    
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
    
    @IBOutlet weak var lblDistance: UILabel!
    
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
    
    
    @IBOutlet weak var img_spot_type: UIImageView!
    @IBOutlet weak var lbl_spot_type: UILabel!
    @IBOutlet weak var lbl_spot_time: UILabel!
    
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
    var arrAllspot:NSMutableArray = NSMutableArray()
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
    
    var Time_price = false
    
    var Search_start_date:Date?
    var Search_end_date:Date?
    var strPickerStart = ""
    var strPickerEnd = ""
    
    // initialize highlighted spot to null
    var highlightedSpot: Spot!
    
    var profileOptions: [ProfileTableOption]?
    //    let cellIdentifier = "profileTableCell"
    
    // Stripe setup
    let config = STPPaymentConfiguration.shared()
    let customerContext = STPCustomerContext(keyProvider: MyAPIClient.sharedClient)
    var paymentContext = STPPaymentContext(customerContext: STPCustomerContext(keyProvider: MyAPIClient.sharedClient))
    
    var allMarkers = [GMSMarker]()
    
    var chargeInfoReservation: Reservation!
    var paymentIntent_ID: String!
    
    //MARK:- View Did Load
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        start_scheduler()
        
        
        // load aspects of User() object from the database
        AppState.sharedInstance.activeSpot.getSpots()
        AppState.sharedInstance.user.GetCar()
        
        let queue = DispatchQueue(label: "Getting Reservations", qos: .utility)
        queue.async {
            AppState.sharedInstance.user.getReservations() { message in
                print(message)
                AppState.sharedInstance.user.reservationsDownloaded = true
            }
        }
        AppState.sharedInstance.user.fetch_Balance()
        AppState.sharedInstance.user.fetch_LifeTimeBalance()
        
        
        AppState.sharedInstance.user.getReservationsOfCurrentUser(){ message in

            print(message)
        }

        
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
        end_datepic.minimumDate = calendar.date(byAdding: .hour, value: 1, to:  Date())
        end_datepic.date = calendar.date(byAdding: .hour, value: 3, to:  Date())!
        
        // list load
        setStartEndDate()
        
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
    
    //    func getReservationsOnDay(date: Date) -> Bool {
    //
    //        for res in AppState.sharedInstance.user.reservations {
    //            if(checkReservationDateMatchesCell(reservationDate: res.startDateTime, cellDate: date)) {
    //                 return true
    //            }
    //        }
    //        return false
    //    }
    
    func checkReservationDateMatchesCell(reservationDate: String, cellDate: Date) -> Bool
    {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        let resDate = formatter.date(from: reservationDate)
        
        return Calendar.current.isDate(resDate!, inSameDayAs: cellDate)
    }
    
    func start_scheduler() {
        
        let url = "https://spotbird-backend-bloughran618.herokuapp.com/start_scheduler"
        print("before starting scheduler")
        
        Alamofire.request(url, method: .post)
            .validate(statusCode: 200..<300)
            .responseJSON { response in
                switch response.result {
                case .success:
                    print("Returned with success")
                case .failure(let error):
                    print("Failure")
                }
                
        }
        print("after starting scheduler")
    }
    
    //MARK:- View will Appears
    
    func viewWillAppear(animated: Bool) {
        //debug:
//        MyAPIClient.sharedClient.createCustomerID()
//        MyAPIClient.sharedClient.createAccountID()
        super.viewWillAppear(animated)
    }
    
    
    func viewWillDisappear(animated: Bool)
    {
        // self.timerAnimation.invalidate()
    }
    //MARK:- Methords
    
    func timearrayset()  {
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:a"
        let stringdate = dateFormatter.string(from: Date())
        
        if stringdate.contains("PM")
        {
            timearray.append("PM")
            timearray.append("AM")
            format1 = "PM"
            format2 = "PM"
        }
        else
        {
            timearray.append("AM")
            timearray.append("PM")
            format1 = "AM"
            format2 = "AM"
        }
    }
    // start date-
    @objc func startdatePickerChanged(picker: UIDatePicker)
    {
        print(picker.date)
        let formatter = DateFormatter()
        formatter.dateFormat = "EE MMM dd"
        let date = formatter.string(from: picker.date)
        print(date)
        print(date)
        strPickerStart = date
    }
    
    // end date-
    @objc func EnddatePickerChanged(picker: UIDatePicker) {
        
        endChange = true
        print(picker.date)
        let formatter = DateFormatter()
        formatter.dateFormat = "EE MMM dd"
        let date = formatter.string(from: picker.date)
        print(date)
        strPickerEnd = date
        
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:a"
        let formatter12 = DateFormatter()
        formatter12.dateFormat = "yyyy-MM-dd hh:mm:a"
        
        var str = formatter12.string(from: picker.date)
        if str.contains("AM")
        {
            if format2 == "AM"
            {
                end_date = formatter12.date(from: str)!
            }else
            {
                let replaced = str.replacingOccurrences(of: "AM", with: "PM")
                end_date = formatter12.date(from: replaced)!
            }
            print(end_date!)
        }else
        {
            if format2 == "PM"
            {
                end_date = formatter12.date(from: str)!
                
            }else
            {
                let replaced = str.replacingOccurrences(of: "PM", with: "AM")
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:a" //Your date format
                dateFormatter.timeZone = TimeZone(abbreviation: "GMT+0:00")
                guard let date = dateFormatter.date(from: replaced) else
                {
                    fatalError()
                }
                end_date =  date
            }
            print(end_date!)
        }
    }
    //MARK:- Button Click Event
    // MARK: _ BTn Date searching(Calender Click Event)
    @IBAction func btn_Date_search(_ sender: UIButton) {
        view_info.isHidden = true
        btn_close.isHidden = true
        start_datepic.date = NSDate() as Date
        end_datepic.date = NSDate() as Date
        if Date_VIew.isHidden == true{
            // Date_VIew.isHidden = false
            
            UIView.transition(with: Date_VIew, duration: 0.3, options: .transitionCurlDown, animations: {
                self.Date_VIew.isHidden = false
            })
            
        }
        else{
            Date_VIew.isHidden = true
        }
        //start_datepic.date = Date()
        //end_datepic.date = Date()
    }
    
    // MARK:_ BTn Date searching close ()
    @IBAction func btn_Date_search_close(_ sender: UIButton) {
        Date_VIew.isHidden = true
        start_datepic.date = Date()
        //end_datepic.date = Date()
        end_datepic.minimumDate = calendar.date(byAdding: .hour, value: 1, to:  Date())
        end_datepic.date = calendar.date(byAdding: .hour, value: 3, to:  Date())!
    }
    
    @IBAction func btn_Date_search_done(_ sender: UIButton) {
        Time_price = true
        let d1 = start_datepic.date
        let d2 = end_datepic.date
        
        let formatter = DateFormatter()
        // formatter.dateFormat = "EE MMM dd h a"
        formatter.dateFormat = "MMM dd, h a"
        
        //        strPickerStart = formatter.string(from:  d1)
        //        strPickerEnd = formatter.string(from: d2)
        
        //        print(datestart)
        //        print(dateend)
        
        // lbl_spot_time.text = "Spot Time - \(datestart) to \(dateend)"
        var time1 = Bool()
        
        // start date time check today
        let myStringafd = dateFormatter2.string(from: start_datepic.date)
        print(myStringafd)
        if myStringafd.contains("AM")
        {
            if format1 == "AM"
            {
                start_date = dateFormatter2.date(from: myStringafd)!
                strPickerStart = formatter.string(from:  start_date!)
                
            }else
            {
                let replaced = myStringafd.replacingOccurrences(of: "AM", with: "PM")
                start_date = dateFormatter2.date(from: replaced)!
                strPickerStart = formatter.string(from:  start_date!)
                
            }
            print(start_date!)
        }else
        {
            if format1 == "PM"
            {
                start_date = dateFormatter2.date(from: myStringafd)!
                strPickerStart = formatter.string(from:  start_date!)
                
            }else
            {
                let replaced = myStringafd.replacingOccurrences(of: "PM", with: "AM")
                start_date = dateFormatter2.date(from: replaced)!
                strPickerStart = formatter.string(from:  start_date!)
                
            }
            print(start_date!)
        }
        
        
        let myStringEndDate = dateFormatter2.string(from: end_datepic.date)
        print(myStringEndDate)
        if myStringEndDate.contains("AM")
        {
            if format1 == "AM"
            {
                end_date = dateFormatter2.date(from: myStringEndDate)!
                strPickerEnd = formatter.string(from:  end_date!)
                
            }else
            {
                let replaced1 = myStringEndDate.replacingOccurrences(of: "AM", with: "PM")
                end_date = dateFormatter2.date(from: replaced1)!
                strPickerEnd = formatter.string(from:  start_date!)
                
            }
            print(end_date!)
        }else
        {
            if format1 == "PM"
            {
                end_date = dateFormatter2.date(from: myStringEndDate)!
                strPickerEnd = formatter.string(from:  end_date!)
                
            }else
            {
                let replaced1 = myStringEndDate.replacingOccurrences(of: "PM", with: "AM")
                end_date = dateFormatter2.date(from: replaced1)!
                strPickerEnd = formatter.string(from:  end_date!)
                
            }
            print(end_date!)
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
            
            //            let addhour = calendar.date(byAdding: .hour, value: 3, to: start_date!)
            //            end_date = addhour!
            //            strPickerEnd = formatter.string(from:  end_date!)
            //
            //            print(addhour)
            end_date = end_datepic.date
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
                    strPickerEnd = formatter.string(from:  end_date!)
                    
                }else
                {
                    let replaced = str.replacingOccurrences(of: "AM", with: "PM")
                    end_date = dateFormatter2.date(from: replaced)!
                    strPickerEnd = formatter.string(from:  end_date!)
                    
                }
                print(end_date!)
            }
                
            else
            {
                if format2 == "PM"
                {
                    end_date = dateFormatter2.date(from: str)!
                    strPickerEnd = formatter.string(from:  end_date!)
                    
                }else
                {
                    let replaced = str.replacingOccurrences(of: "PM", with: "AM")
                    end_date = dateFormatter2.date(from: replaced)!
                    strPickerEnd = formatter.string(from:  end_date!)
                }
                print(end_date!)
            }
            
        }
        
        start_date = dateconvert(userdate: start_date!)
        end_date = dateconvert(userdate: end_date!)
        print(strPickerStart)
        print(strPickerEnd)
        
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
        }else if start_date! == end_date!  {
            let alert = UIAlertController(title: "Spotbirdparking", message: " Start date and end date is equal.", preferredStyle: .alert)
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
            let dateformats = DateFormatter()
            dateformats.timeZone = TimeZone.current
            dateformats.dateFormat  = "EEEE"
            let dayInWeek = dateformats.string(from: Date())
            
            let formatter = DateFormatter()
            // initially set the format based on your datepicker date / server String
            formatter.dateFormat = "yyyy-MM-dd"
            formatter.timeZone = TimeZone(abbreviation: "GMT+0:00")
            var str = formatter.string(from: Date())
            
            let arrCurrentRes = AppState.sharedInstance.user.myReservations
            var calcheck = Calendar.current
            calcheck.timeZone =  TimeZone(abbreviation: "GMT+0:00")!
            for i in 0..<self.arrAllspot.count{
                for j in 0..<arr_day.count{
                    
                    if i == 3 || i == 9 || i == 11 || i == 12{
                        
                        print("i Cheack ")
                        
                    }
                    
                    let dict_spot = self.arrAllspot.object(at: i) as! NSDictionary
                    var localTimeZoneName: String { return TimeZone.current.identifier }
                    print(localTimeZoneName)
                    
                    //MARK:- Sunday Loop
                    
                    if arr_day[j] == "Sunday" {
                        if (self.arrAllspot.object(at: i) as! NSDictionary).value(forKey: "sunswitch") as! Bool == true{
                            
                            let arrsun = datedaydict.value(forKey: "Sunday") as! NSArray
                            for m in 0..<arrsun.count{
                                
                                let spotStart_times = "\(str) \(dict_spot.value(forKey: "sunStartTime") as! String)"
                                let spotEnd_times = "\(str) \(dict_spot.value(forKey: "sunEndTime") as! String)"
                                formatter.dateFormat = "yyyy-MM-dd h:mm a"
                                let dateDay1 = formatter.date(from: spotStart_times)
                                let dateDay2 = formatter.date(from: spotEnd_times)
                                formatter.dateFormat = "MMM dd h a"
                                
                                let statCur = self.dateWithHour(hour:calcheck.component(.hour, from: self.start_date!), minute: 00, second: 00, date: self.start_date!)!
                                let endCur = self.dateWithHour(hour:calcheck.component(.hour, from:self.end_date!), minute: 00, second: 00, date: self.end_date!)!
                                let statCheck = self.dateWithHour(hour:22, minute: 00, second: 00, date: self.start_date!)!
                                if statCheck.isSmallerThan(statCur) || statCheck == statCur
                                {
                                    print("true")
                                    let spotStart_times = "\(str) \(dict_spot.value(forKey: "monStartTime") as! String)"
                                    let spotEnd_times = "\(str) \(dict_spot.value(forKey: "monEndTime") as! String)"
                                    formatter.dateFormat = "yyyy-MM-dd h:mm a"
                                    let dateeDay1 = formatter.date(from: spotStart_times)
                                    let dateeDay2 = formatter.date(from: spotEnd_times)
                                    formatter.dateFormat = "MMM dd h a"
                                    
                                    if dateeDay1 != nil || dateeDay2 != nil
                                    {
                                        if dateeDay1!.isSmallerThan(endCur) && dateeDay2!.isSmallerThan(endCur)
                                        {
                                            var isReservarion = false
                                            for dict in arrCurrentRes
                                            {
                                                if (dict as! NSDictionary).value(forKey: "spotID") as! String == dict_spot.value(forKey: "id") as! String
                                                {
                                                    let date1 = (dict as! NSDictionary).value(forKey: "startDateTime") as! String
                                                    let date2 = (dict as! NSDictionary).value(forKey: "endDateTime") as! String
                                                    formatter.dateFormat = "yyyy-MM-dd HH:mm"
                                                    let date11 = formatter.date(from: date1)
                                                    let date22 = formatter.date(from: date2)
                                                    print(date1)
                                                    if date11!.isSmallerThan(statCur) && date22!.isGreaterThan(endCur)
                                                    {
                                                        isReservarion = true
                                                        break
                                                    }
                                                }
                                            }
                                            if isReservarion == false{
                                                self.arr_search_spot.add(self.arrAllspot.object(at: i))
                                            }
                                        }
                                    }
                                }else
                                {
                                    if dateDay1!.isSmallerThan(statCur) && dateDay2!.isGreaterThan(endCur){
                                        var isReservarion = false
                                        for dict in arrCurrentRes
                                        {
                                            if (dict as! NSDictionary).value(forKey: "spotID") as! String == dict_spot.value(forKey: "id") as! String
                                            {
                                                let date1 = (dict as! NSDictionary).value(forKey: "startDateTime") as! String
                                                let date2 = (dict as! NSDictionary).value(forKey: "endDateTime") as! String
                                                formatter.dateFormat = "yyyy-MM-dd HH:mm"
                                                let date11 = formatter.date(from: date1)
                                                let date22 = formatter.date(from: date2)
                                                print(date1)
                                                if date11!.isSmallerThan(statCur) && date22!.isGreaterThan(endCur)
                                                {
                                                    isReservarion = true
                                                    break
                                                }
                                            }
                                        }
                                        if isReservarion == false{
                                            self.arr_search_spot.add(self.arrAllspot.object(at: i))
                                        }
                                    }
                                }
                                
                                //                                if dateDay1!.isSmallerThan(statCur) && dateDay2!.isGreaterThan(endCur){
                                //                                    var isReservarion = false
                                //                                    for dict in arrCurrentRes
                                //                                    {
                                //                                        if (dict as! NSDictionary).value(forKey: "spotID") as! String == dict_spot.value(forKey: "id") as! String
                                //                                        {
                                //                                            let date1 = (dict as! NSDictionary).value(forKey: "startDateTime") as! String
                                //                                            let date2 = (dict as! NSDictionary).value(forKey: "endDateTime") as! String
                                //                                            formatter.dateFormat = "yyyy-MM-dd HH:mm"
                                //                                            let date11 = formatter.date(from: date1)
                                //                                            let date22 = formatter.date(from: date2)
                                //                                            print(date1)
                                //                                            if date11!.isSmallerThan(statCur) && date22!.isGreaterThan(endCur)
                                //                                            {
                                //                                                isReservarion = true
                                //                                                break
                                //                                            }
                                //                                        }
                                //                                    }
                                //                                    if isReservarion == false{
                                //                                        self.arr_search_spot.add(self.arrAllspot.object(at: i))
                                //                                    }
                                //                                }
                            }
                        }
                        
                        
                        // Comment Part Which is cutted from line number 1153
                        //                                        let sunStartTime = self.dateconvertServer(userdate: dict_spot.value(forKey: "sunStartTime") as! String)
                        //                                        let sunEndTime = self.dateconvertServer(userdate: dict_spot.value(forKey: "sunEndTime")  as! String)
                        //
                        //                                        let server_start1 = self.datetotime(userdate: sunStartTime)
                        //                                        let server_end1 = self.datetotime(userdate: sunEndTime)
                        //                                        print("server   - \(server_start1)")     // server
                        //                                        print("server     - \(server_end1)")     // server
                        //
                        //                                        let user_start = self.datetotime(userdate: self.start_date!)
                        //                                        let user_end = self.datetotime(userdate: self.end_date!)
                        //
                        //                                        print("user_start   - \(user_start)")     // user
                        //                                        print("user_end     - \(user_end)")     // user
                        //
                        //                                        // if user_start >= server_start1 && user_end <= server_end1{
                        //                                        self.arr_search_spot.add(self.arrAllspot.object(at: i))
                        
                        
                        
                        
                        
                        
                    }
                    
                    //MARK:- Monday Loop
                    if arr_day[j] == "Monday" {
                        if (self.arrAllspot.object(at: i) as! NSDictionary).value(forKey: "monswitch") as! Bool == true{
                            
                            let arrmun = datedaydict.value(forKey: "Monday") as! NSArray
                            for m in 0..<arrmun.count{
                                
                                let spotStart_times = "\(str) \(dict_spot.value(forKey: "monStartTime") as! String)"
                                let spotEnd_times = "\(str) \(dict_spot.value(forKey: "monEndTime") as! String)"
                                formatter.dateFormat = "yyyy-MM-dd h:mm a"
                                let dateDay1 = formatter.date(from: spotStart_times)
                                let dateDay2 = formatter.date(from: spotEnd_times)
                                formatter.dateFormat = "MMM dd h a"
                                
                                let statCur = self.dateWithHour(hour:calcheck.component(.hour, from: self.start_date!), minute: 00, second: 00, date: self.start_date!)!
                                let endCur = self.dateWithHour(hour:calcheck.component(.hour, from:self.end_date!), minute: 00, second: 00, date: self.end_date!)!
                                let statCheck = self.dateWithHour(hour:22, minute: 00, second: 00, date: self.start_date!)!
                                if statCheck.isSmallerThan(statCur) || statCheck == statCur
                                {
                                    print("true")
                                    let spotStart_times = "\(str) \(dict_spot.value(forKey: "tueStartTime") as! String)"
                                    let spotEnd_times = "\(str) \(dict_spot.value(forKey: "tueEndTime") as! String)"
                                    formatter.dateFormat = "yyyy-MM-dd h:mm a"
                                    let dateeDay1 = formatter.date(from: spotStart_times)
                                    let dateeDay2 = formatter.date(from: spotEnd_times)
                                    formatter.dateFormat = "MMM dd h a"
                                    if dateeDay1 != nil || dateeDay2 != nil
                                    {
                                        
                                        if dateeDay1!.isSmallerThan(endCur) && dateeDay2!.isSmallerThan(endCur)
                                        {
                                            var isReservarion = false
                                            for dict in arrCurrentRes
                                            {
                                                if (dict as! NSDictionary).value(forKey: "spotID") as! String == dict_spot.value(forKey: "id") as! String
                                                {
                                                    let date1 = (dict as! NSDictionary).value(forKey: "startDateTime") as! String
                                                    let date2 = (dict as! NSDictionary).value(forKey: "endDateTime") as! String
                                                    formatter.dateFormat = "yyyy-MM-dd HH:mm"
                                                    let date11 = formatter.date(from: date1)
                                                    let date22 = formatter.date(from: date2)
                                                    print(date1)
                                                    if date11!.isSmallerThan(statCur) && date22!.isGreaterThan(endCur)
                                                    {
                                                        isReservarion = true
                                                        break
                                                    }
                                                }
                                            }
                                            if isReservarion == false{
                                                self.arr_search_spot.add(self.arrAllspot.object(at: i))
                                            }
                                        }
                                    }
                                }else
                                {
                                    if dateDay1!.isSmallerThan(statCur) && dateDay2!.isGreaterThan(endCur){
                                        var isReservarion = false
                                        for dict in arrCurrentRes
                                        {
                                            if (dict as! NSDictionary).value(forKey: "spotID") as! String == dict_spot.value(forKey: "id") as! String
                                            {
                                                let date1 = (dict as! NSDictionary).value(forKey: "startDateTime") as! String
                                                let date2 = (dict as! NSDictionary).value(forKey: "endDateTime") as! String
                                                formatter.dateFormat = "yyyy-MM-dd HH:mm"
                                                let date11 = formatter.date(from: date1)
                                                let date22 = formatter.date(from: date2)
                                                print(date1)
                                                if date11!.isSmallerThan(statCur) && date22!.isGreaterThan(endCur)
                                                {
                                                    isReservarion = true
                                                    break
                                                }
                                            }
                                        }
                                        if isReservarion == false{
                                            self.arr_search_spot.add(self.arrAllspot.object(at: i))
                                        }
                                    }
                                }
                                
                                //                                if dateDay1!.isSmallerThan(statCur) && dateDay2!.isGreaterThan(endCur){
                                //                                    var isReservarion = false
                                //                                    for dict in arrCurrentRes
                                //                                    {
                                //                                        if (dict as! NSDictionary).value(forKey: "spotID") as! String == dict_spot.value(forKey: "id") as! String
                                //                                        {
                                //                                            let date1 = (dict as! NSDictionary).value(forKey: "startDateTime") as! String
                                //                                            let date2 = (dict as! NSDictionary).value(forKey: "endDateTime") as! String
                                //                                            formatter.dateFormat = "yyyy-MM-dd HH:mm"
                                //                                            let date11 = formatter.date(from: date1)
                                //                                            let date22 = formatter.date(from: date2)
                                //                                            print(date1)
                                //                                            if date11!.isSmallerThan(statCur) && date22!.isGreaterThan(endCur)
                                //                                            {
                                //                                                isReservarion = true
                                //                                                break
                                //                                            }
                                //                                        }
                                //                                    }
                                //                                    if isReservarion == false{
                                //                                        self.arr_search_spot.add(self.arrAllspot.object(at: i))
                                //                                    }
                                //                                }
                            }
                        }
                    }
                    //MARK:- Tuesday Loop
                    if arr_day[j] == "Tuesday" {
                        if (self.arrAllspot.object(at: i) as! NSDictionary).value(forKey: "tueswitch") as! Bool == true{
                            
                            let arrthue = datedaydict.value(forKey: "Tuesday") as! NSArray
                            for m in 0..<arrthue.count{
                                
                                let spotStart_times = "\(str) \(dict_spot.value(forKey: "tueStartTime") as! String)"
                                let spotEnd_times = "\(str) \(dict_spot.value(forKey: "tueEndTime") as! String)"
                                formatter.dateFormat = "yyyy-MM-dd h:mm a"
                                let dateDay1 = formatter.date(from: spotStart_times)
                                let dateDay2 = formatter.date(from: spotEnd_times)
                                formatter.dateFormat = "MMM dd h a"
                                
                                let statCur = self.dateWithHour(hour:calcheck.component(.hour, from: self.start_date!), minute: 00, second: 00, date: self.start_date!)!
                                let endCur = self.dateWithHour(hour:calcheck.component(.hour, from:self.end_date!), minute: 00, second: 00, date: self.end_date!)!
                                let statCheck = self.dateWithHour(hour:22, minute: 00, second: 00, date: self.start_date!)!
                                if statCheck.isSmallerThan(statCur) || statCheck == statCur
                                {
                                    print("true")
                                    let spotStart_times = "\(str) \(dict_spot.value(forKey: "wedStartTime") as! String)"
                                    let spotEnd_times = "\(str) \(dict_spot.value(forKey: "wedEndTime") as! String)"
                                    formatter.dateFormat = "yyyy-MM-dd h:mm a"
                                    let dateeDay1 = formatter.date(from: spotStart_times)
                                    let dateeDay2 = formatter.date(from: spotEnd_times)
                                    formatter.dateFormat = "MMM dd h a"
                                    if dateeDay1 != nil || dateeDay2 != nil
                                    {
                                        
                                        if dateeDay1!.isSmallerThan(endCur) && dateeDay2!.isSmallerThan(endCur)
                                        {
                                            var isReservarion = false
                                            for dict in arrCurrentRes
                                            {
                                                if (dict as! NSDictionary).value(forKey: "spotID") as! String == dict_spot.value(forKey: "id") as! String
                                                {
                                                    let date1 = (dict as! NSDictionary).value(forKey: "startDateTime") as! String
                                                    let date2 = (dict as! NSDictionary).value(forKey: "endDateTime") as! String
                                                    formatter.dateFormat = "yyyy-MM-dd HH:mm"
                                                    let date11 = formatter.date(from: date1)
                                                    let date22 = formatter.date(from: date2)
                                                    print(date1)
                                                    if date11!.isSmallerThan(statCur) && date22!.isGreaterThan(endCur)
                                                    {
                                                        isReservarion = true
                                                        break
                                                    }
                                                }
                                            }
                                            if isReservarion == false{
                                                self.arr_search_spot.add(self.arrAllspot.object(at: i))
                                            }
                                        }
                                    }
                                }else
                                {
                                    if dateDay1!.isSmallerThan(statCur) && dateDay2!.isGreaterThan(endCur){
                                        var isReservarion = false
                                        for dict in arrCurrentRes
                                        {
                                            if (dict as! NSDictionary).value(forKey: "spotID") as! String == dict_spot.value(forKey: "id") as! String
                                            {
                                                let date1 = (dict as! NSDictionary).value(forKey: "startDateTime") as! String
                                                let date2 = (dict as! NSDictionary).value(forKey: "endDateTime") as! String
                                                formatter.dateFormat = "yyyy-MM-dd HH:mm"
                                                let date11 = formatter.date(from: date1)
                                                let date22 = formatter.date(from: date2)
                                                print(date1)
                                                if date11!.isSmallerThan(statCur) && date22!.isGreaterThan(endCur)
                                                {
                                                    isReservarion = true
                                                    break
                                                }
                                            }
                                        }
                                        if isReservarion == false{
                                            self.arr_search_spot.add(self.arrAllspot.object(at: i))
                                        }
                                    }
                                }
                                
                                //                                if dateDay1!.isSmallerThan(statCur) && dateDay2!.isGreaterThan(endCur){
                                //                                    var isReservarion = false
                                //                                    for dict in arrCurrentRes
                                //                                    {
                                //                                        if (dict as! NSDictionary).value(forKey: "spotID") as! String == dict_spot.value(forKey: "id") as! String
                                //                                        {
                                //                                            let date1 = (dict as! NSDictionary).value(forKey: "startDateTime") as! String
                                //                                            let date2 = (dict as! NSDictionary).value(forKey: "endDateTime") as! String
                                //                                            formatter.dateFormat = "yyyy-MM-dd HH:mm"
                                //                                            let date11 = formatter.date(from: date1)
                                //                                            let date22 = formatter.date(from: date2)
                                //                                            print(date1)
                                //                                            if date11!.isSmallerThan(statCur) && date22!.isGreaterThan(endCur)
                                //                                            {
                                //                                                isReservarion = true
                                //                                                break
                                //                                            }
                                //                                        }
                                //                                    }
                                //                                    if isReservarion == false{
                                //                                        self.arr_search_spot.add(self.arrAllspot.object(at: i))
                                //                                    }
                                //                                }
                            }
                        }
                    }
                    //MARK:- Wednesday Loop
                    if arr_day[j] == "Wednesday" {
                        if (self.arrAllspot.object(at: i) as! NSDictionary).value(forKey: "wedswitch") as! Bool == true{
                            
                            let arrwed = datedaydict.value(forKey: "Wednesday") as! NSArray
                            for m in 0..<arrwed.count{
                                
                                let spotStart_times = "\(str) \(dict_spot.value(forKey: "wedStartTime") as! String)"
                                let spotEnd_times = "\(str) \(dict_spot.value(forKey: "wedEndTime") as! String)"
                                formatter.dateFormat = "yyyy-MM-dd h:mm a"
                                let dateDay1 = formatter.date(from: spotStart_times)
                                let dateDay2 = formatter.date(from: spotEnd_times)
                                formatter.dateFormat = "MMM dd h a"
                                
                                let statCur = self.dateWithHour(hour:calcheck.component(.hour, from: self.start_date!), minute: 00, second: 00, date: self.start_date!)!
                                let endCur = self.dateWithHour(hour:calcheck.component(.hour, from:self.end_date!), minute: 00, second: 00, date: self.end_date!)!
                                let statCheck = self.dateWithHour(hour:22, minute: 00, second: 00, date: self.start_date!)!
                                if statCheck.isSmallerThan(statCur) || statCheck == statCur
                                {
                                    print("true")
                                    let spotStart_times = "\(str) \(dict_spot.value(forKey: "thuStartTime") as! String)"
                                    let spotEnd_times = "\(str) \(dict_spot.value(forKey: "thuEndTime") as! String)"
                                    formatter.dateFormat = "yyyy-MM-dd h:mm a"
                                    let dateeDay1 = formatter.date(from: spotStart_times)
                                    let dateeDay2 = formatter.date(from: spotEnd_times)
                                    formatter.dateFormat = "MMM dd h a"
                                    if dateeDay1 != nil || dateeDay2 != nil
                                    {
                                        
                                        if dateeDay1!.isSmallerThan(endCur) && dateeDay2!.isSmallerThan(endCur)
                                        {
                                            var isReservarion = false
                                            for dict in arrCurrentRes
                                            {
                                                if (dict as! NSDictionary).value(forKey: "spotID") as! String == dict_spot.value(forKey: "id") as! String
                                                {
                                                    let date1 = (dict as! NSDictionary).value(forKey: "startDateTime") as! String
                                                    let date2 = (dict as! NSDictionary).value(forKey: "endDateTime") as! String
                                                    formatter.dateFormat = "yyyy-MM-dd HH:mm"
                                                    let date11 = formatter.date(from: date1)
                                                    let date22 = formatter.date(from: date2)
                                                    print(date1)
                                                    if date11!.isSmallerThan(statCur) && date22!.isGreaterThan(endCur)
                                                    {
                                                        isReservarion = true
                                                        break
                                                    }
                                                }
                                            }
                                            if isReservarion == false{
                                                self.arr_search_spot.add(self.arrAllspot.object(at: i))
                                            }
                                        }
                                    }
                                }else
                                {
                                    if dateDay1!.isSmallerThan(statCur) && dateDay2!.isGreaterThan(endCur){
                                        var isReservarion = false
                                        for dict in arrCurrentRes
                                        {
                                            if (dict as! NSDictionary).value(forKey: "spotID") as! String == dict_spot.value(forKey: "id") as! String
                                            {
                                                let date1 = (dict as! NSDictionary).value(forKey: "startDateTime") as! String
                                                let date2 = (dict as! NSDictionary).value(forKey: "endDateTime") as! String
                                                formatter.dateFormat = "yyyy-MM-dd HH:mm"
                                                let date11 = formatter.date(from: date1)
                                                let date22 = formatter.date(from: date2)
                                                print(date1)
                                                if date11!.isSmallerThan(statCur) && date22!.isGreaterThan(endCur)
                                                {
                                                    isReservarion = true
                                                    break
                                                }
                                            }
                                        }
                                        if isReservarion == false{
                                            self.arr_search_spot.add(self.arrAllspot.object(at: i))
                                        }
                                    }
                                }
                                
                                //                                if dateDay1!.isSmallerThan(statCur) && dateDay2!.isGreaterThan(endCur){
                                //                                    var isReservarion = false
                                //                                    for dict in arrCurrentRes
                                //                                    {
                                //                                        if (dict as! NSDictionary).value(forKey: "spotID") as! String == dict_spot.value(forKey: "id") as! String
                                //                                        {
                                //                                            let date1 = (dict as! NSDictionary).value(forKey: "startDateTime") as! String
                                //                                            let date2 = (dict as! NSDictionary).value(forKey: "endDateTime") as! String
                                //                                            formatter.dateFormat = "yyyy-MM-dd HH:mm"
                                //                                            let date11 = formatter.date(from: date1)
                                //                                            let date22 = formatter.date(from: date2)
                                //                                            print(date1)
                                //                                            if date11!.isSmallerThan(statCur) && date22!.isGreaterThan(endCur)
                                //                                            {
                                //                                                isReservarion = true
                                //                                                break
                                //                                            }
                                //                                        }
                                //                                    }
                                //                                    if isReservarion == false{
                                //                                        self.arr_search_spot.add(self.arrAllspot.object(at: i))
                                //                                    }
                                //                                }
                                
                            }
                        }
                    }
                    //MARK:- Thusday Loop
                    if arr_day[j] == "Thursday" {
                        
                        if (self.arrAllspot.object(at: i) as! NSDictionary).value(forKey: "thuswitch") as! Bool == true{
                            
                            let arrThu = datedaydict.value(forKey: "Thursday") as! NSArray
                            for m in 0..<arrThu.count{
                                
                                let spotStart_times = "\(str) \(dict_spot.value(forKey: "thuStartTime") as! String)"
                                let spotEnd_times = "\(str) \(dict_spot.value(forKey: "thuEndTime") as! String)"
                                formatter.dateFormat = "yyyy-MM-dd h:mm a"
                                let dateDay1 = formatter.date(from: spotStart_times)
                                let dateDay2 = formatter.date(from: spotEnd_times)
                                formatter.dateFormat = "MMM dd h a"
                                
                                let statCur = self.dateWithHour(hour:calcheck.component(.hour, from: self.start_date!), minute: 00, second: 00, date: self.start_date!)!
                                let endCur = self.dateWithHour(hour:calcheck.component(.hour, from:self.end_date!), minute: 00, second: 00, date: self.end_date!)!
                                let statCheck = self.dateWithHour(hour:22, minute: 00, second: 00, date: self.start_date!)!
                                if statCheck.isSmallerThan(statCur) || statCheck == statCur
                                {
                                    print("true")
                                    let spotStart_times = "\(str) \(dict_spot.value(forKey: "friStartTime") as! String)"
                                    let spotEnd_times = "\(str) \(dict_spot.value(forKey: "friEndTime") as! String)"
                                    formatter.dateFormat = "yyyy-MM-dd h:mm a"
                                    let dateeDay1 = formatter.date(from: spotStart_times)
                                    let dateeDay2 = formatter.date(from: spotEnd_times)
                                    formatter.dateFormat = "MMM dd h a"
                                    if dateeDay1 != nil || dateeDay2 != nil
                                    {
                                        
                                        if dateeDay1!.isSmallerThan(endCur) && dateeDay2!.isSmallerThan(endCur)
                                        {
                                            var isReservarion = false
                                            for dict in arrCurrentRes
                                            {
                                                if (dict as! NSDictionary).value(forKey: "spotID") as! String == dict_spot.value(forKey: "id") as! String
                                                {
                                                    let date1 = (dict as! NSDictionary).value(forKey: "startDateTime") as! String
                                                    let date2 = (dict as! NSDictionary).value(forKey: "endDateTime") as! String
                                                    formatter.dateFormat = "yyyy-MM-dd HH:mm"
                                                    let date11 = formatter.date(from: date1)
                                                    let date22 = formatter.date(from: date2)
                                                    print(date1)
                                                    if date11!.isSmallerThan(statCur) && date22!.isGreaterThan(endCur)
                                                    {
                                                        isReservarion = true
                                                        break
                                                    }
                                                }
                                            }
                                            if isReservarion == false{
                                                self.arr_search_spot.add(self.arrAllspot.object(at: i))
                                            }
                                        }
                                    }
                                }else
                                {
                                    if dateDay1!.isSmallerThan(statCur) && dateDay2!.isGreaterThan(endCur){
                                        var isReservarion = false
                                        for dict in arrCurrentRes
                                        {
                                            if (dict as! NSDictionary).value(forKey: "spotID") as! String == dict_spot.value(forKey: "id") as! String
                                            {
                                                let date1 = (dict as! NSDictionary).value(forKey: "startDateTime") as! String
                                                let date2 = (dict as! NSDictionary).value(forKey: "endDateTime") as! String
                                                formatter.dateFormat = "yyyy-MM-dd HH:mm"
                                                let date11 = formatter.date(from: date1)
                                                let date22 = formatter.date(from: date2)
                                                print(date1)
                                                if date11!.isSmallerThan(statCur) && date22!.isGreaterThan(endCur)
                                                {
                                                    isReservarion = true
                                                    break
                                                }
                                            }
                                        }
                                        if isReservarion == false{
                                            self.arr_search_spot.add(self.arrAllspot.object(at: i))
                                        }
                                    }
                                }
                                
                                //                                if dateDay1!.isSmallerThan(statCur) && dateDay2!.isGreaterThan(endCur){
                                //                                    var isReservarion = false
                                //                                    for dict in arrCurrentRes
                                //                                    {
                                //                                        if (dict as! NSDictionary).value(forKey: "spotID") as! String == dict_spot.value(forKey: "id") as! String
                                //                                        {
                                //                                            let date1 = (dict as! NSDictionary).value(forKey: "startDateTime") as! String
                                //                                            let date2 = (dict as! NSDictionary).value(forKey: "endDateTime") as! String
                                //                                            formatter.dateFormat = "yyyy-MM-dd HH:mm"
                                //                                            let date11 = formatter.date(from: date1)
                                //                                            let date22 = formatter.date(from: date2)
                                //                                            print(date1)
                                //                                            if date11!.isSmallerThan(statCur) && date22!.isGreaterThan(endCur)
                                //                                            {
                                //                                                isReservarion = true
                                //                                                break
                                //                                            }
                                //                                        }
                                //                                    }
                                //                                    if isReservarion == false{
                                //                                        self.arr_search_spot.add(self.arrAllspot.object(at: i))
                                //                                    }
                                //                                }
                            }
                        }
                    }
                    //MARK:- Friday Loop
                    if arr_day[j] == "Friday" {
                        if (self.arrAllspot.object(at: i) as! NSDictionary).value(forKey: "friswitch") as! Bool == true{
                            
                            let arrFri = datedaydict.value(forKey: "Friday") as! NSArray
                            for m in 0..<arrFri.count{
                                
                                let spotStart_times = "\(str) \(dict_spot.value(forKey: "friStartTime") as! String)"
                                let spotEnd_times = "\(str) \(dict_spot.value(forKey: "friEndTime") as! String)"
                                formatter.dateFormat = "yyyy-MM-dd h:mm a"
                                let dateDay1 = formatter.date(from: spotStart_times)
                                let dateDay2 = formatter.date(from: spotEnd_times)
                                formatter.dateFormat = "MMM dd h a"
                                
                                let statCur = self.dateWithHour(hour:calcheck.component(.hour, from: self.start_date!), minute: 00, second: 00, date: self.start_date!)!
                                let endCur = self.dateWithHour(hour:calcheck.component(.hour, from:self.end_date!), minute: 00, second: 00, date: self.end_date!)!
                                let statCheck = self.dateWithHour(hour:22, minute: 00, second: 00, date: self.start_date!)!
                                if statCheck.isSmallerThan(statCur) || statCheck == statCur
                                {
                                    print("true")
                                    let spotStart_times = "\(str) \(dict_spot.value(forKey: "satStartTime") as! String)"
                                    let spotEnd_times = "\(str) \(dict_spot.value(forKey: "satEndTime") as! String)"
                                    formatter.dateFormat = "yyyy-MM-dd h:mm a"
                                    let dateeDay1 = formatter.date(from: spotStart_times)
                                    let dateeDay2 = formatter.date(from: spotEnd_times)
                                    formatter.dateFormat = "MMM dd h a"
                                    if dateeDay1 != nil || dateeDay2 != nil
                                    {
                                        
                                        if dateeDay1!.isSmallerThan(endCur) && dateeDay2!.isSmallerThan(endCur)
                                        {
                                            var isReservarion = false
                                            for dict in arrCurrentRes
                                            {
                                                if (dict as! NSDictionary).value(forKey: "spotID") as! String == dict_spot.value(forKey: "id") as! String
                                                {
                                                    let date1 = (dict as! NSDictionary).value(forKey: "startDateTime") as! String
                                                    let date2 = (dict as! NSDictionary).value(forKey: "endDateTime") as! String
                                                    formatter.dateFormat = "yyyy-MM-dd HH:mm"
                                                    let date11 = formatter.date(from: date1)
                                                    let date22 = formatter.date(from: date2)
                                                    print(date1)
                                                    if date11!.isSmallerThan(statCur) && date22!.isGreaterThan(endCur)
                                                    {
                                                        isReservarion = true
                                                        break
                                                    }
                                                }
                                            }
                                            if isReservarion == false{
                                                self.arr_search_spot.add(self.arrAllspot.object(at: i))
                                            }
                                        }
                                    }
                                }else
                                {
                                    if dateDay1!.isSmallerThan(statCur) && dateDay2!.isGreaterThan(endCur){
                                        var isReservarion = false
                                        for dict in arrCurrentRes
                                        {
                                            if (dict as! NSDictionary).value(forKey: "spotID") as! String == dict_spot.value(forKey: "id") as! String
                                            {
                                                let date1 = (dict as! NSDictionary).value(forKey: "startDateTime") as! String
                                                let date2 = (dict as! NSDictionary).value(forKey: "endDateTime") as! String
                                                formatter.dateFormat = "yyyy-MM-dd HH:mm"
                                                let date11 = formatter.date(from: date1)
                                                let date22 = formatter.date(from: date2)
                                                print(date1)
                                                if date11!.isSmallerThan(statCur) && date22!.isGreaterThan(endCur)
                                                {
                                                    isReservarion = true
                                                    break
                                                }
                                            }
                                        }
                                        if isReservarion == false{
                                            self.arr_search_spot.add(self.arrAllspot.object(at: i))
                                        }
                                    }
                                }
                                
                                //                                if dateDay1!.isSmallerThan(statCur) && dateDay2!.isGreaterThan(endCur){
                                //                                    var isReservarion = false
                                //                                    for dict in arrCurrentRes
                                //                                    {
                                //                                        if (dict as! NSDictionary).value(forKey: "spotID") as! String == dict_spot.value(forKey: "id") as! String
                                //                                        {
                                //                                            let date1 = (dict as! NSDictionary).value(forKey: "startDateTime") as! String
                                //                                            let date2 = (dict as! NSDictionary).value(forKey: "endDateTime") as! String
                                //                                            formatter.dateFormat = "yyyy-MM-dd HH:mm"
                                //                                            let date11 = formatter.date(from: date1)
                                //                                            let date22 = formatter.date(from: date2)
                                //                                            print(date1)
                                //                                            if date11!.isSmallerThan(statCur) && date22!.isGreaterThan(endCur)
                                //                                            {
                                //                                                isReservarion = true
                                //                                                break
                                //                                            }
                                //                                        }
                                //                                    }
                                //                                    if isReservarion == false{
                                //                                        self.arr_search_spot.add(self.arrAllspot.object(at: i))
                                //                                    }
                                //                                }
                            }
                        }
                    }
                    //MARK:- Saturday Loop
                    if arr_day[j] == "Saturday" {
                        if (self.arrAllspot.object(at: i) as! NSDictionary).value(forKey: "satswitch") as! Bool == true{
                            let arrsat = datedaydict.value(forKey: "Saturday") as! NSArray
                            for m in 0..<arrsat.count{
                                
                                let spotStart_times = "\(str) \(dict_spot.value(forKey: "satStartTime") as! String)"
                                let spotEnd_times = "\(str) \(dict_spot.value(forKey: "satEndTime") as! String)"
                                formatter.dateFormat = "yyyy-MM-dd h:mm a"
                                let dateDay1 = formatter.date(from: spotStart_times)
                                let dateDay2 = formatter.date(from: spotEnd_times)
                                formatter.dateFormat = "MMM dd h a"
                                
                                let statCur = self.dateWithHour(hour:calcheck.component(.hour, from: self.start_date!), minute: 00, second: 00, date: self.start_date!)!
                                let endCur = self.dateWithHour(hour:calcheck.component(.hour, from:self.end_date!), minute: 00, second: 00, date: self.end_date!)!
                                let statCheck = self.dateWithHour(hour:22, minute: 00, second: 00, date: self.start_date!)!
                                if statCheck.isSmallerThan(statCur) || statCheck == statCur
                                {
                                    print("true")
                                    let spotStart_times = "\(str) \(dict_spot.value(forKey: "sunStartTime") as! String)"
                                    let spotEnd_times = "\(str) \(dict_spot.value(forKey: "sunEndTime") as! String)"
                                    formatter.dateFormat = "yyyy-MM-dd h:mm a"
                                    let dateeDay1 = formatter.date(from: spotStart_times)
                                    let dateeDay2 = formatter.date(from: spotEnd_times)
                                    formatter.dateFormat = "MMM dd h a"
                                    if dateeDay1 != nil || dateeDay2 != nil
                                    {
                                        
                                        if dateeDay1!.isSmallerThan(endCur) && dateeDay2!.isSmallerThan(endCur)
                                        {
                                            var isReservarion = false
                                            for dict in arrCurrentRes
                                            {
                                                if (dict as! NSDictionary).value(forKey: "spotID") as! String == dict_spot.value(forKey: "id") as! String
                                                {
                                                    let date1 = (dict as! NSDictionary).value(forKey: "startDateTime") as! String
                                                    let date2 = (dict as! NSDictionary).value(forKey: "endDateTime") as! String
                                                    formatter.dateFormat = "yyyy-MM-dd HH:mm"
                                                    let date11 = formatter.date(from: date1)
                                                    let date22 = formatter.date(from: date2)
                                                    print(date1)
                                                    if date11!.isSmallerThan(statCur) && date22!.isGreaterThan(endCur)
                                                    {
                                                        isReservarion = true
                                                        break
                                                    }
                                                }
                                            }
                                            if isReservarion == false{
                                                self.arr_search_spot.add(self.arrAllspot.object(at: i))
                                            }
                                        }
                                    }
                                }else
                                {
                                    if dateDay1!.isSmallerThan(statCur) && dateDay2!.isGreaterThan(endCur){
                                        var isReservarion = false
                                        for dict in arrCurrentRes
                                        {
                                            if (dict as! NSDictionary).value(forKey: "spotID") as! String == dict_spot.value(forKey: "id") as! String
                                            {
                                                let date1 = (dict as! NSDictionary).value(forKey: "startDateTime") as! String
                                                let date2 = (dict as! NSDictionary).value(forKey: "endDateTime") as! String
                                                formatter.dateFormat = "yyyy-MM-dd HH:mm"
                                                let date11 = formatter.date(from: date1)
                                                let date22 = formatter.date(from: date2)
                                                print(date1)
                                                if date11!.isSmallerThan(statCur) && date22!.isGreaterThan(endCur)
                                                {
                                                    isReservarion = true
                                                    break
                                                }
                                            }
                                        }
                                        if isReservarion == false{
                                            self.arr_search_spot.add(self.arrAllspot.object(at: i))
                                        }
                                    }
                                }
                                
                                //                                if dateDay1!.isSmallerThan(statCur) && dateDay2!.isGreaterThan(endCur){
                                //                                    var isReservarion = false
                                //                                    for dict in arrCurrentRes
                                //                                    {
                                //                                        if (dict as! NSDictionary).value(forKey: "spotID") as! String == dict_spot.value(forKey: "id") as! String
                                //                                        {
                                //                                            let date1 = (dict as! NSDictionary).value(forKey: "startDateTime") as! String
                                //                                            let date2 = (dict as! NSDictionary).value(forKey: "endDateTime") as! String
                                //                                            formatter.dateFormat = "yyyy-MM-dd HH:mm"
                                //                                            let date11 = formatter.date(from: date1)
                                //                                            let date22 = formatter.date(from: date2)
                                //                                            print(date1)
                                //                                            if date11!.isSmallerThan(statCur) && date22!.isGreaterThan(endCur)
                                //                                            {
                                //                                                isReservarion = true
                                //                                                break
                                //                                            }
                                //                                        }
                                //                                    }
                                //                                    if isReservarion == false{
                                //                                        self.arr_search_spot.add(self.arrAllspot.object(at: i))
                                //                                    }
                                //                                }
                            }
                        }
                    }
                }
            }
            print(self.arr_search_spot)
            // Search Data load marker:-
            self.Search_Spot()
            self.Date_VIew.isHidden = true
        }
        endChange = false
        
    }
    
    
    //    @IBAction func btn_Date_search_done(_ sender: UIButton) {
    //        Time_price = true
    //        let d1 = start_datepic.date
    //        let d2 = end_datepic.date
    //
    //        let formatter = DateFormatter()
    //        // formatter.dateFormat = "EE MMM dd h a"
    //        formatter.dateFormat = "MMM dd, h a"
    //
    //        //        strPickerStart = formatter.string(from:  d1)
    //        //        strPickerEnd = formatter.string(from: d2)
    //
    //        //        print(datestart)
    //        //        print(dateend)
    //
    //        // lbl_spot_time.text = "Spot Time - \(datestart) to \(dateend)"
    //        var time1 = Bool()
    //
    //        // start date time check today
    //        let myStringafd = dateFormatter2.string(from: start_datepic.date)
    //        print(myStringafd)
    //         if myStringafd.contains("AM")
    //        {
    //            if format1 == "AM"
    //            {
    //                start_date = dateFormatter2.date(from: myStringafd)!
    //                strPickerStart = formatter.string(from:  start_date!)
    //
    //            }else
    //            {
    //                let replaced = myStringafd.replacingOccurrences(of: "AM", with: "PM")
    //                start_date = dateFormatter2.date(from: replaced)!
    //                strPickerStart = formatter.string(from:  start_date!)
    //
    //            }
    //            print(start_date!)
    //        }else
    //        {
    //            if format1 == "PM"
    //            {
    //                start_date = dateFormatter2.date(from: myStringafd)!
    //                strPickerStart = formatter.string(from:  start_date!)
    //
    //            }else
    //            {
    //                let replaced = myStringafd.replacingOccurrences(of: "PM", with: "AM")
    //                start_date = dateFormatter2.date(from: replaced)!
    //                strPickerStart = formatter.string(from:  start_date!)
    //
    //            }
    //            print(start_date!)
    //        }
    //
    //        if (datetostring(dates: start_date!)) == (datetostring(dates: Date())) {
    //
    //            let usertime = datetotime(userdate: dateconvert(userdate: start_date!))
    //            print(usertime)
    //
    //            let Datesystmem = datetotime(userdate: dateconvert(userdate: Date()))
    //            print(Datesystmem)
    //
    //            if usertime != Datesystmem && usertime < Datesystmem {
    //                time1 = true
    //            }
    //        }
    //
    //        print(time1)
    //        var firsttime = Bool()
    //        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:a"
    //        if endChange == false {
    //            print(start_date)
    //            print(end_date)
    //
    ////            let addhour = calendar.date(byAdding: .hour, value: 3, to: start_date!)
    ////            end_date = addhour!
    ////            strPickerEnd = formatter.string(from:  end_date!)
    ////
    ////            print(addhour)
    //             end_date = end_datepic.date
    //            print(end_date)
    //        }
    //
    //        // End date time check today
    //        if endChange == true {
    //            var str = dateFormatter2.string(from: end_datepic.date)
    //
    //            if str.contains("AM")
    //            {
    //                if format2 == "AM"
    //                {
    //                    end_date = dateFormatter2.date(from: str)!
    //                    strPickerEnd = formatter.string(from:  end_date!)
    //
    //                }else
    //                {
    //                    let replaced = str.replacingOccurrences(of: "AM", with: "PM")
    //                    end_date = dateFormatter2.date(from: replaced)!
    //                    strPickerEnd = formatter.string(from:  end_date!)
    //
    //                }
    //                print(end_date!)
    //            }
    //
    //            else
    //            {
    //                if format2 == "PM"
    //                {
    //                    end_date = dateFormatter2.date(from: str)!
    //                    strPickerEnd = formatter.string(from:  end_date!)
    //
    //                }else
    //                {
    //                    let replaced = str.replacingOccurrences(of: "PM", with: "AM")
    //                    end_date = dateFormatter2.date(from: replaced)!
    //                    strPickerEnd = formatter.string(from:  end_date!)
    //                }
    //                print(end_date!)
    //            }
    //
    //        }
    //
    //        start_date = dateconvert(userdate: start_date!)
    //        end_date = dateconvert(userdate: end_date!)
    //        print(strPickerStart)
    //        print(strPickerEnd)
    //
    //        if time1 == true{
    //            time1 = false
    //            let alert = UIAlertController(title: "Spotbirdparking", message: "Invalid Start TIME", preferredStyle: .alert)
    //            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
    //            self.present(alert, animated: true, completion: nil)
    //        }
    //        else if (datetostring(dates: end_date!))  < (datetostring(dates: start_date!)) && (datetostring(dates: start_date!)) != (datetostring(dates: end_date!))
    //        {
    //            let alert = UIAlertController(title: "Spotbirdparking", message: "Start date greater than End date.", preferredStyle: .alert)
    //            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
    //            self.present(alert, animated: true, completion: nil)
    //        }
    //        else if (datetostring(dates: end_date!)) == (datetostring(dates: start_date!)) && end_date!.time < start_date!.time {
    //            let alert = UIAlertController(title: "Spotbirdparking", message: "End Time greater than Start date.", preferredStyle: .alert)
    //            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
    //            self.present(alert, animated: true, completion: nil)
    //        }else if start_date! == end_date!  {
    //            let alert = UIAlertController(title: "Spotbirdparking", message: " Start date and end date is equal.", preferredStyle: .alert)
    //            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
    //            self.present(alert, animated: true, completion: nil)
    //        }
    //        else{
    //            dateFormatter.dateFormat = "EEE, MMM d, yyyy - h:mm a"
    //            let localtime1 = dateFormatter2.string(from: start_date!)
    //            let localtime2 = dateFormatter2.string(from: end_date!)
    //            arr_search_spot.removeAllObjects()
    //
    //            var arr_date = [Date]()
    //            var arr_day = [String]()
    //            var date = start_datepic.date
    //            while date <= end_datepic.date{
    //                arr_date.append(date)
    //                date = calendar.date(byAdding: .day, value: 1, to: date)!
    //            }
    //            if arr_date.count>0 {
    //                for i in 0..<arr_date.count{
    //                    let dateformats = DateFormatter()
    //                    //  dateformats.timeZone = TimeZone(abbreviation: "UTC")
    //                    dateformats.timeZone = TimeZone.current
    //                    dateformats.dateFormat  = "EEEE"       //"EE" to get short style
    //                    let dayInWeek = dateformats.string(from: arr_date[i])
    //                    arr_day.append(dayInWeek)
    //                }
    //            }
    //            var datedaydict = NSMutableDictionary()
    //            var arrsunday = [Date]()
    //            var arrmonday = [Date]()
    //            var arrtuesday = [Date]()
    //            var arrwednesday = [Date]()
    //            var arrthuesday = [Date]()
    //            var arrfriday = [Date]()
    //            var arrsatarday = [Date]()
    //
    //            for i in 0..<arr_date.count
    //            {
    //                if arr_day[i] == ("Sunday")
    //                {
    //                    arrsunday.append(arr_date[i])
    //                }
    //                if arr_day[i] == "Monday" {
    //                    arrmonday.append(arr_date[i])
    //                }
    //                if arr_day[i] == "Tuesday" {
    //                    arrtuesday.append(arr_date[i])
    //                }
    //                if arr_day[i] == "Wednesday" {
    //                    arrwednesday.append(arr_date[i])
    //                }
    //                if arr_day[i] == "Thursday" {
    //                    arrthuesday.append(arr_date[i])
    //                }
    //                if arr_day[i] == "Friday" {
    //                    arrfriday.append(arr_date[i])
    //                }
    //                if arr_day[i] == "Saturday" {
    //                    arrsatarday.append(arr_date[i])
    //                }
    //            }
    //
    //            if arrsunday.count>0
    //            {
    //                datedaydict.setValue(arrsunday, forKey: "Sunday")
    //            }
    //            if arrmonday.count>0{
    //                datedaydict.setValue(arrmonday, forKey: "Monday")
    //            }
    //            if arrtuesday.count>0 {
    //                datedaydict.setValue(arrtuesday, forKey: "Tuesday")
    //            }
    //            if arrwednesday.count>0 {
    //                datedaydict.setValue(arrwednesday, forKey: "Wednesday")
    //            }
    //            if arrthuesday.count>0 {
    //                datedaydict.setValue(arrthuesday, forKey: "Thursday")
    //            }
    //            if arrfriday.count>0 {
    //                datedaydict.setValue(arrfriday, forKey: "Friday")
    //            }
    //            if arrsatarday.count>0 {
    //                datedaydict.setValue(arrsatarday, forKey: "Saturday")
    //            }
    //
    //            print(arr_day)
    //            print(datedaydict)
    //            let dateformats = DateFormatter()
    //            dateformats.timeZone = TimeZone.current
    //            dateformats.dateFormat  = "EEEE"
    //            let dayInWeek = dateformats.string(from: Date())
    //
    //            let formatter = DateFormatter()
    //            // initially set the format based on your datepicker date / server String
    //            formatter.dateFormat = "yyyy-MM-dd"
    //            formatter.timeZone = TimeZone(abbreviation: "GMT+0:00")
    //            var str = formatter.string(from: Date())
    //
    //             let arrCurrentRes = AppState.sharedInstance.user.myReservations
    //
    //            for i in 0..<self.arrAllspot.count{
    //                        for j in 0..<arr_day.count{
    //
    //                            if i == 3 || i == 9 || i == 11 || i == 12{
    //
    //                                print("i Cheack ")
    //
    //                            }
    //                            let dict_spot = self.arrAllspot.object(at: i) as! NSDictionary
    //
    //                            var localTimeZoneName: String { return TimeZone.current.identifier }
    //                            print(localTimeZoneName)
    //
    //
    //                            //MARK:- Sunday Loop
    //
    //
    //                    if arr_day[j] == "Sunday" {
    //                                if (self.arrAllspot.object(at: i) as! NSDictionary).value(forKey: "sunswitch") as! Bool == true{
    //
    //                                    let arrsun = datedaydict.value(forKey: "Sunday") as! NSArray
    //                                    for m in 0..<arrsun.count{
    //
    //
    //                                        let spotStart_times = "\(str) \(dict_spot.value(forKey: "sunStartTime") as! String)"
    //                                        let spotEnd_times = "\(str) \(dict_spot.value(forKey: "sunEndTime") as! String)"
    //
    //                                        formatter.dateFormat = "yyyy-MM-dd h:mm a"
    //                                        let dateDay1 = formatter.date(from: spotStart_times)
    //                                        let dateDay2 = formatter.date(from: spotEnd_times)
    //                                        formatter.dateFormat = "MMM dd h a"
    //
    //                                        let diffInDays = Calendar.current.dateComponents([.day], from: dateDay1!, to: self.end_date!).day
    //                                        let arrDate = NSMutableArray()
    //                                        var newDate = dateDay2!
    //                                        while newDate <= self.end_date! {
    //
    //                                            arrDate.add(calendar.date(byAdding: .day, value: 1, to: newDate)!)
    //                                            newDate = calendar.date(byAdding: .day, value: 1, to: newDate)!
    //                                        }
    //
    //                                        if dateDay1!.isSmallerThan(self.start_date!) && dateDay2!.isGreaterThan(self.end_date!){
    //                                            //Do Something... var isReservarion = false
    //                                            var isReservarion = false
    //                                            for dict in arrCurrentRes
    //                                            {
    //                                                if (dict as! NSDictionary).value(forKey: "spotID") as! String == dict_spot.value(forKey: "id") as! String
    //                                                {
    //                                                    let date1 = (dict as! NSDictionary).value(forKey: "startDateTime") as! String
    //                                                    let date2 = (dict as! NSDictionary).value(forKey: "endDateTime") as! String
    //                                                    formatter.dateFormat = "yyyy-MM-dd HH:mm"
    //                                                    let date11 = formatter.date(from: date1)
    //                                                    let date22 = formatter.date(from: date2)
    //                                                    print(date1)
    //                                                    if date11!.isSmallerThan(self.start_date!) && date22!.isGreaterThan(self.end_date!)
    //                                                    {
    //                                                        isReservarion = true
    //                                                        break
    //                                                    }
    //                                                }
    //                                            }
    //                                            if isReservarion == false{
    //                                                self.arr_search_spot.add(self.arrAllspot.object(at: i))
    //                                           }
    //
    //                                        }
    //                                    }
    //                                }
    //
    //
    //// Comment Part Which is cutted from line number 1153
    //                                //                                        let sunStartTime = self.dateconvertServer(userdate: dict_spot.value(forKey: "sunStartTime") as! String)
    //                                //                                        let sunEndTime = self.dateconvertServer(userdate: dict_spot.value(forKey: "sunEndTime")  as! String)
    //                                //
    //                                //                                        let server_start1 = self.datetotime(userdate: sunStartTime)
    //                                //                                        let server_end1 = self.datetotime(userdate: sunEndTime)
    //                                //                                        print("server   - \(server_start1)")     // server
    //                                //                                        print("server     - \(server_end1)")     // server
    //                                //
    //                                //                                        let user_start = self.datetotime(userdate: self.start_date!)
    //                                //                                        let user_end = self.datetotime(userdate: self.end_date!)
    //                                //
    //                                //                                        print("user_start   - \(user_start)")     // user
    //                                //                                        print("user_end     - \(user_end)")     // user
    //                                //
    //                                //                                        // if user_start >= server_start1 && user_end <= server_end1{
    //                                //                                        self.arr_search_spot.add(self.arrAllspot.object(at: i))
    //
    //
    //
    //
    //
    //
    //                            }
    //
    //                            //MARK:- Monday Loop
    //                            if arr_day[j] == "Monday" {
    //                                if (self.arrAllspot.object(at: i) as! NSDictionary).value(forKey: "monswitch") as! Bool == true{
    //
    //                                    let arrmun = datedaydict.value(forKey: "Monday") as! NSArray
    //                                    for m in 0..<arrmun.count{
    //
    //                                        let Munday_start = self.dateconvertServer(userdate: dict_spot.value(forKey: "monStartTime") as! String)
    //                                        let Munday_end = self.dateconvertServer(userdate: dict_spot.value(forKey: "monEndTime")  as! String)
    //
    //                                        let server_start1 = self.datetotime(userdate: Munday_start)
    //                                        let server_end1 = self.datetotime(userdate: Munday_end)
    //                                        print("server   - \(server_start1)")     // server
    //                                        print("server     - \(server_end1)")     // server
    //
    //                                        let user_start = self.datetotime(userdate: self.start_date!)
    //                                        let user_end = self.datetotime(userdate: self.end_date!)
    //
    //                                        print("user_start   - \(user_start)")     // user
    //                                        print("user_end     - \(user_end)")     // user
    //
    //                                        if user_start >= server_start1 && user_end <= server_end1{
    //                                            var isReservarion = false
    //                                            for dict in arrCurrentRes
    //                                            {
    //                                                if (dict as! NSDictionary).value(forKey: "spotID") as! String == dict_spot.value(forKey: "id") as! String
    //                                                {
    //                                                    let date1 = (dict as! NSDictionary).value(forKey: "startDateTime") as! String
    //                                                    let date2 = (dict as! NSDictionary).value(forKey: "endDateTime") as! String
    //                                                    formatter.dateFormat = "yyyy-MM-dd HH:mm"
    //                                                    let date11 = formatter.date(from: date1)
    //                                                    let date22 = formatter.date(from: date2)
    //                                                    print(date1)
    //                                                    if date11!.isSmallerThan(self.start_date!) && date22!.isGreaterThan(self.end_date!)
    //                                                    {
    //                                                        isReservarion = true
    //                                                        break
    //                                                    }
    //                                                }
    //                                            }
    //                                            if isReservarion == false{
    //                                                self.arr_search_spot.add(self.arrAllspot.object(at: i))
    //                                            }
    //                                        }
    ////                                        let spotStart_times = "\(str) \(dict_spot.value(forKey: "monStartTime") as! String)"
    ////                                        let spotEnd_times = "\(str) \(dict_spot.value(forKey: "monEndTime") as! String)"
    ////                                        formatter.dateFormat = "yyyy-MM-dd h:mm a"
    ////                                        let dateDay1 = formatter.date(from: spotStart_times)
    ////                                        let dateDay2 = formatter.date(from: spotEnd_times)
    ////                                        formatter.dateFormat = "MMM dd h a"
    ////                                        if dateDay1!.isSmallerThan(self.start_date!) && dateDay2!.isGreaterThan(self.end_date!){
    ////                                            //Do Something...
    ////                                            self.arr_search_spot.add(self.arrAllspot.object(at: i))
    ////                                        }
    //
    //                                    }
    //                                }
    //                            }
    //                            //MARK:- Tuesday Loop
    //                            if arr_day[j] == "Tuesday" {
    //                                if (self.arrAllspot.object(at: i) as! NSDictionary).value(forKey: "tueswitch") as! Bool == true{
    //
    //                                    let arrthue = datedaydict.value(forKey: "Tuesday") as! NSArray
    //                                    for m in 0..<arrthue.count{
    //
    //                                        let tueStartTime = self.dateconvertServer(userdate: dict_spot.value(forKey: "tueStartTime") as! String)
    //                                        let tueEndTime = self.dateconvertServer(userdate: dict_spot.value(forKey: "tueEndTime")  as! String)
    //
    //                                        let server_start1 = self.datetotime(userdate: tueStartTime)
    //                                        let server_end1 = self.datetotime(userdate: tueEndTime)
    //                                        print("server   - \(server_start1)")     // server
    //                                        print("server     - \(server_end1)")     // server
    //
    //                                        let user_start = self.datetotime(userdate: self.start_date!)
    //                                        let user_end = self.datetotime(userdate: self.end_date!)
    //
    //                                        print("user_start   - \(user_start)")     // user
    //                                        print("user_end     - \(user_end)")     // user
    //
    //                                        if user_start >= server_start1 && user_end <= server_end1{
    //                                            var isReservarion = false
    //                                            for dict in arrCurrentRes
    //                                            {
    //                                                if (dict as! NSDictionary).value(forKey: "spotID") as! String == dict_spot.value(forKey: "id") as! String
    //                                                {
    //                                                    let date1 = (dict as! NSDictionary).value(forKey: "startDateTime") as! String
    //                                                    let date2 = (dict as! NSDictionary).value(forKey: "endDateTime") as! String
    //                                                    formatter.dateFormat = "yyyy-MM-dd HH:mm"
    //                                                    let date11 = formatter.date(from: date1)
    //                                                    let date22 = formatter.date(from: date2)
    //                                                    print(date1)
    //                                                    if date11!.isSmallerThan(self.start_date!) && date22!.isGreaterThan(self.end_date!)
    //                                                    {
    //                                                        isReservarion = true
    //                                                        break
    //                                                    }
    //                                                }
    //                                            }
    //                                            if isReservarion == false{
    //                                                self.arr_search_spot.add(self.arrAllspot.object(at: i))
    //                                            }
    //                                        }
    ////                                        let spotStart_times = "\(str) \(dict_spot.value(forKey: "tueStartTime") as! String)"
    ////                                        let spotEnd_times = "\(str) \(dict_spot.value(forKey: "tueEndTime") as! String)"
    ////                                        formatter.dateFormat = "yyyy-MM-dd h:mm a"
    ////                                        let dateDay1 = formatter.date(from: spotStart_times)
    ////                                        let dateDay2 = formatter.date(from: spotEnd_times)
    ////                                        formatter.dateFormat = "MMM dd h a"
    ////                                        if dateDay1!.isSmallerThan(self.start_date!) && dateDay2!.isGreaterThan(self.end_date!){
    ////                                            //Do Something...
    ////                                            self.arr_search_spot.add(self.arrAllspot.object(at: i))
    ////                                        }
    ////
    //
    //                                    }
    //                                }
    //                            }
    //                            //MARK:- Wednesday Loop
    //                            if arr_day[j] == "Wednesday" {
    //                                if (self.arrAllspot.object(at: i) as! NSDictionary).value(forKey: "wedswitch") as! Bool == true{
    //
    //                                    let arrwed = datedaydict.value(forKey: "Wednesday") as! NSArray
    //                                    for m in 0..<arrwed.count{
    //
    //                                        let wedStartTime = self.dateconvertServer(userdate: dict_spot.value(forKey: "wedStartTime") as! String)
    //                                        let wedEndTime = self.dateconvertServer(userdate: dict_spot.value(forKey: "wedEndTime")  as! String)
    //
    //                                        let server_start1 = self.datetotime(userdate: wedStartTime)
    //                                        let server_end1 = self.datetotime(userdate: wedEndTime)
    //                                        print("server   - \(server_start1)")     // server
    //                                        print("server     - \(server_end1)")     // server
    //
    //                                        let user_start = self.datetotime(userdate: self.start_date!)
    //                                        let user_end = self.datetotime(userdate: self.end_date!)
    //
    //                                        print("user_start   - \(user_start)")     // user
    //                                        print("user_end     - \(user_end)")     // user
    //
    //
    //
    //                                        if user_start >= server_start1 && user_end <= server_end1{
    //                                            var isReservarion = false
    //                                            for dict in arrCurrentRes
    //                                            {
    //                                                if (dict as! NSDictionary).value(forKey: "spotID") as! String == dict_spot.value(forKey: "id") as! String
    //                                                {
    //                                                    let date1 = (dict as! NSDictionary).value(forKey: "startDateTime") as! String
    //                                                    let date2 = (dict as! NSDictionary).value(forKey: "endDateTime") as! String
    //                                                    formatter.dateFormat = "yyyy-MM-dd HH:mm"
    //                                                    let date11 = formatter.date(from: date1)
    //                                                    let date22 = formatter.date(from: date2)
    //                                                    print(date1)
    //                                                    if date11!.isSmallerThan(self.start_date!) && date22!.isGreaterThan(self.end_date!)
    //                                                    {
    //                                                        isReservarion = true
    //                                                        break
    //                                                    }
    //                                                }
    //                                            }
    //                                            if isReservarion == false{
    //                                                self.arr_search_spot.add(self.arrAllspot.object(at: i))
    //                                            }
    //                                        }
    //
    ////                                        let spotStart_times = "\(str) \(dict_spot.value(forKey: "wedStartTime") as! String)"
    ////                                        let spotEnd_times = "\(str) \(dict_spot.value(forKey: "wedEndTime") as! String)"
    ////                                        formatter.dateFormat = "yyyy-MM-dd h:mm a"
    ////                                        let dateDay1 = formatter.date(from: spotStart_times)
    ////                                        let dateDay2 = formatter.date(from: spotEnd_times)
    ////                                        formatter.dateFormat = "MMM dd h a"
    ////                                        if dateDay1!.isSmallerThan(self.start_date!) && dateDay2!.isGreaterThan(self.end_date!){
    ////                                            //Do Something...
    ////                                            self.arr_search_spot.add(self.arrAllspot.object(at: i))
    ////                                        }
    ////
    //                                    }
    //                                }
    //                            }
    //                            //MARK:- Thusday Loop
    //                            if arr_day[j] == "Thursday" {
    //
    //                                if (self.arrAllspot.object(at: i) as! NSDictionary).value(forKey: "thuswitch") as! Bool == true{
    //
    //                                    let arrThu = datedaydict.value(forKey: "Thursday") as! NSArray
    //                                    for m in 0..<arrThu.count{
    //
    //                                        let thuStartTime = self.dateconvertServer(userdate: dict_spot.value(forKey: "thuStartTime") as! String)
    //                                        let thuEndTime = self.dateconvertServer(userdate: dict_spot.value(forKey: "thuEndTime")  as! String)
    //
    //                                        let server_start1 = self.datetotime(userdate: thuStartTime)
    //                                        let server_end1 = self.datetotime(userdate: thuEndTime)
    //                                        print("server   - \(server_start1)")     // server
    //                                        print("server     - \(server_end1)")     // server
    //
    //                                        let user_start = self.datetotime(userdate: self.start_date!)
    //                                        let user_end = self.datetotime(userdate: self.end_date!)
    //
    //                                        print("user_start   - \(user_start)")     // user
    //                                        print("user_end     - \(user_end)")     // user
    //
    //                                        if user_start >= server_start1 && user_end <= server_end1{
    //                                            var isReservarion = false
    //                                            for dict in arrCurrentRes
    //                                            {
    //                                                if (dict as! NSDictionary).value(forKey: "spotID") as! String == dict_spot.value(forKey: "id") as! String
    //                                                {
    //                                                    let date1 = (dict as! NSDictionary).value(forKey: "startDateTime") as! String
    //                                                    let date2 = (dict as! NSDictionary).value(forKey: "endDateTime") as! String
    //                                                    formatter.dateFormat = "yyyy-MM-dd HH:mm"
    //                                                    let date11 = formatter.date(from: date1)
    //                                                    let date22 = formatter.date(from: date2)
    //                                                    print(date1)
    //                                                    if date11!.isSmallerThan(self.start_date!) && date22!.isGreaterThan(self.end_date!)
    //                                                    {
    //                                                        isReservarion = true
    //                                                        break
    //                                                    }
    //                                                }
    //                                            }
    //                                            if isReservarion == false{
    //                                                self.arr_search_spot.add(self.arrAllspot.object(at: i))
    //                                            }
    //                                        }
    ////
    ////                                        let spotStart_times = "\(str) \(dict_spot.value(forKey: "thuStartTime") as! String)"
    ////                                        let spotEnd_times = "\(str) \(dict_spot.value(forKey: "thuEndTime") as! String)"
    ////                                        formatter.dateFormat = "yyyy-MM-dd h:mm a"
    ////                                        let dateDay1 = formatter.date(from: spotStart_times)
    ////                                        let dateDay2 = formatter.date(from: spotEnd_times)
    ////                                        formatter.dateFormat = "MMM dd h a"
    ////                                        if dateDay1!.isSmallerThan(self.start_date!) && dateDay2!.isGreaterThan(self.end_date!){
    ////                                            //Do Something...
    ////                                            self.arr_search_spot.add(self.arrAllspot.object(at: i))
    ////                                        }
    //                                    }
    //                                }
    //                            }
    //
    //                            //MARK:- Friday Loop
    //                            if arr_day[j] == "Friday" {
    //                                if (self.arrAllspot.object(at: i) as! NSDictionary).value(forKey: "friswitch") as! Bool == true{
    //
    //                                    let arrFri = datedaydict.value(forKey: "Friday") as! NSArray
    //                                    for m in 0..<arrFri.count{
    //
    //                                        print(dict_spot.value(forKey: "friStartTime") as! String)
    //                                        print(dict_spot.value(forKey: "friEndTime")  as! String)
    //
    //                                        let friStartTime = self.dateconvertServer(userdate: dict_spot.value(forKey: "friStartTime") as! String)
    //                                        let friEndTime = self.dateconvertServer(userdate: dict_spot.value(forKey: "friEndTime")  as! String)
    //                                        print(friStartTime)
    //                                        print(friEndTime)
    //
    //                                        let server_start1 = self.datetotime(userdate: friStartTime)
    //                                        let server_end1 = self.datetotime(userdate: friEndTime)
    //                                        print("server   - \(server_start1)")     // server
    //                                        print("server     - \(server_end1)")     // server
    //
    //                                        let user_start = self.datetotime(userdate: self.start_date!)
    //                                        let user_end = self.datetotime(userdate: self.end_date!)
    //
    //                                        print("user_start   - \(user_start)")     // user
    //                                        print("user_end     - \(user_end)")     // user
    //
    //                                        if user_start >= server_start1 && user_end <= server_end1{
    //                                            var isReservarion = false
    //                                            for dict in arrCurrentRes
    //                                            {
    //                                                if (dict as! NSDictionary).value(forKey: "spotID") as! String == dict_spot.value(forKey: "id") as! String
    //                                                {
    //                                                    let date1 = (dict as! NSDictionary).value(forKey: "startDateTime") as! String
    //                                                    let date2 = (dict as! NSDictionary).value(forKey: "endDateTime") as! String
    //                                                    formatter.dateFormat = "yyyy-MM-dd HH:mm"
    //                                                    let date11 = formatter.date(from: date1)
    //                                                    let date22 = formatter.date(from: date2)
    //                                                    print(date1)
    //                                                    if date11!.isSmallerThan(self.start_date!) && date22!.isGreaterThan(self.end_date!)
    //                                                    {
    //                                                        isReservarion = true
    //                                                        break
    //                                                    }
    //                                                }
    //                                            }
    //                                            if isReservarion == false{
    //                                                self.arr_search_spot.add(self.arrAllspot.object(at: i))
    //                                            }
    //                                        }
    //
    ////                                        let spotStart_times = "\(str) \(dict_spot.value(forKey: "friStartTime") as! String)"
    ////                                        let spotEnd_times = "\(str) \(dict_spot.value(forKey: "friEndTime") as! String)"
    ////                                        formatter.dateFormat = "yyyy-MM-dd h:mm a"
    ////                                        let dateDay1 = formatter.date(from: spotStart_times)
    ////                                        let dateDay2 = formatter.date(from: spotEnd_times)
    ////                                        formatter.dateFormat = "MMM dd h a"
    ////                                        if dateDay1!.isSmallerThan(self.start_date!) && dateDay2!.isGreaterThan(self.end_date!){
    ////                                            //Do Something...
    ////                                            self.arr_search_spot.add(self.arrAllspot.object(at: i))
    ////                                        }
    //                                    }
    //                                }
    //                            }
    //                            //MARK:- Saturday Loop
    //                            if arr_day[j] == "Saturday" {
    //                                if (self.arrAllspot.object(at: i) as! NSDictionary).value(forKey: "satswitch") as! Bool == true{
    //                                    let arrsat = datedaydict.value(forKey: "Saturday") as! NSArray
    //                                    for m in 0..<arrsat.count{
    //                                        let satStartTime = self.dateconvertServer(userdate: dict_spot.value(forKey: "satStartTime") as! String)
    //                                        let satEndTime = self.dateconvertServer(userdate: dict_spot.value(forKey: "satEndTime")  as! String)
    //
    //                                        let server_start1 = self.datetotime(userdate: satStartTime)
    //                                        let server_end1 = self.datetotime(userdate: satEndTime)
    //                                        print("server   - \(server_start1)")     // server
    //                                        print("server     - \(server_end1)")     // server
    //
    //                                        let user_start = self.datetotime(userdate: self.start_date!)
    //                                        let user_end = self.datetotime(userdate: self.end_date!)
    //
    //                                        print("user_start   - \(user_start)")     // user
    //                                        print("user_end     - \(user_end)")     // user
    //
    //                                        if user_start >= server_start1 && user_end <= server_end1{
    //                                            var isReservarion = false
    //                                            for dict in arrCurrentRes
    //                                            {
    //                                                if (dict as! NSDictionary).value(forKey: "spotID") as! String == dict_spot.value(forKey: "id") as! String
    //                                                {
    //                                                    let date1 = (dict as! NSDictionary).value(forKey: "startDateTime") as! String
    //                                                    let date2 = (dict as! NSDictionary).value(forKey: "endDateTime") as! String
    //                                                    formatter.dateFormat = "yyyy-MM-dd HH:mm"
    //                                                    let date11 = formatter.date(from: date1)
    //                                                    let date22 = formatter.date(from: date2)
    //                                                    print(date1)
    //                                                    if date11!.isSmallerThan(self.start_date!) && date22!.isGreaterThan(self.end_date!)
    //                                                    {
    //                                                        isReservarion = true
    //                                                        break
    //                                                    }
    //                                                }
    //                                            }
    //                                            if isReservarion == false{
    //                                                self.arr_search_spot.add(self.arrAllspot.object(at: i))
    //                                            }
    //                                        }
    //
    ////                                        let spotStart_times = "\(str) \(dict_spot.value(forKey: "satStartTime") as! String)"
    ////                                        let spotEnd_times = "\(str) \(dict_spot.value(forKey: "satEndTime") as! String)"
    ////                                        formatter.dateFormat = "yyyy-MM-dd h:mm a"
    ////                                        let dateDay1 = formatter.date(from: spotStart_times)
    ////                                        let dateDay2 = formatter.date(from: spotEnd_times)
    ////                                        formatter.dateFormat = "MMM dd h a"
    ////                                        if dateDay1!.isSmallerThan(self.start_date!) && dateDay2!.isGreaterThan(self.end_date!){
    ////                                            //Do Something...
    ////                                            self.arr_search_spot.add(self.arrAllspot.object(at: i))
    ////                                        }
    //                                    }
    //                                }
    //                            }
    //                        }
    //                    }
    //                    print(self.arr_search_spot)
    //                    // Search Data load marker:-
    //                    self.Search_Spot()
    //                    self.Date_VIew.isHidden = true
    //        }
    //        endChange = false
    //
    //    }
    
    // MARK:- Google Api getting distance
    
    func callPlotRouteCalcDistanceAndTimeApis(originLat:String, originLong:String, destinationLat:String, destinationLong:String){
        
        requestGoogleMapsDirectionApis(originLat: originLat, originLong: originLong, destinationLat: destinationLat, destinationLong: destinationLong, onSuccess: { (response) in
            
            // filter data
            // set data to model
            // plot route in google map
            self.responseJsonObjectFilter(jsonObject: response)
            
        }) { (failureMsz) in
            
            
        }
    }
    
    // MARK: - GoogleMaps Direction
    func requestGoogleMapsDirectionApis(originLat: String,originLong:String, destinationLat:String, destinationLong:String, onSuccess:@escaping (_ response:AnyObject)->Void, onError:@escaping (_ errorMessage:String)->Void)->Void{
        
        // GOOGLE DIRECTION APIS DEMO
        //https://maps.googleapis.com/maps/api/directions/json?origin=27.696981,85.2942719&destination=27.6792144,85.3632975&sensor=false&mode=driving&alternatives=falseGOOGLE_MAP_API_KEY
        
        let url:String =   "https://maps.googleapis.com/maps/api/distancematrix/json?units=imperial&origins=\(originLat),\(originLong)&destinations=\(destinationLat),\(destinationLong)&key=AIzaSyATq8xrUL51RMK8Xgf_3YI-dl_ocbNajD4"
        
        
        //let url:String = "https://maps.googleapis.com/maps/api/directions/json?origin=\(originLat),\(originLong)&destination=\(destinationLat),\(destinationLong)&sensor=false&mode=driving&alternatives=false&key=AIzaSyCiA5RwJSdB8U9hdAHEW1US8k-TbQJ2OTI"
        // AIzaSyAn4Sx8oHd0-4gwKf83VxDZpjXyD2VeW1Y
        
        Alamofire.request(url, method: .get).responseJSON { response in
            
            switch response.result {
            case .success:
                
                if let jsonObject = response.result.value{
                    onSuccess(jsonObject as AnyObject)
                }
            case .failure:
                
                /* Handle error just using simple message */
                
                onError("failure")
                
            }
        }
    }
    
    /* Response object filter PLOT ROUTE APIs for SUCCESS or FAILED */
    func responseJsonObjectFilter(jsonObject:AnyObject){
        
        if let jsonObjectDictionary = jsonObject as? NSDictionary {
            
            print(jsonObjectDictionary)
            if let statusMessage = jsonObjectDictionary["status"] as? String{
                
                if(statusMessage == "OK"){
                    
                    if let rows = jsonObjectDictionary["rows"] as? [[String:Any]]{
                        
                        var element = rows[0]["elements"] as? [[String:Any]]
                        
                        var duration = element?[0]["duration"] as? [String:Any]
                        if duration != nil
                        {
                            print(duration?["text"] as! String)
                            lblDistance.text = duration?["text"] as! String
                        }
                    }
                    
                    if let routesObject = jsonObjectDictionary["elements"] as? [[String:Any]] {
                        
                        if let durationObjectNsDictionary = routesObject[1]["duration"] as? NSDictionary {
                            
                            var estimatedTime = durationObjectNsDictionary["text"] as! String
                            lblDistance.text = String(estimatedTime)
                        }
                    }
                }else{
                    
                }
            }
        }
    }
    
    
    func setStartEndDate()
    {
        let d1 = start_datepic.date
        let d2 = end_datepic.date
        
        let formatter = DateFormatter()
        //formatter.dateFormat = "EE MMM dd h a"
        formatter.dateFormat = "MMM dd, h a"
        
        //        strPickerStart = formatter.string(from:  d1)
        //        strPickerEnd = formatter.string(from: d2)
        
        //        print(datestart)
        //        print(dateend)
        
        // lbl_spot_time.text = "Spot Time - \(datestart) to \(dateend)"
        var time1 = Bool()
        
        // start date time check today
        let myStringafd = dateFormatter2.string(from: start_datepic.date)
        print(myStringafd)
        if myStringafd.contains("AM")
        {
            if format1 == "AM"
            {
                start_date = dateFormatter2.date(from: myStringafd)!
                strPickerStart = formatter.string(from:  start_date!)
                
            }else
            {
                let replaced = myStringafd.replacingOccurrences(of: "AM", with: "PM")
                start_date = dateFormatter2.date(from: replaced)!
                strPickerStart = formatter.string(from:  start_date!)
                
            }
            print(start_date!)
        }else
        {
            if format1 == "PM"
            {
                start_date = dateFormatter2.date(from: myStringafd)!
                strPickerStart = formatter.string(from:  start_date!)
                
            }else
            {
                let replaced = myStringafd.replacingOccurrences(of: "PM", with: "AM")
                start_date = dateFormatter2.date(from: replaced)!
                strPickerStart = formatter.string(from:  start_date!)
                
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
            strPickerEnd = formatter.string(from:  end_date!)
            
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
                    strPickerEnd = formatter.string(from:  end_date!)
                    
                }else
                {
                    let replaced = str.replacingOccurrences(of: "AM", with: "PM")
                    end_date = dateFormatter2.date(from: replaced)!
                    strPickerEnd = formatter.string(from:  end_date!)
                    
                }
                print(end_date!)
            }
                
            else
            {
                if format2 == "PM"
                {
                    end_date = dateFormatter2.date(from: str)!
                    strPickerEnd = formatter.string(from:  end_date!)
                    
                }else
                {
                    let replaced = str.replacingOccurrences(of: "PM", with: "AM")
                    end_date = dateFormatter2.date(from: replaced)!
                    strPickerEnd = formatter.string(from:  end_date!)
                }
                print(end_date!)
            }
            
        }
        
        start_date = dateconvert(userdate: start_date!)
        end_date = dateconvert(userdate: end_date!)
        print(strPickerStart)
        print(strPickerEnd)
    }
    
    func dateWithHour (hour: Int, minute:Int, second:Int,date: Date) ->Date?{
        var calendar = NSCalendar.current
        calendar.timeZone =  TimeZone(abbreviation: "GMT+0:00")!
        var components = calendar.dateComponents([.day,.month,.year], from: date)
        components.hour = hour
        components.minute = minute
        components.second = second
        let formatter = DateFormatter()
        // initially set the format based on your datepicker date / server String
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        formatter.timeZone = TimeZone(abbreviation: "GMT+0:00")
        let dateeeee = formatter.string(from: calendar.date(from: components)!)
        let d = formatter.date(from: dateeeee)
        return d
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
        
        // show that we are doing something
        Spinner.start()
        
        // debug lines
        print("Lets do some booking!")
        print("your customer token is: \(AppState.sharedInstance.user.customertoken)")
        // create dummy car to create reference to defaultCar
        var defaultCar = Car(make: "", model: "", year: "", carImage: "", isDefault: false, car_id: "")
        
        // get the user default car
        if(AppState.sharedInstance.user.cars.count > 0) {
            defaultCar = AppState.sharedInstance.user.getDefaultCar()
        }
        else {
            // handle if there are no cars
            let alert = UIAlertController(title: "No Cars", message: "To reserve a spot you must create a car in the Profile tab", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
            Spinner.stop()
            return
        }
        
        // make sure there is an active customertoken
        if(AppState.sharedInstance.user.customertoken == "") {
            // handle if user customertoken is ""
            let alert = UIAlertController(title: "Account Info Misconfigured", message: "Your account does not appear to have a token to connect to our payment system. Please contact Customer Service", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
            Spinner.stop()
            return
        }
        
        // check ahead to see if there is a value for the destination token
        let ownerID = self.highlightedSpot.owner_ids
        print("The owner's ID is: \(ownerID)")
        print("Destination found")
        AppState.sharedInstance.appStateRoot.child("User").child(ownerID).observeSingleEvent(of: .value, with: { (snapshot) in
            let userDict = snapshot.value as! [String: Any]
            let destination = userDict["accountToken"] as! String
            print("Destination is: \(destination)")
            
            if(destination == "") {
                // handle if user customertoken is ""
                let alert = UIAlertController(title: "Spot Info Misconfigured", message: "Spot was incorrectly configured. Please try another spot.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true)
                Spinner.stop()
                return
            }
        })
        
        // create reservation object
        let parkerReservation = Reservation(
            startDateTime: Reservation.dateToString(date: start_datepic.date),
            endDateTime: Reservation.dateToString(date: end_datepic.date),
            parkOrRent: "Park",
            spot: self.highlightedSpot,
            parkerID: AppState.sharedInstance.userid,
            car: defaultCar!,
            ownerID: ownerID,
            paymentIntent_id: ""
        )
        
        // track reservation to set paymentIntent_id
        // must be called before charge is created
        self.chargeInfoReservation = parkerReservation
        
        // check if there are any conflicting reservations
        AppState.sharedInstance.user.getReservationTimesForUser(spotUser: ownerID) {
            timesList in
            
            Spinner.start()
            
            print("IM in here")
            var isConflict = AppState.sharedInstance.user.checkReservationAgainstTimesList(res: parkerReservation!, timesList: timesList)
            
            Spinner.start()
            
            print("Conflict?: " + String(isConflict))
            
            // if there is a conflict display an alert and return
            if isConflict {
                print("We should display an alert")
                let alert = UIAlertController(title: "Spot Reserved During this Time", message: "We apologize, this spot is already reserved. Please try another spot", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true)
                Spinner.stop()
                return
            }
            else {
                print("IM over here")
                
                        
                // get integer value for amount for payment in cents
                let amount = Int((NumberFormatter().number(from: (parkerReservation?.price)!)!.floatValue) * 100)
                    print("Price (cents): \(amount)")
                
                Spinner.start()
//                sleep(4)
                
                // pay us
                print("we are getting paid")
                self.setPaymentContext(price: amount)
                print("The payment context has been set")
                Spinner.stop()
                self.paymentContext.requestPayment()
                
                // if payment is successful we will initiate transfer and setting reservations
                // see paymentContext didFinishWith ()
                    
            }
            
        }
    }
    
    // This function is a helper to btn_book, and is called by paymentContext : didFinishWith status
    public func transferAndSetReservations() {
        
        print("Begin transfer and set the reservations")
        
        Spinner.start()
        
        // set the default car
        let defaultCar = AppState.sharedInstance.user.getDefaultCar()
        
        // get the ID of the spot owner
        let ownerID = self.highlightedSpot.owner_ids

        // create reservation to be sent to the parker
        let parkerReservation = Reservation(
            startDateTime: Reservation.dateToString(date: start_datepic.date),
            endDateTime: Reservation.dateToString(date: end_datepic.date),
            parkOrRent: "Park",
            spot: self.highlightedSpot,
            parkerID: AppState.sharedInstance.userid,
            car: defaultCar,
            ownerID: ownerID,
            paymentIntent_id: AppState.sharedInstance.user.temporary_paymentIntent_id
        )
        
        // create reservation to be sent to the spot owner
        let ownerReservation = Reservation(
            startDateTime: Reservation.dateToString(date: start_datepic.date),
            endDateTime: Reservation.dateToString(date: end_datepic.date),
            parkOrRent: "Rent",
            spot: self.highlightedSpot,
            parkerID: AppState.sharedInstance.userid,
            car: defaultCar,
            ownerID: ownerID,
            paymentIntent_id: ""
        )
        
        // set reservations in the database
        print("The reservations are being created in the db")
        AppState.sharedInstance.user.addReservation(reservation: parkerReservation!)
        AppState.sharedInstance.user.addReservationToUser(reservation: ownerReservation!)
        
        let source = AppState.sharedInstance.user.customertoken

        AppState.sharedInstance.appStateRoot.child("User").child(ownerID).observeSingleEvent(of: .value, with: { (snapshot) in
            
            let userDict = snapshot.value as! [String: Any]
            print("userDict: \(userDict)")
            let destination = userDict["accountToken"] as! String
            print("The destination is: \(destination)")
            
            // get integer value for amount for payment in cents
            let amount = Int((NumberFormatter().number(from: (parkerReservation?.price)!)!.floatValue) * 100)

            print("Amount to transfer: \(amount)")
            
//            let message = ("\(self.highlightedSpot.address) \(self.highlightedSpot.town), \(self.highlightedSpot.state) reserved. See active reservations in Reservations tab")
//            let title = "Success"
//            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//            self.present(alert, animated: true)
            
            // pay owner
            MyAPIClient.sharedClient.completeTransfer(destination: destination, spotAmount: amount, spotID: self.highlightedSpot.spot_id, startDateTime: Reservation.dateToString(date: self.start_datepic.date)) {result in
                
                // handle the result of the transfer
                if (result == "Success") {
                    print("Success")
                    Spinner.stop()
                    let message = ("\(self.highlightedSpot.address) \(self.highlightedSpot.town), \(self.highlightedSpot.state) reserved. See active reservations in Reservations tab")
                    let title = "Success"
                    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true)
                }
                else {
                    print("There was an issue with the payment transfer")
                }
            }
        })
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
        // self.CurrentLocMarker.title = "myLoc"
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
        if marker == self.CurrentLocMarker
        {
            return false
        }
        
        for mark in allMarkers {
            if mark == marker
            {
                marker.zIndex = 1
            }else
            {
                mark.zIndex = 0
            }
        }
        
        
        let index:Int! = Int(marker.accessibilityLabel!)
        print("Index is: \(String(index))")
        self.lblDistance.text = ""
        
        //        let coordinate1 = CLLocation(latitude: self.CurrentLocMarker.position.latitude, longitude: self.CurrentLocMarker.position.longitude)
        //        let coordinate2 = CLLocation(latitude: marker.position.latitude, longitude: marker.position.longitude)
        //        let distanceInMeters = coordinate1.distance(from: coordinate2)
        
        callPlotRouteCalcDistanceAndTimeApis(originLat: String(self.CurrentLocMarker.position.latitude), originLong: String(self.CurrentLocMarker.position.longitude), destinationLat:  String(marker.position.latitude), destinationLong: String(marker.position.longitude))
        
        if Time_price == true{
            
            //            let price  = (arr_search_spot.object(at: index) as! NSDictionary).value(forKey: "hourlyPricing") as?  String
            //            let doller = (price! as NSString).integerValue
            let form = DateFormatter()
            // initially set the format based on your datepicker date / server String
            form.dateFormat = "yyyy-MM-dd HH:mm"
            let START = form.string(from: start_date!)
            print("start time :" + START)
            let END = form.string(from: end_date!)
            print("end time :" + END)
            let basePrice = ((self.arr_search_spot.object(at: index) as! NSDictionary).value(forKey: "basePricing") as! String)
            let priceSPOT = Reservation.publicCalcPrice(startDateTimeString:START,endDateTimeString: END, basePrice: basePrice)
            
            //print(time_Price)
            let doller = Reservation.priceToString(price: priceSPOT)
            //            let numberOfPlaces = 2.0
            //            let multiplier = pow(10.0, numberOfPlaces)
            //            let doller = round(priceSPOT * multiplier) / multiplier
            
            view_info.isHidden = false
            btn_close.isHidden = false
            curruntlat = marker.position.latitude
            curruntlong = marker.position.longitude
            
            lbl_spot_time.text = "Time: \(strPickerStart) to \(strPickerEnd)"
            
            if (arr_search_spot.object(at: index) as! NSDictionary).value(forKey: "spot_type") as!  String == "Garage"{
                img_spot_type.image = UIImage(named:"garageParking")
            }
            if (arr_search_spot.object(at: index) as! NSDictionary).value(forKey: "spot_type") as!  String == "Lot"{
                img_spot_type.image = UIImage(named:"lotParking")
            }
            if (arr_search_spot.object(at: index) as! NSDictionary).value(forKey: "spot_type") as!  String == "Street"{
                img_spot_type.image = UIImage(named:"streetParking")
            }
            if (arr_search_spot.object(at: index) as! NSDictionary).value(forKey: "spot_type") as!  String == "Driveway"{
                img_spot_type.image = UIImage(named:"drivewayParking")
            }
            
            lbl_spot_type.text = (arr_search_spot.object(at: index) as! NSDictionary).value(forKey: "spot_type") as?  String
            
            // let intDist = Int(distanceInMeters)
            lbl_price.text = "$\(doller)"
            // lbl_price.text = "$\(doller)"
            lbl_address.text = (arr_search_spot.object(at: index) as! NSDictionary).value(forKey: "address") as?  String
            //
            let str = (arr_search_spot.object(at: index) as! NSDictionary).value(forKey: "address") as!  String
            var arr = str.components(separatedBy: " ")
            
            if arr.count>0 {
                
                //                var str_addrss = ""
                //                if  let check = arr[0] as? Int{
                //                    for i in 1..<arr.count{
                //                        str_addrss.append(arr[i])
                //                    }
                //                    lbl_address.text = str_addrss
                //
                //                }else
                //                {
                //                    lbl_address.text = (arr_search_spot.object(at: index) as! NSDictionary).value(forKey: "address") as?  String
                //
                //                }
                
                var str_addrss = ""
                let str = arr[0]
                let strInt = Int(str)
                if  strInt != nil{
                    
                    for i in 0..<arr.count{
                        if i == 0
                        {
                            if strInt != nil{
                                
                            }else
                            {
                                str_addrss.append("\(arr[i])" )
                            }
                            
                        }else{
                            if i == 1
                            {
                                if strInt != nil{
                                    str_addrss.append("\(arr[i])" )
                                }else
                                {
                                    str_addrss.append(" \(arr[i])" )
                                }
                            }else
                            {
                                str_addrss.append(" \(arr[i])" )
                            }
                        }
                    }
                    
                    lbl_address.text = str_addrss
                    
                }else
                {
                    lbl_address.text = (arr_search_spot.object(at: index) as! NSDictionary).value(forKey: "address") as?  String
                    
                }
                
            }
            
            
            let imgurl = (arr_search_spot.object(at: index) as! NSDictionary).value(forKey: "image") as!  String
            img_spot.sd_setImage(with: URL(string: imgurl), placeholderImage: #imageLiteral(resourceName: "Placeholder"))
            
            // specify which spot is highlighted
            // Should I do this asynchronously?
            self.highlightedSpot = Spot(address: ((arr_search_spot.object(at: index) as! NSDictionary).value(forKey: "address") as?  String) ?? "",
                                        town: (arr_search_spot.object(at: index) as! NSDictionary).value(forKey: "city") as?  String ?? "",
                                        state: (arr_search_spot.object(at: index) as! NSDictionary).value(forKey: "state") as?  String ?? "",
                                        zipCode: (arr_search_spot.object(at: index) as! NSDictionary).value(forKey: "zipcode") as?  String ?? "",
                                        spotImage: (arr_search_spot.object(at: index) as! NSDictionary).value(forKey: "image") as?  String ?? "",
                                        description: (arr_search_spot.object(at: index) as! NSDictionary).value(forKey: "description") as?  String ?? "",
                                        monStartTime: (arr_search_spot.object(at: index) as! NSDictionary).value(forKey: "monStartTime") as?  String ?? "",
                                        monEndTime: (arr_search_spot.object(at: index) as! NSDictionary).value(forKey: "monEndTime") as?  String ?? "",
                                        tueStartTime: (arr_search_spot.object(at: index) as! NSDictionary).value(forKey: "tueStartTime") as?  String ?? "",
                                        tueEndTime: (arr_search_spot.object(at: index) as! NSDictionary).value(forKey: "tueEndTime") as?  String ?? "",
                                        wedStartTime: (arr_search_spot.object(at: index) as! NSDictionary).value(forKey: "wedStartTime") as?  String ?? "",
                                        wedEndTime: (arr_search_spot.object(at: index) as! NSDictionary).value(forKey: "wedEndTime") as?  String ?? "",
                                        thuStartTime: (arr_search_spot.object(at: index) as! NSDictionary).value(forKey: "thuStartTime") as?  String ?? "",
                                        thuEndTime: (arr_search_spot.object(at: index) as! NSDictionary).value(forKey: "thuEndTime") as?  String ?? "",
                                        friStartTime: (arr_search_spot.object(at: index) as! NSDictionary).value(forKey: "friStartTime") as?  String ?? "",
                                        friEndTime: (arr_search_spot.object(at: index) as! NSDictionary).value(forKey: "friEndTime") as?  String ?? "",
                                        satStartTime: (arr_search_spot.object(at: index) as! NSDictionary).value(forKey: "satStartTime") as?  String ?? "",
                                        satEndTime: (arr_search_spot.object(at: index) as! NSDictionary).value(forKey: "satEndTime") as?  String ?? "",
                                        sunStartTime: (arr_search_spot.object(at: index) as! NSDictionary).value(forKey: "sunStartTime") as?  String ?? "",
                                        sunEndTime: (arr_search_spot.object(at: index) as! NSDictionary).value(forKey: "sunEndTime") as?  String ?? "",
                                        monOn: (arr_search_spot.object(at: index) as! NSDictionary).value(forKey: "monSwitch") as?  Bool ?? false,
                                        tueOn: (arr_search_spot.object(at: index) as! NSDictionary).value(forKey: "tueSwitch") as?  Bool ?? false,
                                        wedOn: (arr_search_spot.object(at: index) as! NSDictionary).value(forKey: "wedSwitch") as?  Bool ?? false,
                                        thuOn: (arr_search_spot.object(at: index) as! NSDictionary).value(forKey: "thuSwitch") as?  Bool ?? false,
                                        friOn: (arr_search_spot.object(at: index) as! NSDictionary).value(forKey: "friSwitch") as?  Bool ?? false,
                                        satOn: (arr_search_spot.object(at: index) as! NSDictionary).value(forKey: "satSwitch") as?  Bool ?? false,
                                        sunOn: (arr_search_spot.object(at: index) as! NSDictionary).value(forKey: "sunSwitch") as?  Bool ?? false,
                                        hourlyPricing: (arr_search_spot.object(at: index) as! NSDictionary).value(forKey: "hourlyPricing") as?  String ?? "",
                                        dailyPricing: (arr_search_spot.object(at: index) as! NSDictionary).value(forKey: "dailyPricing") as?  String ?? "",
                                        weeklyPricing: (arr_search_spot.object(at: index) as! NSDictionary).value(forKey: "weeklyPricing") as?  String ?? "",
                                        monthlyPricing: (arr_search_spot.object(at: index) as! NSDictionary).value(forKey: "monthlyPricing") as?  String ?? "",
                                        weeklyOn: (arr_search_spot.object(at: index) as! NSDictionary).value(forKey: "weeklyOn") as?  Bool ?? false,
                                        monthlyOn: (arr_search_spot.object(at: index) as! NSDictionary).value(forKey: "monthlyOn") as?  Bool ?? false,
                                        index: index,
                                        approved: true,
                                        spotImages: img_spot.image ?? UIImage(named: "white")!,
                                        spots_id: (arr_search_spot.object(at: index) as! NSDictionary).value(forKey: "id") as?  String ?? "",
                                        latitude: (arr_search_spot.object(at: index) as! NSDictionary).value(forKey: "latitude") as?  String ?? "",
                                        longitude: (arr_search_spot.object(at: index) as! NSDictionary).value(forKey: "longitude") as?  String ?? "",
                                        spottype: (arr_search_spot.object(at: index) as! NSDictionary).value(forKey: "spot_type") as?  String ?? "",
                                        owner_id: (arr_search_spot.object(at: index) as! NSDictionary).value(forKey: "owner_id") as?  String ?? "",
                                        Email: (arr_search_spot.object(at: index) as! NSDictionary).value(forKey: "Email") as?  String ?? "", baseprice: (arr_search_spot.object(at: index) as! NSDictionary).value(forKey: "basePricing") as?  String ?? "")
            
            // debug lines, can get rid of eventually
            print("Highlighted Spot Address is: \(self.highlightedSpot.address)")
            print("Highlighted Spot Email is: \(self.highlightedSpot.Email)")
            
        }else
        {
            let form = DateFormatter()
            // initially set the format based on your datepicker date / server String
            form.dateFormat = "yyyy-MM-dd HH:mm"
            let START = form.string(from: start_date!)
            print("start time :" + START)
            let END = form.string(from: end_date!)
            print("end time :" + END)
            let basePrice = ((self.arrspot.object(at: index) as! NSDictionary).value(forKey: "basePricing") as! String)
            let priceSPOT = Reservation.publicCalcPrice(startDateTimeString:START,endDateTimeString: END, basePrice: basePrice)
            let doller = Reservation.priceToString(price: priceSPOT)
            //print(time_Price)
            //            let numberOfPlaces = 2.0
            //            let multiplier = pow(10.0, numberOfPlaces)
            //            let doller = round(priceSPOT * multiplier) / multiplier
            
            //            let price  = (arrspot.object(at: index) as! NSDictionary).value(forKey: "hourlyPricing") as?  String
            //            let doller = (price! as NSString).integerValue
            view_info.isHidden = false
            btn_close.isHidden = false
            curruntlat = marker.position.latitude
            curruntlong = marker.position.longitude
            
            let formatter = DateFormatter(); formatter.dateFormat = "EEEE"
            let today =  formatter.string(from: Date())
            
            var time = ""
            
            if today == "Monday" {
                
                time = "\((arrspot.object(at: index) as! NSDictionary).value(forKey: "monStartTime") as!  String)-\((arrspot.object(at: index) as! NSDictionary).value(forKey: "monEndTime") as!  String)"
            }
            if today == "Tuesday" {
                
                time = "\((arrspot.object(at: index) as! NSDictionary).value(forKey: "tueStartTime") as!  String)-\((arrspot.object(at: index) as! NSDictionary).value(forKey: "tueEndTime") as!  String)"
            }
            if today == "Wednesday" {
                time = "\((arrspot.object(at: index) as! NSDictionary).value(forKey: "wedStartTime") as!  String)-\((arrspot.object(at: index) as! NSDictionary).value(forKey: "wedEndTime") as!  String)"
            }
            if today == "Thursday" {
                time = "\((arrspot.object(at: index) as! NSDictionary).value(forKey: "thuStartTime") as!  String)-\((arrspot.object(at: index) as! NSDictionary).value(forKey: "thuEndTime") as!  String)"
            }
            if today == "Friday" {
                time = "\((arrspot.object(at: index) as! NSDictionary).value(forKey: "friStartTime") as!  String)-\((arrspot.object(at: index) as! NSDictionary).value(forKey: "friEndTime") as!  String)"
            }
            if today == "Saturday" {
                time = "\((arrspot.object(at: index) as! NSDictionary).value(forKey: "satStartTime") as!  String)-\((arrspot.object(at: index) as! NSDictionary).value(forKey: "satEndTime") as!  String)"
            }
            if today == "Sunday" {
                time = "\((arrspot.object(at: index) as! NSDictionary).value(forKey: "sunStartTime") as!  String)-\((arrspot.object(at: index) as! NSDictionary).value(forKey: "sunEndTime") as!  String)"
            }
            
            lbl_spot_time.text = "Time: \(strPickerStart) to \(strPickerEnd)"
            
            //  lbl_spot_time.text = "Time: \(time)"
            
            if (arrspot.object(at: index) as! NSDictionary).value(forKey: "spot_type") as!  String == "Garage"{
                img_spot_type.image = UIImage(named:"garageParking")
            }
            if (arrspot.object(at: index) as! NSDictionary).value(forKey: "spot_type") as!  String == "Lot"{
                img_spot_type.image = UIImage(named:"lotParking")
            }
            if (arrspot.object(at: index) as! NSDictionary).value(forKey: "spot_type") as!  String == "Street"{
                img_spot_type.image = UIImage(named:"streetParking")
            }
            if (arrspot.object(at: index) as! NSDictionary).value(forKey: "spot_type") as!  String == "Driveway"{
                img_spot_type.image = UIImage(named:"drivewayParking")
            }
            
            lbl_spot_type.text = (arrspot.object(at: index) as! NSDictionary).value(forKey: "spot_type") as?  String
            //let intDist = Int(distanceInMeters)
            lbl_price.text = "$\(doller)"
            lbl_address.text = (arrspot.object(at: index) as! NSDictionary).value(forKey: "address") as?  String
            let str = (arrspot.object(at: index) as! NSDictionary).value(forKey: "address") as!  String
            var arr = str.components(separatedBy: " ")
            
            if arr.count>0 {
                
                var str_addrss = ""
                let str = arr[0]
                let strInt = Int(str)
                if  strInt != nil{
                    
                    for i in 0..<arr.count{
                        if i == 0
                        {
                            if strInt != nil{
                                
                            }else
                            {
                                str_addrss.append("\(arr[i])" )
                            }
                            
                        }else{
                            if i == 1
                            {
                                if strInt != nil{
                                    str_addrss.append("\(arr[i])" )
                                }else
                                {
                                    str_addrss.append(" \(arr[i])" )
                                }
                            }else
                            {
                                str_addrss.append(" \(arr[i])" )
                            }
                        }
                    }
                    
                    lbl_address.text = str_addrss
                    
                }else
                {
                    lbl_address.text = (arrspot.object(at: index) as! NSDictionary).value(forKey: "address") as?  String
                }
            }
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
        }
        
        return true
    }
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        fetchMapData(lat: markerlatitude, long: markerlongitude)
    }
    
    // GET ALL SPOT ON MAP
    func getlatlong(){
        
        print("We are loading spots...")
        
        //        Spinner.start()
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
            //self.CurrentLocMarker.title = "myLoc"
            var markerView = UIImageView()
            markerView = UIImageView(image: UIImage.init(named: "current_location_icon"))
            markerView.frame.size.width = 30
            markerView.frame.size.height = 30
            //            self.CurrentLocMarker.iconView = markerView
            //            self.CurrentLocMarker.map = self.mapView
            var spotStart_times = ""
            var spotEnd_times = ""
            let formatter = DateFormatter()
            // initially set the format based on your datepicker date / server String
            formatter.dateFormat = "yyyy-MM-dd"
            formatter.timeZone = TimeZone(abbreviation: "GMT+0:00")
            // let ddd = "2019-06-04"
            // let dd = formatter.date(from: ddd)
            // var str = formatter.string(from: self.start_datepic.date)
            var calcheck = Calendar.current
            calcheck.timeZone =  TimeZone(abbreviation: "GMT+0:00")!
            var str = formatter.string(from: Date())
            if snapshot.childrenCount > 0 {
                formatter.dateFormat = "yyyy-MM-dd HH:mm"
                
                self.arrspot.removeAllObjects()
                let arrCurrentRes = AppState.sharedInstance.user.myReservations
                for artists in snapshot.children.allObjects as! [DataSnapshot] {
                    let snapshotValue = snapshot.value as! NSDictionary
                    let dictdata = ((snapshot.value as! NSDictionary).value(forKey: (artists as! DataSnapshot).key)) as! NSDictionary
                    if dictdata.count>0
                    {
                        for (theKey, theValue) in dictdata {
                            //  print(theKey)
                            //  print(theValue)
                            self.arrAllspot.add(theValue)
                            // self.arrspot.add(theValue)
                            if dayInWeek == "Sunday"{
                                if (theValue as! NSDictionary).value(forKey: "sunswitch") as! Int  == 1
                                {
                                    let spotStart_times = "\(str) \((theValue as! NSDictionary).value(forKey: "sunStartTime") as! String)"
                                    let spotEnd_times = "\(str) \((theValue as! NSDictionary).value(forKey: "sunEndTime") as! String)"
                                    formatter.dateFormat = "yyyy-MM-dd h:mm a"
                                    let dateDay1 = formatter.date(from: spotStart_times)
                                    let dateDay2 = formatter.date(from: spotEnd_times)
                                    formatter.dateFormat = "MMM dd h a"
                                    let statCur = self.dateWithHour(hour:calcheck.component(.hour, from: self.start_date!), minute: 00, second: 00, date: self.start_date!)!
                                    let endCur = self.dateWithHour(hour:calcheck.component(.hour, from:self.end_date!), minute: 00, second: 00, date: self.end_date!)!
                                    let statCheck = self.dateWithHour(hour:22, minute: 00, second: 00, date: self.start_date!)!
                                    if statCheck.isSmallerThan(statCur) || statCheck == statCur
                                    {
                                        print("true")
                                        let spotStart_times = "\(str) \((theValue as! NSDictionary).value(forKey: "monStartTime") as! String)"
                                        let spotEnd_times = "\(str) \((theValue as! NSDictionary).value(forKey: "monEndTime") as! String)"
                                        formatter.dateFormat = "yyyy-MM-dd h:mm a"
                                        let dateeDay1 = formatter.date(from: spotStart_times)
                                        let dateeDay2 = formatter.date(from: spotEnd_times)
                                        formatter.dateFormat = "MMM dd h a"
                                        if dateeDay1 != nil || dateeDay2 != nil
                                        {
                                            
                                            if dateeDay1!.isSmallerThan(endCur) && dateeDay2!.isSmallerThan(endCur)
                                            {
                                                var isReservarion = false
                                                for dict in arrCurrentRes
                                                {
                                                    if (dict as! NSDictionary).value(forKey: "spotID") as! String == (theValue as! NSDictionary).value(forKey: "id") as! String
                                                    {
                                                        let date1 = (dict as! NSDictionary).value(forKey: "startDateTime") as! String
                                                        let date2 = (dict as! NSDictionary).value(forKey: "endDateTime") as! String
                                                        formatter.dateFormat = "yyyy-MM-dd HH:mm"
                                                        let date11 = formatter.date(from: date1)
                                                        let date22 = formatter.date(from: date2)
                                                        print(date1)
                                                        if date11!.isSmallerThan(statCur) && date22!.isGreaterThan(endCur)
                                                        {
                                                            isReservarion = true
                                                            break
                                                        }
                                                    }
                                                }
                                                if isReservarion == false{
                                                    self.arrspot.add(theValue)
                                                }
                                            }
                                        }
                                    }
                                    else
                                    {
                                        if dateDay1!.isSmallerThan(statCur) && dateDay2!.isGreaterThan(endCur){
                                            var isReservarion = false
                                            for dict in arrCurrentRes
                                            {
                                                if (dict as! NSDictionary).value(forKey: "spotID") as! String == (theValue as! NSDictionary).value(forKey: "id") as! String
                                                {
                                                    let date1 = (dict as! NSDictionary).value(forKey: "startDateTime") as! String
                                                    let date2 = (dict as! NSDictionary).value(forKey: "endDateTime") as! String
                                                    formatter.dateFormat = "yyyy-MM-dd HH:mm"
                                                    let date11 = formatter.date(from: date1)
                                                    let date22 = formatter.date(from: date2)
                                                    print(date1)
                                                    if date11!.isSmallerThan(statCur) && date22!.isGreaterThan(endCur)
                                                    {
                                                        isReservarion = true
                                                        break
                                                    }
                                                }
                                            }
                                            if isReservarion == false{
                                                self.arrspot.add(theValue)
                                            }
                                            //                                        if self.getReservationsOnDay(date: dateDay1!) == true
                                            //                                        {
                                            //                                            self.arrspot.add(theValue)
                                            //                                        }
                                        }
                                    }
                                    //                                    if dateDay1!.isSmallerThan(statCur) && dateDay2!.isGreaterThan(endCur){
                                    //                                        var isReservarion = false
                                    //                                        for dict in arrCurrentRes
                                    //                                        {
                                    //                                            if (dict as! NSDictionary).value(forKey: "spotID") as! String == (theValue as! NSDictionary).value(forKey: "id") as! String
                                    //                                            {
                                    //                                                let date1 = (dict as! NSDictionary).value(forKey: "startDateTime") as! String
                                    //                                                let date2 = (dict as! NSDictionary).value(forKey: "endDateTime") as! String
                                    //                                                formatter.dateFormat = "yyyy-MM-dd HH:mm"
                                    //                                                let date11 = formatter.date(from: date1)
                                    //                                                let date22 = formatter.date(from: date2)
                                    //                                                print(date1)
                                    //                                                if date11!.isSmallerThan(statCur) && date22!.isGreaterThan(endCur)
                                    //                                                {
                                    //                                                    isReservarion = true
                                    //                                                    break
                                    //                                                }
                                    //                                            }
                                    //                                        }
                                    //                                        if isReservarion == false{
                                    //                                            self.arrspot.add(theValue)
                                    //                                        }
                                    //                                    }
                                }
                            }
                            if dayInWeek == "Monday"{
                                if (theValue as! NSDictionary).value(forKey: "monswitch") as! Int  == 1
                                {
                                    let spotStart_times = "\(str) \((theValue as! NSDictionary).value(forKey: "monStartTime") as! String)"
                                    let spotEnd_times = "\(str) \((theValue as! NSDictionary).value(forKey: "monEndTime") as! String)"
                                    formatter.dateFormat = "yyyy-MM-dd h:mm a"
                                    let dateDay1 = formatter.date(from: spotStart_times)
                                    let dateDay2 = formatter.date(from: spotEnd_times)
                                    formatter.dateFormat = "MMM dd h a"
                                    
                                    let statCur = self.dateWithHour(hour:calcheck.component(.hour, from: self.start_date!), minute: 00, second: 00, date: self.start_date!)!
                                    let endCur = self.dateWithHour(hour:calcheck.component(.hour, from:self.end_date!), minute: 00, second: 00, date: self.end_date!)!
                                    print(dateDay1!)
                                    print(statCur)
                                    print(dateDay2!)
                                    print(endCur)
                                    
                                    let statCheck = self.dateWithHour(hour:22, minute: 00, second: 00, date: self.start_date!)!
                                    if statCheck.isSmallerThan(statCur) || statCheck == statCur
                                    {
                                        print("true")
                                        let spotStart_times = "\(str) \((theValue as! NSDictionary).value(forKey: "tueStartTime") as! String)"
                                        let spotEnd_times = "\(str) \((theValue as! NSDictionary).value(forKey: "tueEndTime") as! String)"
                                        formatter.dateFormat = "yyyy-MM-dd h:mm a"
                                        let dateeDay1 = formatter.date(from: spotStart_times)
                                        let dateeDay2 = formatter.date(from: spotEnd_times)
                                        formatter.dateFormat = "MMM dd h a"
                                        if dateeDay1 != nil || dateeDay2 != nil
                                        {
                                            
                                            if dateeDay1!.isSmallerThan(endCur) && dateeDay2!.isSmallerThan(endCur)
                                            {
                                                var isReservarion = false
                                                for dict in arrCurrentRes
                                                {
                                                    if (dict as! NSDictionary).value(forKey: "spotID") as! String == (theValue as! NSDictionary).value(forKey: "id") as! String
                                                    {
                                                        let date1 = (dict as! NSDictionary).value(forKey: "startDateTime") as! String
                                                        let date2 = (dict as! NSDictionary).value(forKey: "endDateTime") as! String
                                                        formatter.dateFormat = "yyyy-MM-dd HH:mm"
                                                        let date11 = formatter.date(from: date1)
                                                        let date22 = formatter.date(from: date2)
                                                        print(date1)
                                                        if date11!.isSmallerThan(statCur) && date22!.isGreaterThan(endCur)
                                                        {
                                                            isReservarion = true
                                                            break
                                                        }
                                                    }
                                                }
                                                if isReservarion == false{
                                                    self.arrspot.add(theValue)
                                                }
                                            }
                                        }
                                    }else
                                    {
                                        if dateDay1!.isSmallerThan(statCur) && dateDay2!.isGreaterThan(endCur){
                                            var isReservarion = false
                                            for dict in arrCurrentRes
                                            {
                                                if (dict as! NSDictionary).value(forKey: "spotID") as! String == (theValue as! NSDictionary).value(forKey: "id") as! String
                                                {
                                                    let date1 = (dict as! NSDictionary).value(forKey: "startDateTime") as! String
                                                    let date2 = (dict as! NSDictionary).value(forKey: "endDateTime") as! String
                                                    formatter.dateFormat = "yyyy-MM-dd HH:mm"
                                                    let date11 = formatter.date(from: date1)
                                                    let date22 = formatter.date(from: date2)
                                                    print(date1)
                                                    if date11!.isSmallerThan(statCur) && date22!.isGreaterThan(endCur)
                                                    {
                                                        isReservarion = true
                                                        break
                                                    }
                                                }
                                            }
                                            if isReservarion == false{
                                                self.arrspot.add(theValue)
                                            }
                                            //                                        if self.getReservationsOnDay(date: dateDay1!) == true
                                            //                                        {
                                            //                                            self.arrspot.add(theValue)
                                            //                                        }
                                        }
                                    }
                                }
                            }
                            if dayInWeek == "Tuesday"{
                                if (theValue as! NSDictionary).value(forKey: "tueswitch") as! Int  == 1
                                {
                                    let spotStart_times = "\(str) \((theValue as! NSDictionary).value(forKey: "tueStartTime") as! String)"
                                    let spotEnd_times = "\(str) \((theValue as! NSDictionary).value(forKey: "tueEndTime") as! String)"
                                    formatter.dateFormat = "yyyy-MM-dd h:mm a"
                                    let dateDay1 = formatter.date(from: spotStart_times)
                                    let dateDay2 = formatter.date(from: spotEnd_times)
                                    formatter.dateFormat = "MMM dd h a"
                                    let statCur = self.dateWithHour(hour:calcheck.component(.hour, from: self.start_date!), minute: 00, second: 00, date: self.start_date!)!
                                    let endCur = self.dateWithHour(hour:calcheck.component(.hour, from:self.end_date!), minute: 00, second: 00, date: self.end_date!)!
                                    let statCheck = self.dateWithHour(hour:22, minute: 00, second: 00, date: self.start_date!)!
                                    if statCheck.isSmallerThan(statCur) || statCheck == statCur
                                    {
                                        print("true")
                                        let spotStart_times = "\(str) \((theValue as! NSDictionary).value(forKey: "wedStartTime") as! String)"
                                        let spotEnd_times = "\(str) \((theValue as! NSDictionary).value(forKey: "wedEndTime") as! String)"
                                        formatter.dateFormat = "yyyy-MM-dd h:mm a"
                                        let dateeDay1 = formatter.date(from: spotStart_times)
                                        let dateeDay2 = formatter.date(from: spotEnd_times)
                                        formatter.dateFormat = "MMM dd h a"
                                        if dateeDay1 != nil || dateeDay2 != nil
                                        {
                                            
                                            if dateeDay1!.isSmallerThan(endCur) && dateeDay2!.isSmallerThan(endCur)
                                            {
                                                var isReservarion = false
                                                for dict in arrCurrentRes
                                                {
                                                    if (dict as! NSDictionary).value(forKey: "spotID") as! String == (theValue as! NSDictionary).value(forKey: "id") as! String
                                                    {
                                                        let date1 = (dict as! NSDictionary).value(forKey: "startDateTime") as! String
                                                        let date2 = (dict as! NSDictionary).value(forKey: "endDateTime") as! String
                                                        formatter.dateFormat = "yyyy-MM-dd HH:mm"
                                                        let date11 = formatter.date(from: date1)
                                                        let date22 = formatter.date(from: date2)
                                                        print(date1)
                                                        if date11!.isSmallerThan(statCur) && date22!.isGreaterThan(endCur)
                                                        {
                                                            isReservarion = true
                                                            break
                                                        }
                                                    }
                                                }
                                                if isReservarion == false{
                                                    self.arrspot.add(theValue)
                                                }
                                            }
                                        }
                                    }else
                                    {
                                        if dateDay1!.isSmallerThan(statCur) && dateDay2!.isGreaterThan(endCur){
                                            var isReservarion = false
                                            for dict in arrCurrentRes
                                            {
                                                if (dict as! NSDictionary).value(forKey: "spotID") as! String == (theValue as! NSDictionary).value(forKey: "id") as! String
                                                {
                                                    let date1 = (dict as! NSDictionary).value(forKey: "startDateTime") as! String
                                                    let date2 = (dict as! NSDictionary).value(forKey: "endDateTime") as! String
                                                    formatter.dateFormat = "yyyy-MM-dd HH:mm"
                                                    let date11 = formatter.date(from: date1)
                                                    let date22 = formatter.date(from: date2)
                                                    print(date1)
                                                    if date11!.isSmallerThan(statCur) && date22!.isGreaterThan(endCur)
                                                    {
                                                        isReservarion = true
                                                        break
                                                    }
                                                }
                                            }
                                            if isReservarion == false{
                                                self.arrspot.add(theValue)
                                            }
                                            //                                        if self.getReservationsOnDay(date: dateDay1!) == true
                                            //                                        {
                                            //                                            self.arrspot.add(theValue)
                                            //                                        }
                                        }
                                    }
                                    
                                    //                                    if dateDay1!.isSmallerThan(statCur) && dateDay2!.isGreaterThan(endCur){
                                    //                                        var isReservarion = false
                                    //                                        for dict in arrCurrentRes
                                    //                                        {
                                    //                                            if (dict as! NSDictionary).value(forKey: "spotID") as! String == (theValue as! NSDictionary).value(forKey: "id") as! String
                                    //                                            {
                                    //                                                let date1 = (dict as! NSDictionary).value(forKey: "startDateTime") as! String
                                    //                                                let date2 = (dict as! NSDictionary).value(forKey: "endDateTime") as! String
                                    //                                                formatter.dateFormat = "yyyy-MM-dd HH:mm"
                                    //                                                let date11 = formatter.date(from: date1)
                                    //                                                let date22 = formatter.date(from: date2)
                                    //                                                print(date1)
                                    //                                                if date11!.isSmallerThan(statCur) && date22!.isGreaterThan(endCur)
                                    //                                                {
                                    //                                                    isReservarion = true
                                    //                                                    break
                                    //                                                }
                                    //                                            }
                                    //                                        }
                                    //                                        if isReservarion == false{
                                    //                                            self.arrspot.add(theValue)
                                    //                                        }
                                    //                                    }
                                }
                            }
                            if dayInWeek == "Wednesday"{
                                
                                if (theValue as! NSDictionary).value(forKey: "wedswitch") as! Int  == 1
                                {
                                    let spotStart_times = "\(str) \((theValue as! NSDictionary).value(forKey: "wedStartTime") as! String)"
                                    let spotEnd_times = "\(str) \((theValue as! NSDictionary).value(forKey: "wedEndTime") as! String)"
                                    formatter.dateFormat = "yyyy-MM-dd h:mm a"
                                    let dateDay1 = formatter.date(from: spotStart_times)
                                    let dateDay2 = formatter.date(from: spotEnd_times)
                                    formatter.dateFormat = "MMM dd h a"
                                    let statCur = self.dateWithHour(hour:calcheck.component(.hour, from: self.start_date!), minute: 00, second: 00, date: self.start_date!)!
                                    let endCur = self.dateWithHour(hour:calcheck.component(.hour, from:self.end_date!), minute: 00, second: 00, date: self.end_date!)!
                                    let statCheck = self.dateWithHour(hour:22, minute: 00, second: 00, date: self.start_date!)!
                                    if statCheck.isSmallerThan(statCur) || statCheck == statCur
                                    {
                                        print("true")
                                        let spotStart_times = "\(str) \((theValue as! NSDictionary).value(forKey: "thuStartTime") as! String)"
                                        let spotEnd_times = "\(str) \((theValue as! NSDictionary).value(forKey: "thuEndTime") as! String)"
                                        formatter.dateFormat = "yyyy-MM-dd h:mm a"
                                        let dateeDay1 = formatter.date(from: spotStart_times)
                                        let dateeDay2 = formatter.date(from: spotEnd_times)
                                        formatter.dateFormat = "MMM dd h a"
                                        if dateeDay1 != nil || dateeDay2 != nil
                                        {
                                            
                                            if dateeDay1!.isSmallerThan(endCur) && dateeDay2!.isSmallerThan(endCur)
                                            {
                                                var isReservarion = false
                                                for dict in arrCurrentRes
                                                {
                                                    if (dict as! NSDictionary).value(forKey: "spotID") as! String == (theValue as! NSDictionary).value(forKey: "id") as! String
                                                    {
                                                        let date1 = (dict as! NSDictionary).value(forKey: "startDateTime") as! String
                                                        let date2 = (dict as! NSDictionary).value(forKey: "endDateTime") as! String
                                                        formatter.dateFormat = "yyyy-MM-dd HH:mm"
                                                        let date11 = formatter.date(from: date1)
                                                        let date22 = formatter.date(from: date2)
                                                        print(date1)
                                                        if date11!.isSmallerThan(statCur) && date22!.isGreaterThan(endCur)
                                                        {
                                                            isReservarion = true
                                                            break
                                                        }
                                                    }
                                                }
                                                if isReservarion == false{
                                                    self.arrspot.add(theValue)
                                                }
                                            }
                                        }
                                    }else
                                    {
                                        if dateDay1!.isSmallerThan(statCur) && dateDay2!.isGreaterThan(endCur){
                                            var isReservarion = false
                                            for dict in arrCurrentRes
                                            {
                                                if (dict as! NSDictionary).value(forKey: "spotID") as! String == (theValue as! NSDictionary).value(forKey: "id") as! String
                                                {
                                                    let date1 = (dict as! NSDictionary).value(forKey: "startDateTime") as! String
                                                    let date2 = (dict as! NSDictionary).value(forKey: "endDateTime") as! String
                                                    formatter.dateFormat = "yyyy-MM-dd HH:mm"
                                                    let date11 = formatter.date(from: date1)
                                                    let date22 = formatter.date(from: date2)
                                                    print(date1)
                                                    if date11!.isSmallerThan(statCur) && date22!.isGreaterThan(endCur)
                                                    {
                                                        isReservarion = true
                                                        break
                                                    }
                                                }
                                            }
                                            if isReservarion == false{
                                                self.arrspot.add(theValue)
                                            }
                                        }
                                    }
                                    
                                    //                                    if dateDay1!.isSmallerThan(statCur) && dateDay2!.isGreaterThan(endCur){
                                    //                                        var isReservarion = false
                                    //                                         for dict in arrCurrentRes
                                    //                                         {
                                    //
                                    //                                            if (dict as! NSDictionary).value(forKey: "spotID") as! String == (theValue as! NSDictionary).value(forKey: "id") as! String
                                    //                                            {
                                    //
                                    //                                                let date1 = (dict as! NSDictionary).value(forKey: "startDateTime") as! String
                                    //                                                let date2 = (dict as! NSDictionary).value(forKey: "endDateTime") as! String
                                    //                                                formatter.dateFormat = "yyyy-MM-dd HH:mm"
                                    //                                                let date11 = formatter.date(from: date1)
                                    //                                                let date22 = formatter.date(from: date2)
                                    //                                                print(date1)
                                    //                                                if date11!.isSmallerThan(statCur) && date22!.isGreaterThan(endCur)
                                    //                                                {
                                    //                                                    isReservarion = true
                                    //                                                    break
                                    //                                                }
                                    //                                            }
                                    //                                         }
                                    //                                        if isReservarion == false{
                                    //                                            self.arrspot.add(theValue)
                                    //                                        }
                                    //                                    }
                                }
                            }
                            if dayInWeek == "Thursday"{
                                if (theValue as! NSDictionary).value(forKey: "thuswitch") as! Int  == 1
                                {
                                    let spotStart_times = "\(str) \((theValue as! NSDictionary).value(forKey: "thuStartTime") as! String)"
                                    let spotEnd_times = "\(str) \((theValue as! NSDictionary).value(forKey: "thuEndTime") as! String)"
                                    formatter.dateFormat = "yyyy-MM-dd h:mm a"
                                    let dateDay1 = formatter.date(from: spotStart_times)
                                    let dateDay2 = formatter.date(from: spotEnd_times)
                                    formatter.dateFormat = "MMM dd h a"
                                    let statCur = self.dateWithHour(hour:calcheck.component(.hour, from: self.start_date!), minute: 00, second: 00, date: self.start_date!)!
                                    let endCur = self.dateWithHour(hour:calcheck.component(.hour, from:self.end_date!), minute: 00, second: 00, date: self.end_date!)!
                                    let statCheck = self.dateWithHour(hour:22, minute: 00, second: 00, date: self.start_date!)!
                                    if statCheck.isSmallerThan(statCur) || statCheck == statCur
                                    {
                                        print("true")
                                        let spotStart_times = "\(str) \((theValue as! NSDictionary).value(forKey: "friStartTime") as! String)"
                                        let spotEnd_times = "\(str) \((theValue as! NSDictionary).value(forKey: "friEndTime") as! String)"
                                        formatter.dateFormat = "yyyy-MM-dd h:mm a"
                                        let dateeDay1 = formatter.date(from: spotStart_times)
                                        let dateeDay2 = formatter.date(from: spotEnd_times)
                                        formatter.dateFormat = "MMM dd h a"
                                        if dateeDay1 != nil || dateeDay2 != nil
                                        {
                                            
                                            if dateeDay1!.isSmallerThan(endCur) && dateeDay2!.isSmallerThan(endCur)
                                            {
                                                var isReservarion = false
                                                for dict in arrCurrentRes
                                                {
                                                    if (dict as! NSDictionary).value(forKey: "spotID") as! String == (theValue as! NSDictionary).value(forKey: "id") as! String
                                                    {
                                                        let date1 = (dict as! NSDictionary).value(forKey: "startDateTime") as! String
                                                        let date2 = (dict as! NSDictionary).value(forKey: "endDateTime") as! String
                                                        formatter.dateFormat = "yyyy-MM-dd HH:mm"
                                                        let date11 = formatter.date(from: date1)
                                                        let date22 = formatter.date(from: date2)
                                                        print(date1)
                                                        if date11!.isSmallerThan(statCur) && date22!.isGreaterThan(endCur)
                                                        {
                                                            isReservarion = true
                                                            break
                                                        }
                                                    }
                                                }
                                                if isReservarion == false{
                                                    self.arrspot.add(theValue)
                                                }
                                            }
                                        }
                                    }else
                                    {
                                        if dateDay1!.isSmallerThan(statCur) && dateDay2!.isGreaterThan(endCur){
                                            var isReservarion = false
                                            for dict in arrCurrentRes
                                            {
                                                if (dict as! NSDictionary).value(forKey: "spotID") as! String == (theValue as! NSDictionary).value(forKey: "id") as! String
                                                {
                                                    let date1 = (dict as! NSDictionary).value(forKey: "startDateTime") as! String
                                                    let date2 = (dict as! NSDictionary).value(forKey: "endDateTime") as! String
                                                    formatter.dateFormat = "yyyy-MM-dd HH:mm"
                                                    let date11 = formatter.date(from: date1)
                                                    let date22 = formatter.date(from: date2)
                                                    print(date1)
                                                    if date11!.isSmallerThan(statCur) && date22!.isGreaterThan(endCur)
                                                    {
                                                        isReservarion = true
                                                        break
                                                    }
                                                }
                                            }
                                            if isReservarion == false{
                                                self.arrspot.add(theValue)
                                            }
                                        }
                                    }
                                    
                                    //                                    if dateDay1!.isSmallerThan(statCur) && dateDay2!.isGreaterThan(endCur){
                                    //                                        var isReservarion = false
                                    //                                        for dict in arrCurrentRes
                                    //                                        {
                                    //                                            if (dict as! NSDictionary).value(forKey: "spotID") as! String == (theValue as! NSDictionary).value(forKey: "id") as! String
                                    //                                            {
                                    //                                                let date1 = (dict as! NSDictionary).value(forKey: "startDateTime") as! String
                                    //                                                let date2 = (dict as! NSDictionary).value(forKey: "endDateTime") as! String
                                    //                                                formatter.dateFormat = "yyyy-MM-dd HH:mm"
                                    //                                                let date11 = formatter.date(from: date1)
                                    //                                                let date22 = formatter.date(from: date2)
                                    //                                                print(date1)
                                    //
                                    //                                                    if date11!.isSmallerThan(statCur) && date22!.isGreaterThan(endCur)
                                    //                                                    {
                                    //                                                        isReservarion = true
                                    //                                                        break
                                    //                                                    }
                                    //                                            }
                                    //                                        }
                                    //                                        if isReservarion == false{
                                    //                                            self.arrspot.add(theValue)
                                    //                                        }
                                    //
                                    //                                    }
                                }
                            }
                            if dayInWeek == "Friday"{
                                if (theValue as! NSDictionary).value(forKey: "friswitch") as! Int  == 1
                                {
                                    let spotStart_times = "\(str) \((theValue as! NSDictionary).value(forKey: "friStartTime") as! String)"
                                    let spotEnd_times = "\(str) \((theValue as! NSDictionary).value(forKey: "friEndTime") as! String)"
                                    formatter.dateFormat = "yyyy-MM-dd h:mm a"
                                    let dateDay1 = formatter.date(from: spotStart_times)
                                    let dateDay2 = formatter.date(from: spotEnd_times)
                                    formatter.dateFormat = "MMM dd h a"
                                    let statCur = self.dateWithHour(hour:calcheck.component(.hour, from: self.start_date!), minute: 00, second: 00, date: self.start_date!)!
                                    let endCur = self.dateWithHour(hour:calcheck.component(.hour, from:self.end_date!), minute: 00, second: 00, date: self.end_date!)!
                                    let statCheck = self.dateWithHour(hour:22, minute: 00, second: 00, date: self.start_date!)!
                                    if statCheck.isSmallerThan(statCur) || statCheck == statCur
                                    {
                                        print("true")
                                        let spotStart_times = "\(str) \((theValue as! NSDictionary).value(forKey: "satStartTime") as! String)"
                                        let spotEnd_times = "\(str) \((theValue as! NSDictionary).value(forKey: "satEndTime") as! String)"
                                        formatter.dateFormat = "yyyy-MM-dd h:mm a"
                                        let dateeDay1 = formatter.date(from: spotStart_times)
                                        let dateeDay2 = formatter.date(from: spotEnd_times)
                                        formatter.dateFormat = "MMM dd h a"
                                        if dateeDay1 != nil || dateeDay2 != nil
                                        {
                                            
                                            if dateeDay1!.isSmallerThan(endCur) && dateeDay2!.isSmallerThan(endCur)
                                            {
                                                var isReservarion = false
                                                for dict in arrCurrentRes
                                                {
                                                    if (dict as! NSDictionary).value(forKey: "spotID") as! String == (theValue as! NSDictionary).value(forKey: "id") as! String
                                                    {
                                                        let date1 = (dict as! NSDictionary).value(forKey: "startDateTime") as! String
                                                        let date2 = (dict as! NSDictionary).value(forKey: "endDateTime") as! String
                                                        formatter.dateFormat = "yyyy-MM-dd HH:mm"
                                                        let date11 = formatter.date(from: date1)
                                                        let date22 = formatter.date(from: date2)
                                                        print(date1)
                                                        if date11!.isSmallerThan(statCur) && date22!.isGreaterThan(endCur)
                                                        {
                                                            isReservarion = true
                                                            break
                                                        }
                                                    }
                                                }
                                                if isReservarion == false{
                                                    self.arrspot.add(theValue)
                                                }
                                            }
                                        }
                                    }else
                                    {
                                        if dateDay1!.isSmallerThan(statCur) && dateDay2!.isGreaterThan(endCur){
                                            var isReservarion = false
                                            for dict in arrCurrentRes
                                            {
                                                if (dict as! NSDictionary).value(forKey: "spotID") as! String == (theValue as! NSDictionary).value(forKey: "id") as! String
                                                {
                                                    let date1 = (dict as! NSDictionary).value(forKey: "startDateTime") as! String
                                                    let date2 = (dict as! NSDictionary).value(forKey: "endDateTime") as! String
                                                    formatter.dateFormat = "yyyy-MM-dd HH:mm"
                                                    let date11 = formatter.date(from: date1)
                                                    let date22 = formatter.date(from: date2)
                                                    print(date1)
                                                    if date11!.isSmallerThan(statCur) && date22!.isGreaterThan(endCur)
                                                    {
                                                        isReservarion = true
                                                        break
                                                    }
                                                }
                                            }
                                            if isReservarion == false{
                                                self.arrspot.add(theValue)
                                            }
                                        }
                                    }
                                    //                                    if dateDay1!.isSmallerThan(statCur) && dateDay2!.isGreaterThan(endCur){
                                    //                                        var isReservarion = false
                                    //                                        for dict in arrCurrentRes
                                    //                                        {
                                    //                                            if (dict as! NSDictionary).value(forKey: "spotID") as! String == (theValue as! NSDictionary).value(forKey: "id") as! String
                                    //                                            {
                                    //                                                let date1 = (dict as! NSDictionary).value(forKey: "startDateTime") as! String
                                    //                                                let date2 = (dict as! NSDictionary).value(forKey: "endDateTime") as! String
                                    //                                                formatter.dateFormat = "yyyy-MM-dd HH:mm"
                                    //                                                let date11 = formatter.date(from: date1)
                                    //                                                let date22 = formatter.date(from: date2)
                                    //                                                print(date1)
                                    //                                                if date11!.isSmallerThan(statCur) && date22!.isGreaterThan(endCur)
                                    //                                                {
                                    //                                                    isReservarion = true
                                    //                                                    break
                                    //                                                }
                                    //                                            }
                                    //                                        }
                                    //                                        if isReservarion == false{
                                    //                                            self.arrspot.add(theValue)
                                    //                                        }
                                    //                                        //                                        if self.getReservationsOnDay(date: dateDay1!) == true
                                    //                                        //                                        {
                                    //                                        //                                            self.arrspot.add(theValue)
                                    //                                        //                                        }
                                    //                                    }
                                }
                            }
                            if dayInWeek == "Saturday"{
                                if (theValue as! NSDictionary).value(forKey: "satswitch") as! Int  == 1
                                {
                                    let spotStart_times = "\(str) \((theValue as! NSDictionary).value(forKey: "satStartTime") as! String)"
                                    let spotEnd_times = "\(str) \((theValue as! NSDictionary).value(forKey: "satEndTime") as! String)"
                                    formatter.dateFormat = "yyyy-MM-dd h:mm a"
                                    let dateDay1 = formatter.date(from: spotStart_times)
                                    let dateDay2 = formatter.date(from: spotEnd_times)
                                    formatter.dateFormat = "MMM dd h a"
                                    let statCur = self.dateWithHour(hour:calcheck.component(.hour, from: self.start_date!), minute: 00, second: 00, date: self.start_date!)!
                                    let endCur = self.dateWithHour(hour:calcheck.component(.hour, from:self.end_date!), minute: 00, second: 00, date: self.end_date!)!
                                    let statCheck = self.dateWithHour(hour:22, minute: 00, second: 00, date: self.start_date!)!
                                    if statCheck.isSmallerThan(statCur) || statCheck == statCur
                                    {
                                        print("true")
                                        let spotStart_times = "\(str) \((theValue as! NSDictionary).value(forKey: "sunStartTime") as! String)"
                                        let spotEnd_times = "\(str) \((theValue as! NSDictionary).value(forKey: "sunEndTime") as! String)"
                                        formatter.dateFormat = "yyyy-MM-dd h:mm a"
                                        let dateeDay1 = formatter.date(from: spotStart_times)
                                        let dateeDay2 = formatter.date(from: spotEnd_times)
                                        formatter.dateFormat = "MMM dd h a"
                                        if dateeDay1 != nil || dateeDay2 != nil
                                        {
                                            
                                            if dateeDay1!.isSmallerThan(endCur) && dateeDay2!.isSmallerThan(endCur)
                                            {
                                                var isReservarion = false
                                                for dict in arrCurrentRes
                                                {
                                                    if (dict as! NSDictionary).value(forKey: "spotID") as! String == (theValue as! NSDictionary).value(forKey: "id") as! String
                                                    {
                                                        let date1 = (dict as! NSDictionary).value(forKey: "startDateTime") as! String
                                                        let date2 = (dict as! NSDictionary).value(forKey: "endDateTime") as! String
                                                        formatter.dateFormat = "yyyy-MM-dd HH:mm"
                                                        let date11 = formatter.date(from: date1)
                                                        let date22 = formatter.date(from: date2)
                                                        print(date1)
                                                        if date11!.isSmallerThan(statCur) && date22!.isGreaterThan(endCur)
                                                        {
                                                            isReservarion = true
                                                            break
                                                        }
                                                    }
                                                }
                                                if isReservarion == false{
                                                    self.arrspot.add(theValue)
                                                }
                                            }
                                        }
                                    }else
                                    {
                                        if dateDay1!.isSmallerThan(statCur) && dateDay2!.isGreaterThan(endCur){
                                            var isReservarion = false
                                            for dict in arrCurrentRes
                                            {
                                                if (dict as! NSDictionary).value(forKey: "spotID") as! String == (theValue as! NSDictionary).value(forKey: "id") as! String
                                                {
                                                    let date1 = (dict as! NSDictionary).value(forKey: "startDateTime") as! String
                                                    let date2 = (dict as! NSDictionary).value(forKey: "endDateTime") as! String
                                                    formatter.dateFormat = "yyyy-MM-dd HH:mm"
                                                    let date11 = formatter.date(from: date1)
                                                    let date22 = formatter.date(from: date2)
                                                    print(date1)
                                                    if date11!.isSmallerThan(statCur) && date22!.isGreaterThan(endCur)
                                                    {
                                                        isReservarion = true
                                                        break
                                                    }
                                                }
                                            }
                                            if isReservarion == false{
                                                self.arrspot.add(theValue)
                                            }
                                        }
                                    }
                                    
                                    //                                    if dateDay1!.isSmallerThan(statCur) && dateDay2!.isGreaterThan(endCur){
                                    //                                        var isReservarion = false
                                    //                                        for dict in arrCurrentRes
                                    //                                        {
                                    //                                            if (dict as! NSDictionary).value(forKey: "spotID") as! String == (theValue as! NSDictionary).value(forKey: "id") as! String
                                    //                                            {
                                    //                                                let date1 = (dict as! NSDictionary).value(forKey: "startDateTime") as! String
                                    //                                                let date2 = (dict as! NSDictionary).value(forKey: "endDateTime") as! String
                                    //                                                formatter.dateFormat = "yyyy-MM-dd HH:mm"
                                    //                                                let date11 = formatter.date(from: date1)
                                    //                                                let date22 = formatter.date(from: date2)
                                    //                                                print(date1)
                                    //                                                if date11!.isSmallerThan(statCur) && date22!.isGreaterThan(endCur)
                                    //                                                {
                                    //                                                    isReservarion = true
                                    //                                                    break
                                    //                                                }
                                    //                                            }
                                    //                                        }
                                    //                                        if isReservarion == false{
                                    //                                            self.arrspot.add(theValue)
                                    //                                        }
                                    //                                    }
                                }
                            }
                        }
                        //self.loadEventsToMap(lat: self.userlatitude, long: self.userlongitude)
                    }
                }
                
                var spot_array:NSMutableArray = NSMutableArray()
                self.allMarkers.removeAll()
                if self.arrspot.count > 0 {
                    
                    for tag in 0 ..< self.arrspot.count {
                        //                        if dayInWeek == "Sunday"{
                        //                            if (self.arrspot[tag] as! NSDictionary).value(forKey: "sunswitch") as! Int  == 0
                        //                            {
                        //                                return
                        //                            }
                        //                        }
                        //                        if dayInWeek == "Monday"{
                        //                            if (self.arrspot[tag] as! NSDictionary).value(forKey: "monswitch") as! Int  == 0
                        //                            {
                        //                                return
                        //
                        //                            }
                        //
                        //                        }
                        //                        if dayInWeek == "Tuesday"{
                        //                            if (self.arrspot[tag] as! NSDictionary).value(forKey: "thuswitch") as! Int  == 0
                        //                            {
                        //                                    return
                        //                            }
                        //                        }
                        //                        if dayInWeek == "Wednesday"{
                        //                            if (self.arrspot[tag] as! NSDictionary).value(forKey: "wedswitch") as! Int  == 0
                        //                            {
                        //                                return
                        //                            }
                        //
                        //                        }
                        //                        if dayInWeek == "Thursday"{
                        //
                        //                            if (self.arrspot[tag] as! NSDictionary).value(forKey: "thuswitch") as! Int  == 0
                        //                            {
                        //                                return
                        //                            }
                        //                        }
                        //                        if dayInWeek == "Friday"{
                        //                            if (self.arrspot[tag] as! NSDictionary).value(forKey: "friswitch") as! Int  == 0
                        //                            {
                        //                                return
                        //                            }
                        //                        }
                        //                        if dayInWeek == "Saturday"{
                        //                            if (self.arrspot[tag] as! NSDictionary).value(forKey: "satswitch") as! Int  == 0
                        //                            {
                        //                                return
                        //                            }
                        //                        }
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
                        lbl_marker.frame = CGRect(x: 10, y: (markerimg.frame.height/2)-25, width: markerimg.frame.width-20, height: 40)
                        //lbl_marker.backgroundColor = UIColor.red
                        markerimg.addSubview(lbl_marker)
                        
                        lbl_marker.textAlignment = .center
                        lbl_marker.numberOfLines = 1;
                        // lbl_marker.text = "$\(doller)"
                        lbl_marker.minimumScaleFactor = 0.5;
                        lbl_marker.adjustsFontSizeToFitWidth = true;
                        lbl_marker.textColor = UIColor.black
                        customView.backgroundColor = UIColor.clear
                        
                        let formatter = DateFormatter()
                        formatter.dateFormat = "yyyy-MM-dd HH:mm"
                        let START = formatter.string(from: self.start_date!)
                        print("start time :" + START)
                        let END = formatter.string(from: self.end_date!)
                        print("end time :" + END)
                        //print(END)
                        let basePrice = (self.arrspot.object(at: tag) as! NSDictionary).value(forKey: "basePricing") as! String
                        let priceSPOT = Reservation.publicCalcPrice(startDateTimeString:START,endDateTimeString: END, basePrice: basePrice)
                        //    print(time_Price)
                        let dollerr = Reservation.priceToString(price: priceSPOT)
                        //                        let numberOfPlaces = 2.0
                        //                        let multiplier = pow(10.0, numberOfPlaces)
                        //                        let rounded = round(priceSPOT * multiplier) / multiplier
                        lbl_marker.text = "$\(dollerr)"
                        marker.iconView = customView
                        self.allMarkers.append(marker)
                    }
                    Spinner.stop()
                }
            }
            else{
                Spinner.stop()
            }
        })
        // need to get rid of this line...
        //        Spinner.stop()
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
        lbl_marker.frame = CGRect(x: 10, y: (markerimg.frame.height/2)-25, width: markerimg.frame.width-20, height: 40)
        markerimg.addSubview(lbl_marker)
        //lbl_marker.backgroundColor = UIColor.red
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
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        Time_price = false
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
            //            if distacneinKM < 5 {
            //                print("dicstance ------<5 = \(distacneinKM)")
            //                print(five)
            //                five = five+1
            //  if five < 5 {
            
            let marker = GMSMarker()
            //
            //                    let lat1 = (self.arrspot.object(at: i) as! NSDictionary).value(forKey: "user_lat") as! String
            //                    let long1 = (self.arrspot.object(at: i) as! NSDictionary).value(forKey: "user_long") as! String
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
            lbl_marker.frame = CGRect(x: 10, y: (markerimg.frame.height/2)-25, width: markerimg.frame.width-20, height: 40)
            markerimg.addSubview(lbl_marker)
            //lbl_marker.backgroundColor = UIColor.red
            lbl_marker.textAlignment = .center
            lbl_marker.numberOfLines = 1;
            
            let START = formatter.string(from: self.start_date!)
            print("start time :" + START)
            let END = formatter.string(from: self.end_date!)
            print("end time :" + END)
            //print(END)
            let basePrice = (self.arrspot.object(at:i) as! NSDictionary).value(forKey: "basePricing") as! String
            let priceSPOT = Reservation.publicCalcPrice(startDateTimeString:START,endDateTimeString: END, basePrice: basePrice)
            //    print(time_Price)
            let dollerr = Reservation.priceToString(price: priceSPOT)
            //                        let numberOfPlaces = 2.0
            //                        let multiplier = pow(10.0, numberOfPlaces)
            //                        let rounded = round(priceSPOT * multiplier) / multiplier
            lbl_marker.text = "$\(dollerr)"
            
            // lbl_marker.text = "$\(doller)"
            lbl_marker.minimumScaleFactor = 0.5;
            lbl_marker.adjustsFontSizeToFitWidth = true;
            lbl_marker.textColor = UIColor.black
            customView.backgroundColor = UIColor.clear
            marker.iconView = customView
            //   }
            //  Spinner.stop()
            //            }
            //            else{
            //                //    Spinner.stop()
            //
            //            }
        }
        Spinner.stop()
    }
    
    // Search Filter Spot -
    func Search_Spot() {
        
        if arr_search_spot.count > 0
        {
            mapView.clear()
            self.CurrentLocMarker.position = self.cooridnates
            //   self.CurrentLocMarker.title = "myLoc"
            var markerView = UIImageView()
            markerView = UIImageView(image: UIImage.init(named: "current_location_icon"))
            markerView.frame.size.width = 30
            markerView.frame.size.height = 30
            //            self.CurrentLocMarker.iconView = markerView
            //            self.CurrentLocMarker.map = self.mapView
            self.allMarkers.removeAll()
            for i in 0..<self.arr_search_spot.count
            {
                let marker = GMSMarker()
                let lat1 = (self.arr_search_spot.object(at: i) as! NSDictionary).value(forKey: "user_lat") as! String
                let long1 = (self.arr_search_spot.object(at: i) as! NSDictionary).value(forKey: "user_long") as! String
                let lat = (lat1 as NSString).doubleValue
                let long = (long1 as NSString).doubleValue
                self.allMarkers.append(marker)
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
                lbl_marker.frame = CGRect(x: 10, y: (markerimg.frame.height/2)-25, width: markerimg.frame.width-20, height: 40)
                markerimg.addSubview(lbl_marker)
                //lbl_marker.backgroundColor = UIColor.red
                lbl_marker.textAlignment = .center
                lbl_marker.adjustsFontSizeToFitWidth = true
                lbl_marker.numberOfLines = 1;
                lbl_marker.minimumScaleFactor = 0.5;
                lbl_marker.adjustsFontSizeToFitWidth = true;
                
                if Time_price == true {
                    var spotStart_times = ""
                    var spotEnd_times = ""
                    let dateformats = DateFormatter()
                    dateformats.timeZone = TimeZone.current
                    dateformats.dateFormat  = "EEEE"
                    let dayInWeek = dateformats.string(from: Date())
                    print(dayInWeek)
                    let basePrice = ((self.arr_search_spot.object(at: i) as! NSDictionary).value(forKey: "basePricing") as! String)
                    
                    print(start_date)
                    
                    let formatter = DateFormatter()
                    // initially set the format based on your datepicker date / server String
                    formatter.dateFormat = "yyyy-MM-dd "
                    
                    
                    var str = formatter.string(from: start_date!)
                    print(str)
                    
                    
                    if dayInWeek == "Sunday"{
                        spotStart_times = "\(str)\((self.arr_search_spot.object(at: i) as! NSDictionary).value(forKey: "sunStartTime") as! String)"
                        spotEnd_times = "\(str)\((self.arr_search_spot.object(at: i) as! NSDictionary).value(forKey: "satEndTime") as! String)"
                        
                    }
                    if dayInWeek == "Monday"{
                        spotStart_times = "\(str)\((self.arr_search_spot.object(at: i) as! NSDictionary).value(forKey: "monStartTime") as! String)"
                        spotEnd_times = "\(str)\((self.arr_search_spot.object(at: i) as! NSDictionary).value(forKey: "monEndTime") as! String)"
                        
                    }
                    if dayInWeek == "Tuesday"{
                        spotStart_times = "\(str)\((self.arr_search_spot.object(at: i) as! NSDictionary).value(forKey: "tueEndTime") as! String)"
                        spotEnd_times = "\(str)\((self.arr_search_spot.object(at: i) as! NSDictionary).value(forKey: "tueStartTime") as! String)"
                        
                        
                    }
                    if dayInWeek == "Wednesday"{
                        spotStart_times = "\(str)\((self.arr_search_spot.object(at: i) as! NSDictionary).value(forKey: "wedStartTime") as! String)"
                        spotEnd_times = "\(str)\((self.arr_search_spot.object(at: i) as! NSDictionary).value(forKey: "wedEndTime") as! String)"
                        
                    }
                    if dayInWeek == "Thursday"{
                        spotStart_times = "\(str)\((self.arr_search_spot.object(at: i) as! NSDictionary).value(forKey: "thuStartTime") as! String)"
                        spotEnd_times = "\(str)\((self.arr_search_spot.object(at: i) as! NSDictionary).value(forKey: "thuEndTime") as! String)"
                        
                    }
                    if dayInWeek == "Friday"{
                        spotStart_times = "\(str)\((self.arr_search_spot.object(at: i) as! NSDictionary).value(forKey: "friStartTime") as! String)"
                        spotEnd_times = "\(str)\((self.arr_search_spot.object(at: i) as! NSDictionary).value(forKey: "friEndTime") as! String)"
                        
                        
                    }
                    if dayInWeek == "Saturday"{
                        spotStart_times = "\(str)\((self.arr_search_spot.object(at: i) as! NSDictionary).value(forKey: "sunStartTime") as! String)"
                        spotEnd_times = "\(str)\((self.arr_search_spot.object(at: i) as! NSDictionary).value(forKey: "satEndTime") as! String)"
                        
                    }
                    
                    formatter.dateFormat = "yyyy-MM-dd HH:mm"
                    
                    let START = formatter.string(from: start_date!)
                    print("start time :" + START)
                    
                    let END = formatter.string(from: end_date!)
                    print("end time :" + END)
                    //print(END)
                    
                    
                    let priceSPOT = Reservation.publicCalcPrice(startDateTimeString:START,endDateTimeString: END, basePrice: basePrice)
                    
                    //    print(time_Price)
                    //                    let numberOfPlaces = 2.0
                    //                    let multiplier = pow(10.0, numberOfPlaces)
                    //                    let rounded = round(priceSPOT * multiplier) / multiplier
                    let doller = Reservation.priceToString(price: priceSPOT)
                    
                    lbl_marker.text = "$\(doller)"
                    //lbl_marker.text = "$\(String(priceSPOT))"
                    
                }else{
                    lbl_marker.text = "$\(doller)"
                }
                
                lbl_marker.textColor = UIColor.black
                //                lbl_marker.adjustsFontSizeToFitWidth = true
                //                lbl_marker.numberOfLines = 1
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
        //Time_price = false
        
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
        for component in place.addressComponents!  {
            print(component.type)
            print(component.name)
            if component.type == "locality" {
                // self.CurrentLocMarker.title = component.name
            }
            else{
                if component.type == "sublocality_level_1" {
                    //self.CurrentLocMarker.title = component.name
                }
            }
        }
        //        self.CurrentLocMarker.title = "myLoc"
        var markerView = UIImageView()
        markerView = UIImageView(image: UIImage.init(named: "current_location_icon"))
        markerView.frame.size.width = 30
        markerView.frame.size.height = 30
        // self.CurrentLocMarker.iconView = markerView
        let camera = GMSCameraPosition.camera(withLatitude: (place.coordinate.latitude), longitude: (place.coordinate.longitude), zoom:self.mapView.camera.zoom)
        mapView.camera = camera
        //self.mapView.animate(to: camera)
        five = 0
        loadEventsToMap(lat: place.coordinate.latitude, long:place.coordinate.longitude)
        view_info.isHidden = true
        btn_close.isHidden = true
        if Date_VIew.isHidden == true{
            // Date_VIew.isHidden = false
            
            UIView.transition(with: Date_VIew, duration: 0.3, options: .transitionCurlDown, animations: {
                self.Date_VIew.isHidden = false
            })
            
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
        completion(arg)
    }
    
    
    // UIPICKERVIEW:_
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return timearray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        let today = Date()
        if pickerView == timpic1{
            format1 = timearray[row]
        }
        if pickerView == timepic2{
            endChange = true
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
                                                reservationInfo: self.chargeInfoReservation,
                                                completion: completion) 
        Spinner.start()
    }
    
    func paymentContext(_ paymentContext: STPPaymentContext, didFinishWith status: STPPaymentStatus, error: Error?) {
        print("run didFinishWith paymentContext()")
        let title: String
        let message: String
        switch status {
        case .error:
            title = "Error"
            message = error?.localizedDescription ?? ""
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(action)
            self.present(alertController, animated: true, completion: nil)
            
        case .success:
            Spinner.start()
            
            // if payment succeeds and is not canceled, transfer funds to the spot ownner and set the reservations in the database
            self.transferAndSetReservations()
            
        case .userCancellation:
            return
        }
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
        print("Customer String: \(AppState.sharedInstance.user.customertoken)")
        print("Account String: \(AppState.sharedInstance.user.accounttoken)")
    }
    
    func setPaymentContext(price: Int) {
        paymentContext = STPPaymentContext(customerContext: STPCustomerContext(keyProvider: MyAPIClient.sharedClient))
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

extension Date {
    
    func isEqualTo(_ date: Date) -> Bool {
        return self == date
    }
    
    func isGreaterThan(_ date: Date) -> Bool {
        return self > date
    }
    
    func isSmallerThan(_ date: Date) -> Bool {
        return self < date
    }
}
