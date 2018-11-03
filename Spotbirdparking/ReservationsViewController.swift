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
    @IBOutlet weak var year: UILabel!
    @IBOutlet weak var month: UILabel!
    @IBOutlet weak var resByDayTable: UITableView!
    
    
    let currentDateSelectedViewColor = UIColor(red: 178, green: 178, blue: 178, alpha: 1)
    
    let formatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Temp data
         let spot = Spot(address: "", town: "", state: "", zipCode: "", spotImage: "test", description: "<#T##String#>", monStartTime: "<#T##String#>", monEndTime: "<#T##String#>", tueStartTime: "<#T##String#>", tueEndTime: "<#T##String#>", wedStartTime: "<#T##String#>", wedEndTime: "<#T##String#>", thuStartTime: "<#T##String#>", thuEndTime: "<#T##String#>", friStartTime: "<#T##String#>", friEndTime: "<#T##String#>", satStartTime: "<#T##String#>", satEndTime: "<#T##String#>", sunStartTime: "<#T##String#>", sunEndTime: "<#T##String#>", monOn: true, tueOn: true, wedOn: true, thuOn: true, friOn: true, satOn: true, sunOn: true, hourlyPricing: "1", dailyPricing: "1.00", weeklyPricing: "3", monthlyPricing: "8", weeklyOn: true, monthlyOn: true, index: 0, approved: true, spotImages: UIImage(named: "test")!, spots_id: "<#T##String#>")
        AppState.sharedInstance.reservations = [Reservation(startDateTime: "2018-01-18 12:00", endDateTime: "2018-01-18 13:00", parkOrRent: "Park", spot: spot!), Reservation(startDateTime: "2018-01-08 14:30", endDateTime: "2018-01-08 16:30", parkOrRent: "Park", spot: spot!), Reservation(startDateTime: "2018-01-05 14:30", endDateTime: "2018-01-08 16:30", parkOrRent: "Park", spot: spot!)] as! [Reservation]
        
        for res in AppState.sharedInstance.reservations {
            print("Start Date: " + res.startDateTime)
        }
        
        calendarView.calendarDataSource = self
        calendarView.calendarDelegate = self
        
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
        self.year.text = self.formatter.string(from: date)
        
        self.formatter.dateFormat = "MMMM"
        self.month.text = self.formatter.string(from: date)
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
}

extension ReservationsViewController: JTAppleCalendarViewDataSource {
    
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        formatter.dateFormat = "yyyy MM dd"
        formatter.timeZone = Calendar.current.timeZone
        formatter.locale = Calendar.current.locale
        
        let startDate = formatter.date(from: "2018 01 01")!
        let endDate = formatter.date(from: "2018 12 31")!
        
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
    }
    
    // Show view when selecting cell
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        handleCellSelected(view: cell, cellState: cellState)
        handleCellTextColor(view: cell, cellState: cellState)
        
        // change event view to white color
        guard let validCell = cell as? CustomCell else { return }
        validCell.eventView.backgroundColor = UIColor.white
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
