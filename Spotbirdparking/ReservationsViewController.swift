//
//  ReservationsViewController.swift
//  Spotbirdparking
//
//  Created by user138340 on 10/17/18.
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
import JTAppleCalendar
import MapKit

class ReservationsViewController: UIViewController,GMSMapViewDelegate,CLLocationManagerDelegate{
    
    @IBOutlet weak var calendarView: JTAppleCalendarView!
    @IBOutlet weak var resByDayTable: UITableView!
    @IBOutlet weak var monthYearLabel: UILabel!
    
    @IBOutlet var mapView: GMSMapView!
    @IBOutlet var btn_back: UIButton!
    
    var resOnDay = [Reservation]()
    
    let currentDateSelectedViewColor = UIColor(red: 178, green: 178, blue: 178, alpha: 1)
    
    let formatter = DateFormatter()
    
    var locManager = CLLocationManager()
    let CurrentLocMarker = GMSMarker()
    var Spot_cooridnates = CLLocationCoordinate2D()
    var timerAnimation: Timer!
    
    var locationManager = CLLocationManager()
    
    var spotlatitude:Double  = Double()
    var spotlongitude:Double  = Double()
    
      var SpotDetails:String  = String()
    
    var cellDate = Date()
    
//    let testRes: Reservation
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // highlight today in the calendar
        calendarView.selectDates([Date()])
        
        // reservation table starts on current date
        print("We will scroll to the right date")
        calendarView.scrollToDate(Date(), animateScroll: false)
        
        // delegates and row height
        calendarView.calendarDataSource = self
        calendarView.calendarDelegate = self
        resByDayTable.delegate = self
        resByDayTable.dataSource = self
        resByDayTable.rowHeight = 80
        
        setView(view: mapView, hidden: true)
        setView(view: btn_back, hidden: true)
        
        Spinner.stop()
        Spinner.start()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
            if AppState.sharedInstance.user.reservationsDownloaded == true {
                
                print("Reservations: \(AppState.sharedInstance.user.reservations)")
                
                // reservation table shows data for today
                self.resOnDay = self.getReservationsOnDay(date: Date())
                self.resByDayTable.reloadData()
                
                // setup the CalendarView()
                self.setupCalendarView()
                
                Spinner.stop()
            } else {
                print("waiting to download")
            }
        })
        
        
//        // Temp data
//        let spot = Spot(address: "1500 Market Street", town: "Philadelphia", state: "PA", zipCode: "19102", spotImage: "test", description: "<#T##String#>", monStartTime: "<#T##String#>", monEndTime: "<#T##String#>", tueStartTime: "<#T##String#>", tueEndTime: "<#T##String#>", wedStartTime: "<#T##String#>", wedEndTime: "<#T##String#>", thuStartTime: "<#T##String#>", thuEndTime: "<#T##String#>", friStartTime: "<#T##String#>", friEndTime: "<#T##String#>", satStartTime: "<#T##String#>", satEndTime: "<#T##String#>", sunStartTime: "<#T##String#>", sunEndTime: "<#T##String#>", monOn: true, tueOn: true, wedOn: true, thuOn: true, friOn: true, satOn: true, sunOn: true, hourlyPricing: "1", dailyPricing: "1.00", weeklyPricing: "3", monthlyPricing: "8", weeklyOn: true, monthlyOn: true, index: 0, approved: true, spotImages: UIImage(named: "test")!, spots_id: "-LhmnAVVHAoJ9GpmO9YW", latitude: "39.9525839", longitude: "-75.1652215", spottype: "", owner_id: "", Email: "", baseprice: "")
//
//        let spot2 = Spot(address: "1500 Micheal Plaza also an unreasonable amoutnt of text", town: "Philly", state: "PA", zipCode: "00000", spotImage: "Share", description: "<#T##String#>", monStartTime: "<#T##String#>", monEndTime: "<#T##String#>", tueStartTime: "<#T##String#>", tueEndTime: "<#T##String#>", wedStartTime: "<#T##String#>", wedEndTime: "<#T##String#>", thuStartTime: "<#T##String#>", thuEndTime: "<#T##String#>", friStartTime: "<#T##String#>", friEndTime: "<#T##String#>", satStartTime: "<#T##String#>", satEndTime: "<#T##String#>", sunStartTime: "<#T##String#>", sunEndTime: "<#T##String#>", monOn: true, tueOn: true, wedOn: true, thuOn: true, friOn: true, satOn: true, sunOn: true, hourlyPricing: "1", dailyPricing: "1.00", weeklyPricing: "3", monthlyPricing: "8", weeklyOn: true, monthlyOn: true, index: 0, approved: true, spotImages: UIImage(named: "Share")!, spots_id: "<#T##String#>", latitude: "20.1", longitude: "50.1", spottype: "", owner_id: "", Email: "", baseprice: "")
//
//        let car = Car(make: "<#T##String#>", model: "<#T##String#>", year: "<#T##String#>", carImage: "<#T##String#>", isDefault: true, car_id: "<#T##String#>")
//
//        AppState.sharedInstance.user.reservations = [Reservation(startDateTime: "2019-01-18 12:00", endDateTime: "2019-01-18 13:00", parkOrRent: "Park", spot: spot!, parkerID: "1234", car: car!), Reservation(startDateTime: "2019-01-08 14:30", endDateTime: "2019-01-08 16:30", parkOrRent: "Park", spot: spot2!, parkerID: "1234", car: car!), Reservation(startDateTime: "2019-01-05 14:30", endDateTime: "2019-01-08 16:30", parkOrRent: "Park", spot: spot!, parkerID: "1234", car: car!), Reservation(startDateTime: "2019-01-18 13:00", endDateTime: "2019-01-18 15:00", parkOrRent: "Rent", spot: spot2!, parkerID: "1234", car: car!)] as! [Reservation]
        
