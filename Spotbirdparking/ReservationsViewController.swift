//
//  ReservationsViewController.swift
//  Spotbirdparking
//
//  Created by user138340 on 10/17/18.
//  Copyright © 2018 Spotbird. All rights reserved.
//

import UIKit
import JTAppleCalendar

class ReservationsViewController: UIViewController {
    
    @IBOutlet weak var calendarView: JTAppleCalendarView!
    @IBOutlet weak var resByDayTable: UITableView!
    @IBOutlet weak var monthYearLabel: UILabel!
    
    var resOnDay = [Reservation]()
    
    let currentDateSelectedViewColor = UIColor(red: 178, green: 178, blue: 178, alpha: 1)
    
    let formatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Temp data
        let spot = Spot(address: "42 Ardmore Rd", town: "Philadelphia", state: "PA", zipCode: "00000", spotImage: "test", description: "<#T##String#>", monStartTime: "<#T##String#>", monEndTime: "<#T##String#>", tueStartTime: "<#T##String#>", tueEndTime: "<#T##String#>", wedStartTime: "<#T##String#>", wedEndTime: "<#T##String#>", thuStartTime: "<#T##String#>", thuEndTime: "<#T##String#>", friStartTime: "<#T##String#>", friEndTime: "<#T##String#>", satStartTime: "<#T##String#>", satEndTime: "<#T##String#>", sunStartTime: "<#T##String#>", sunEndTime: "<#T##String#>", monOn: true, tueOn: true, wedOn: true, thuOn: true, friOn: true, satOn: true, sunOn: true, hourlyPricing: "1", dailyPricing: "1.00", weeklyPricing: "3", monthlyPricing: "8", weeklyOn: true, monthlyOn: true, index: 0, approved: true, spotImages: UIImage(named: "test")!, spots_id: "<#T##String#>", latitude: "20.0", longitude: "50.0", spottype: "")
        let spot2 = Spot(address: "1500 Micheal Plaza also an unreasonable amoutnt of text", town: "Philly", state: "PA", zipCode: "00000", spotImage: "Share", description: "<#T##String#>", monStartTime: "<#T##String#>", monEndTime: "<#T##String#>", tueStartTime: "<#T##String#>", tueEndTime: "<#T##String#>", wedStartTime: "<#T##String#>", wedEndTime: "<#T##String#>", thuStartTime: "<#T##String#>", thuEndTime: "<#T##String#>", friStartTime: "<#T##String#>", friEndTime: "<#T##String#>", satStartTime: "<#T##String#>", satEndTime: "<#T##String#>", sunStartTime: "<#T##String#>", sunEndTime: "<#T##String#>", monOn: true, tueOn: true, wedOn: true, thuOn: true, friOn: true, satOn: true, sunOn: true, hourlyPricing: "1", dailyPricing: "1.00", weeklyPricing: "3", monthlyPricing: "8", weeklyOn: true, monthlyOn: true, index: 0, approved: true, spotImages: UIImage(named: "Share")!, spots_id: "<#T##String#>", latitude: "20.1", longitude: "50.1", spottype: "")
        
        AppState.sharedInstance.reservations = [Reservation(startDateTime: "2019-01-18 12:00", endDateTime: "2019-01-18 13:00", parkOrRent: "Park", spot: spot!), Reservation(startDateTime: "2019-01-08 14:30", endDateTime: "2019-01-08 16:30", parkOrRent: "Park", spot: spot2!), Reservation(startDateTime: "2019-01-05 14:30", endDateTime: "2019-01-08 16:30", parkOrRent: "Park", spot: spot!), Reservation(startDateTime: "2019-01-18 13:00", endDateTime: "2019-01-18 15:00", parkOrRent: "Rent", spot: spot2!)] as! [Reservation]
        
        calendarView.calendarDataSource = self
        calendarView.calendarDelegate = self
        
        self.resByDayTable.delegate = self
        self.resByDayTable.dataSource = self
        self.resByDayTable.rowHeight = 80
        
        setupCalendarView()
    
        // Do any additional setup after loading the view.
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
        var reservations = [Reservation]()
        
        for res in AppState.sharedInstance.reservations {
            if(checkReservationDateMatchesCell(reservationDate: res.startDateTime, cellDate: date)) {
                reservations.append(res)
            }
        }
        return reservations
    }
}

extension ReservationsViewController: JTAppleCalendarViewDataSource {
    
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        formatter.dateFormat = "yyyy MM dd"
        formatter.timeZone = Calendar.current.timeZone
        formatter.locale = Calendar.current.locale
        
        let startDate = formatter.date(from: "2019 01 01")!
        let endDate = formatter.date(from: "2019 12 31")!
        
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
        for res in AppState.sharedInstance.reservations {
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

extension ReservationsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resOnDay.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ResCell") as? ByDayResTableViewCell

        let res = resOnDay[indexPath.row]

        cell?.spotImageView.image = UIImage.init(named: res.spot.spotImage)
        cell?.addressLabel.text = res.spot.address
        cell?.cityStateLabel.text = res.spot.town + ", " + res.spot.state
        cell?.timeLabel.text = "Begin: " + res.startDateTime
        cell?.endTimeLabel.text = "Finish: " + res.endDateTime
        
        return cell!
    }
    
//    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        print("A cell is selected")
//        let cell = tableView.cellForRow(at: indexPath as IndexPath)
//        cell!.backgroundColor = UIColor.init(red: 83/255, green: 188/255, blue: 111/255, alpha: 1.0)
//    }
}
