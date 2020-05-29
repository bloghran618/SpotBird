//
//  ReservationsViewController.swift
//  Spothawk
//
//  Created by user138340 on 10/17/18.
//  Copyright © 2020 Spothawk. All rights reserved.
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
    
//    @IBOutlet weak var resMapView: GMSMapView!
    @IBOutlet var resMapView: GMSMapView!
    
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
        
        // get the reservations
        _ = DispatchQueue(label: "Getting Reservations", qos: .background).async {
            AppState.sharedInstance.user.getReservations() { message in
                print(message)
                AppState.sharedInstance.user.reservationsDownloaded = true
                print("Done getting the reservations")
            }
        }
        
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
        self.resByDayTable.tableFooterView = UIView()
        resByDayTable.rowHeight = 80
        
        setView(view: resMapView, hidden: true)
        
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
                self.calendarView.reloadData()
                
                Spinner.stop()
            } else {
                print("waiting to download")
            }
        })
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
    
    // check if the existing reservation should show for the cell
    func getReservationsOnDay(date: Date) -> [Reservation] {
        print("The date we are looking at is: \(self.formatter.string(from: date))")
        var reservations = [Reservation]()
        self.formatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        for res in AppState.sharedInstance.user.reservations {
            
            let startDate = self.formatter.date(from: res.startDateTime)
            let endDate = self.formatter.date(from: res.endDateTime)
            if((min(startDate!, endDate!) ... max(startDate!, endDate!)).contains(date) || checkReservationDateMatchesCell(reservationDate: res.startDateTime, cellDate: date) || checkReservationDateMatchesCell(reservationDate: res.endDateTime, cellDate: date)) {
                
                reservations.append(res)
            }
        }
        print("There are \(reservations.count) reservations on \(self.formatter.string(from: date))")
        return reservations
    }
}

extension ReservationsViewController: JTAppleCalendarViewDataSource {
    
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
  
        // Set start and end dates for  calendar display based on current date
        let now = Date()
        let twoMonthsAgo = Calendar.current.date(byAdding: .month, value: -2, to: now)
        let nextYear = Calendar.current.date(byAdding: .year, value: 1, to: now)
        
        let parameters = ConfigurationParameters(startDate: twoMonthsAgo!, endDate: nextYear!)
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
        
        self.formatter.dateFormat = "yyyy-MM-dd HH:mm"

        for res in AppState.sharedInstance.user.reservations {
            
            let startDate = self.formatter.date(from: res.startDateTime)
            let endDate = self.formatter.date(from: res.endDateTime)
            
            // check reservation should show for date
            if((min(startDate!, endDate!) ... max(startDate!, endDate!)).contains(date) || checkReservationDateMatchesCell(reservationDate: res.startDateTime, cellDate: date) || checkReservationDateMatchesCell(reservationDate: res.endDateTime, cellDate: date)) {
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
        
        // change event view to Spothawk green color
        guard let validCell = cell as? CustomCell else { return }
        validCell.eventView.backgroundColor = UIColor.init(red: 83/255, green: 188/255, blue: 111/255, alpha: 1.0)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        setupViewsOfCalendar(from: visibleDates)
    }
}

// MARK: Table View Stuff
extension ReservationsViewController: UITableViewDelegate, UITableViewDataSource,User_navDelegates {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resOnDay.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ResCell") as? ByDayResTableViewCell
        
        // get the reservations
        let res = resOnDay[indexPath.row]
        
        // convert database dateformat to Reservations date format
        self.formatter.dateFormat = "yyyy-MM-dd HH:mm"
        let startDate = self.formatter.date(from: res.startDateTime)
        let endDate = self.formatter.date(from: res.endDateTime)
        self.formatter.dateFormat = "MMM dd, h:mm a"
        let formattedStartDate = self.formatter.string(from: startDate!)
        let formattedEndDate = self.formatter.string(from: endDate!)

        // configure the cell
        if res.parkOrRent == "Rent" {
            cell?.navButton.isHidden = true
        }
        else {
            cell?.navButton.isHidden = false
        }
        cell?.spotImageView.sd_setImage(with: URL(string: res.spot.spotImage), placeholderImage: UIImage(named: "emptySpot"))
        cell?.addressLabel.text = res.spot.address
        cell?.cityStateLabel.text = res.spot.town + ", " + res.spot.state
        cell?.timeLabel.text = "Begin: " + formattedStartDate
        cell?.endTimeLabel.text = "Finish: " + formattedEndDate
        cell?.delegate = self

        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let res = resOnDay[indexPath.row]
        print(res)
        if res.parkOrRent == "Park" {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ReservationsDetailViewController") as! ReservationsDetailViewController
            vc.modalPresentationStyle = .fullScreen
            vc.resOnDay = resOnDay
            vc.index = indexPath.row
            self.present(vc, animated: true, completion: nil)
            
        } else {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "RentingOutDetailViewController") as! RentingOutDetailViewController
            vc.modalPresentationStyle = .fullScreen
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
        
        // get spot info for Google maps and format it for Maps universal links
        let spotAddress = res.spot.address as! String
        let formattedSpotAddress = spotAddress.replacingOccurrences(of: " ", with: "+")
        let spotTown = res.spot.town as! String
        let formattedSpotTown = spotTown.replacingOccurrences(of: " ", with: "+")
        let spotState = res.spot.state as! String
        let formattedSpotState = spotState.replacingOccurrences(of: " ", with: "+")
        
        self.Spot_cooridnates = CLLocationCoordinate2DMake(self.spotlatitude,self.spotlongitude)
        
        // try google maps
        if (UIApplication.shared.canOpenURL(NSURL(string:"comgooglemaps://")! as URL)) {

            UIApplication.shared.openURL(NSURL(string: "comgooglemaps://?saddr=&daddr=\(formattedSpotAddress),\(formattedSpotTown),\(formattedSpotState)&directionsmode=driving")! as URL)
        
        }
        else {
            let coordinate = CLLocationCoordinate2DMake(self.spotlatitude, self.spotlongitude)
            let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate, addressDictionary:nil))
            mapItem.name = "\(res.spot.address), \(res.spot.town), \(res.spot.state) \(res.spot.zipCode))"
            mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving])
        }
    }
    
    // View transition
    func setView(view: UIView, hidden: Bool) {
        UIView.transition(with: view, duration: 0.5, options: .transitionCrossDissolve, animations: {
            view.isHidden = hidden
        })
    }
    
}

extension Date {
    func isBetween(date1: Date, date2: Date) -> Bool {
        return (min(date1, date2) ... max(date1, date2)).contains(self)
    }
}