//        let testRes = Reservation(startDateTime: "2019-06-24 19:00", endDateTime: "2019-06-24 23:30", parkOrRent: "Park", spot: spot!, parkerID: "1234", car: car!, ownerID: "-Ld-qaMWe_3vvivur38l")
        
        // just debug code:
        //        AppState.sharedInstance.user.getReservationTimesForUser(spotUser: "-LbWC5PfUgukQWiQKhi9")
        // remember spotUser is the owner of the spot
//        AppState.sharedInstance.user.getReservationTimesForUser(spotUser: "-Ld-qaMWe_3vvivur38l") {
//            timesList in
//            print("Completion: \(timesList)")
//            AppState.sharedInstance.user.checkReservationAgainstTimesList(res: testRes!, timesList: timesList)
//        }
        
    }
    
    // make sure to update calendar every time view is loaded
    override func viewWillAppear(_ animated: Bool) {
        // load the reservation table with today's reservations
        self.resOnDay = self.getReservationsOnDay(date: self.cellDate)
        resByDayTable.reloadData()
        
        // set up the calendar formatting
        setupCalendarView()
        
        // reload the dates that are on the calendar
        calendarView.reloadData()
        
        print("The view will appear right.... now!")
        print("There should be \(AppState.sharedInstance.user.reservations.count) reservations")
        print("there should be \(resOnDay.count) reservations on selected date: \(self.cellDate)")
        
        
    }
    
    func setupCalendarView() {
        // Set up calendar spacing
        calendarView.minimumLineSpacing = 0
        calendarView.minimumInteritemSpacing = 0
        
        // Set month and year labels
        calendarView.visibleDates { (visibleDates) in
            self.setupViewsOfCalendar(from: visibleDates)
        }
    }
    
    func setupViewsOfCalendar(from visibleDates: DateSegmentInfo) {
        let date = visibleDates.monthDates.first!.date
        
        self.formatter.dateFormat = "yyyy"
        let year = self.formatter.string(from: date)
        self.formatter.dateFormat = "MMMM"
        let month = self.formatter.string(from: date)
        
        self.monthYearLabel.text = month + " " + year
    }
    
    func handleCellTextColor(view: JTAppleCell?, cellState: CellState) {
        guard let validCell = view as? CustomCell else { return }
        
        // Fix randomly repeating views across calendar
        if cellState.isSelected {
            validCell.dateLabel.textColor = UIColor.white
        }
        else {
            if cellState.dateBelongsTo == .thisMonth {
                validCell.dateLabel.textColor = UIColor.black
            }
            else {
                validCell.dateLabel.textColor = UIColor.lightGray
            }
        }
    }
    
    func checkReservationDateMatchesCell(reservationDate: String, cellDate: Date) -> Bool
    {
        self.formatter.dateFormat = "yyyy-MM-dd HH:mm"
        let resDate = self.formatter.date(from: reservationDate)
        
        return Calendar.current.isDate(resDate!, inSameDayAs: cellDate)
    }
    
    func handleCellSelected(view: JTAppleCell?, cellState: CellState) {
        guard let validCell = view as? CustomCell else { return }
        
        // Fix randomly repeating views across calendar
        if cellState.isSelected {
            validCell.selectedView.isHidden = false
        }
        else {
            validCell.selectedView.isHidden = true
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func getReservationsOnDay(date: Date) -> [Reservation] {
        print("The date we are looking at is: \(self.formatter.string(from: date))")
        var reservations = [Reservation]()
        
        for res in AppState.sharedInstance.user.reservations {
            if(checkReservationDateMatchesCell(reservationDate: res.startDateTime, cellDate: date)) {
                reservations.append(res)
            }
        }
        print("There are \(reservations.count) reservations on \(self.formatter.string(from: date))")
        return reservations
    }
    
    @IBAction func BAck(_ sender: Any)
    {
        setView(view: mapView, hidden: true)
        setView(view: btn_back, hidden: true)
    }
}

extension ReservationsViewController: JTAppleCalendarViewDataSource {
    
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        // set formate of date
        formatter.dateFormat = "yyyy MM dd"
        formatter.timeZone = Calendar.current.timeZone
        formatter.locale = Calendar.current.locale
        
        // get the current year and month
        let monthFormatter = DateFormatter()
        monthFormatter.dateFormat = "MM"
        let yearFormatter = DateFormatter()
        yearFormatter.dateFormat = "YYYY"
        let now = Date()
        let MM = monthFormatter.string(from: now)
        let YYYY = yearFormatter.string(from: now)
        let nextYYYY = String((Int(YYYY) ?? 2020) + 1)
        print("Starting Month is: \(MM)")
        print("Starting year is: \(YYYY)")
        print("Next year is: \(nextYYYY)")
        
        // set the start and end date as this month -> 12 months from now
        let startDate = formatter.date(from: "\(YYYY) \(String((Int(MM) ?? 3) - 2)) 01")!
        let endDate = formatter.date(from: "\(nextYYYY) \(MM) 28")!
        
        let parameters = ConfigurationParameters(startDate: startDate, endDate: endDate)
        return parameters
    }
}

