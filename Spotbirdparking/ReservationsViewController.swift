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
    
    let formatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension ReservationsViewController: JTAppleCalendarViewDelegate, JTAppleCalendarViewDataSource {
    
    public func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        
        formatter.dateFormat = "yyyy MM dd"
        formatter.timeZone = Calendar.current.timeZone
        formatter.locale = Calendar.current.locale
        
        let startDate = formatter.date(from: "2017 01 01")!
        let endDate = formatter.date(from: "2017 12 31")!
        
        let parameters = ConfigurationParameters(startDate: startDate, endDate: endDate)
        return parameters
    }
    
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "CustomCell", for: indexPath) as! ReservationViewCell
        cell.dateLabel.text = cellState.text
        return cell
    }
    
    // This function has to be exactly the same as the previous function!
    func calendar(_ calendar: JTAppleCalendarView, willDisplay cell: JTAppleCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "CustomCell", for: indexPath) as! ReservationViewCell
        cell.dateLabel.text = cellState.text
    }
    
    func sharedFunctionToConfigureCell(myCustomCell: ReservationViewCell, cellState: CellState, date: Date) {
        // Can optionally implement this
    }
}