extension ReservationsViewController: JTAppleCalendarViewDelegate {
    
    func calendar(_ calendar: JTAppleCalendarView, willDisplay cell: JTAppleCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        // This function should have the same code as the cellForItemAt function
        let myCustomCell = cell as! CustomCell
        sharedFunctionToConfigureCell(myCustomCell: myCustomCell, cellState: cellState, date: date)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        let myCustomCell = calendar.dequeueReusableCell(withReuseIdentifier: "CustomCell", for: indexPath) as! CustomCell
        sharedFunctionToConfigureCell(myCustomCell: myCustomCell, cellState: cellState, date: date)
        return myCustomCell
    }
    
    // Configure the cell
    func sharedFunctionToConfigureCell(myCustomCell: CustomCell, cellState: CellState, date: Date) {
        myCustomCell.dateLabel.text = cellState.text
        
        handleCellSelected(view: myCustomCell, cellState: cellState)
        handleCellTextColor(view: myCustomCell, cellState: cellState)
        
        // show dates with reservation
        var isDateInRes = false
        for res in AppState.sharedInstance.user.reservations {
            if(checkReservationDateMatchesCell(reservationDate: res.startDateTime, cellDate: date)) {
                isDateInRes = true
            }
        }
        myCustomCell.eventView.isHidden = !isDateInRes
        
        // Take care of eventview color
        if(isDateInRes) {
            if(cellState.isSelected) {
                myCustomCell.eventView.backgroundColor = UIColor.white
            }
            else {
                myCustomCell.eventView.backgroundColor = UIColor.init(red: 83/255, green: 188/255, blue: 111/255, alpha: 1.0)
            }
        }
        
        // save the current date
        self.cellDate = date
    }
    
    // Show view when selecting cell
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        handleCellSelected(view: cell, cellState: cellState)
        handleCellTextColor(view: cell, cellState: cellState)
        
        // change event view to white color
        guard let validCell = cell as? CustomCell else { return }
        validCell.eventView.backgroundColor = UIColor.white
        
        // change by-day reservations based on cell
        self.resOnDay = getReservationsOnDay(date: date)
        resByDayTable.reloadData()
        
        // track the date selected
        self.cellDate = date
    }
    
    // Hide view when deselecting cell
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        handleCellSelected(view: cell, cellState: cellState)
        handleCellTextColor(view: cell, cellState: cellState)
        
        // change event view to SpotBird green color
        guard let validCell = cell as? CustomCell else { return }
        validCell.eventView.backgroundColor = UIColor.init(red: 83/255, green: 188/255, blue: 111/255, alpha: 1.0)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        setupViewsOfCalendar(from: visibleDates)
    }
}

extension ReservationsViewController: UITableViewDelegate, UITableViewDataSource,User_navDelegates {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resOnDay.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ResCell") as? ByDayResTableViewCell
        
        let res = resOnDay[indexPath.row]
        
        if res.parkOrRent == "Rent" {
            cell?.navButton.isHidden = true
        }
        else {
            cell?.navButton.isHidden = false
        }
        
        cell?.spotImageView.sd_setImage(with: URL(string: res.spot.spotImage), placeholderImage: UIImage(named: "emptySpot"))
        cell?.addressLabel.text = res.spot.address
        cell?.cityStateLabel.text = res.spot.town + ", " + res.spot.state
        cell?.timeLabel.text = "Begin: " + res.startDateTime
        cell?.endTimeLabel.text = "Finish: " + res.endDateTime
        cell?.delegate = self

        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let res = resOnDay[indexPath.row]
        print(res)
        if res.parkOrRent == "Park" {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ReservationsDetailViewController") as! ReservationsDetailViewController
            vc.resOnDay = resOnDay
            vc.index = indexPath.row
            self.present(vc, animated: true, completion: nil)
        } else {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "RentingOutDetailViewController") as! RentingOutDetailViewController
            vc.resOnDay = resOnDay
            vc.index = indexPath.row
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    // MARK:- NAVIGATE TO LOCATION
    func navigateLocation(cell: ByDayResTableViewCell) {
        let index = resByDayTable.indexPath(for: cell)!
        let res = resOnDay[index.row]
        
        spotlatitude =  (res.spot.latitude as NSString).doubleValue
        spotlongitude = (res.spot.longitude as NSString).doubleValue
        
        SpotDetails = res.spot.address
        
        self.Spot_cooridnates = CLLocationCoordinate2DMake(self.spotlatitude,self.spotlongitude)
//        self.mapView.delegate = self
//        self.locationManager.delegate = self
//        self.locationManager.requestAlwaysAuthorization()
//        self.locationManager.requestWhenInUseAuthorization()
//        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
//        self.CurrentLocMarker.map = self.mapView
//        self.locationManager.startMonitoringSignificantLocationChanges()
//        self.locationManager.startUpdatingLocation()
//     // mapView.isMyLocationEnabled = true
//        self.mapView.settings.myLocationButton = true
        
                    if (UIApplication.shared.canOpenURL(NSURL(string:"comgooglemaps://")! as URL)) {
                        UIApplication.shared.openURL(NSURL(string:
                            "comgooglemaps://?saddr=&daddr=\(self.spotlatitude),\(self.spotlongitude)&directionsmode=driving")! as URL)
        
                    }
                    else {
                        let coordinate = CLLocationCoordinate2DMake(self.spotlatitude, self.spotlongitude)
                        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate, addressDictionary:nil))
                        mapItem.name = "\(res.spot.address), \(res.spot.town), \(res.spot.state) \(res.spot.zipCode))"
                        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving])
                        
//                        NSLog("Can't use comgooglemaps://");
//                        let alert = UIAlertController(title: "Spotbirdparking", message: "Can't use comgooglemaps://", preferredStyle: UIAlertControllerStyle.alert)
//                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
//                        self.present(alert, animated: true, completion: nil)
        
                    }
        
        
    }
    
    //    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    //        print("A cell is selected")
    //        let cell = tableView.cellForRow(at: indexPath as IndexPath)
    //        cell!.backgroundColor = UIColor.init(red: 83/255, green: 188/255, blue: 111/255, alpha: 1.0)
    //    }
    
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
        // let camera = GMSCameraPosition.camera(withLatitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!, zoom:12)
        // self.mapView.animate(to: camera)
        //   mapView.camera = camera
        setView(view: mapView, hidden: false)
        setView(view: btn_back, hidden: false)
        
        
        Spinner.start()
        getPolylineRoute(from:  (location?.coordinate)!, to: Spot_cooridnates)
        self.locationManager.stopUpdatingLocation()
    }
    
    func getPolylineRoute(from source: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D){
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        let url = URL(string: "https://maps.googleapis.com/maps/api/directions/json?origin=\(source.latitude),\(source.longitude)&destination=\(destination.latitude),\(destination.longitude)&sensor=true&mode=driving&key=AIzaSyCvFxAOvA246L6Syk7Cl426254C-sMJGxk")!
        
     //      let url = URL(string: "https://maps.googleapis.com/maps/api/directions/json?origin=\(source.latitude),\(source.longitude)&destination=\(22.9623),\(76.0508)&sensor=true&mode=driving&key=AIzaSyCvFxAOvA246L6Syk7Cl426254C-sMJGxk")!
        
        let task = session.dataTask(with: url, completionHandler: {
            (data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
                Spinner.stop()
            }
            else {
                do {
                    if let json : [String:Any] = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any]{
                        
                        guard let routes = json["routes"] as? NSArray else {
                            DispatchQueue.main.async {
                                Spinner.stop()
                            }
                            return
                        }
                        
                        if (routes.count > 0) {
                            let overview_polyline = routes[0] as? NSDictionary
                            let dictPolyline = overview_polyline?["overview_polyline"] as? NSDictionary
                            
                            let points = dictPolyline?.object(forKey: "points") as! String
                            
                            DispatchQueue.main.async {
                                Spinner.stop()
                                let path = GMSPath(fromEncodedPath: points)
                                let polyline = GMSPolyline(path: path)
                                polyline.strokeColor = .blue
                                polyline.strokeWidth = 4.5
                                polyline.map = self.mapView
                                
                                let bounds = GMSCoordinateBounds(coordinate: source, coordinate: destination)
                                let update = GMSCameraUpdate.fit(bounds, with: UIEdgeInsetsMake(170, 30, 30, 30))
                                self.mapView!.moveCamera(update)
                                let marker = GMSMarker()
                                marker.position = destination
                                marker.title = self.SpotDetails
                                var markerView = UIImageView()
                                markerView = UIImageView(image: UIImage.init(named: "ext"))
                                markerView.frame.size.width = 30
                                markerView.frame.size.height = 30
                                marker.iconView = markerView
                                marker.map = self.mapView
                                let camera = GMSCameraPosition.camera(withLatitude: (source.latitude), longitude: (source.longitude), zoom:10)
                                self.mapView.animate(to: camera)
                                
                                
                            }
                            
                        }
                        else {
                            DispatchQueue.main.async {
                                
                                Spinner.stop()
                                
                                let alertController = UIAlertController(title: "Error", message: json["status"] as? String, preferredStyle: .alert)
                                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                                alertController.addAction(defaultAction)
                                self.present(alertController, animated: true, completion: nil)
                                let camera = GMSCameraPosition.camera(withLatitude: (source.latitude), longitude: (source.longitude), zoom:12)
                                self.mapView.animate(to: camera)
                                
                                
                                
                            }
                        }
                    }
                }
                catch {
                    print("error in JSONSerialization")
                    DispatchQueue.main.async {
                        Spinner.stop()
                    }
                }
            }
        })
        task.resume()
    }
    
    //SET VIEW HIDE UNHIDE
    func setView(view: UIView, hidden: Bool) {
        UIView.transition(with: view, duration: 0.5, options: .transitionCrossDissolve, animations: {
            view.isHidden = hidden
        })
    }
    
}
