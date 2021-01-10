//
//  ScheduleViewController.swift
//  Spothawk
//
//  Created by user138340 on 8/7/18.
//  Copyright © 2020 Spothawk. All rights reserved.
//

import UIKit

class ScheduleViewController: UIViewController, UITextFieldDelegate{
    
    @IBOutlet weak var monSwitch: UISwitch!
    @IBOutlet weak var monStartPicker: UIDatePicker!
    @IBOutlet weak var monEndPicker: UIDatePicker!
    
    @IBOutlet weak var tueSwitch: UISwitch!
    @IBOutlet weak var tueStartPicker: UIDatePicker!
    @IBOutlet weak var tueEndPicker: UIDatePicker!
    
    @IBOutlet weak var wedSwitch: UISwitch!
    @IBOutlet weak var wedStartPicker: UIDatePicker!
    @IBOutlet weak var wedEndPicker: UIDatePicker!
    
    @IBOutlet weak var thuSwitch: UISwitch!
    @IBOutlet weak var thuStartPicker: UIDatePicker!
    @IBOutlet weak var thuEndPicker: UIDatePicker!
    
    @IBOutlet weak var friSwitch: UISwitch!
    @IBOutlet weak var friStartPicker: UIDatePicker!
    @IBOutlet weak var friEndPicker: UIDatePicker!
    
    @IBOutlet weak var satSwitch: UISwitch!
    @IBOutlet weak var satStartPicker: UIDatePicker!
    @IBOutlet weak var satEndPicker: UIDatePicker!
    
    @IBOutlet weak var sunSwitch: UISwitch!
    @IBOutlet weak var sunStartPicker: UIDatePicker!
    @IBOutlet weak var sunEndPicker: UIDatePicker!
    
    private var datePicker: UIDatePicker?
    
    let dateFormatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboardWhenTappedAround()
        
        print(AppState.sharedInstance.activeSpot.monStartTime)
        
        monSwitch.setOn(AppState.sharedInstance.activeSpot.monOn, animated: true)
        tueSwitch.setOn(AppState.sharedInstance.activeSpot.tueOn, animated: true)
        wedSwitch.setOn(AppState.sharedInstance.activeSpot.wedOn, animated: true)
        thuSwitch.setOn(AppState.sharedInstance.activeSpot.thuOn, animated: true)
        friSwitch.setOn(AppState.sharedInstance.activeSpot.friOn, animated: true)
        satSwitch.setOn(AppState.sharedInstance.activeSpot.satOn, animated: true)
        sunSwitch.setOn(AppState.sharedInstance.activeSpot.sunOn, animated: true)
        
        // format date formatter
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "hh:mm a"
        
        // set initial values for datepickers
        monStartPicker.date = dateFormatter.date(from: AppState.sharedInstance.activeSpot.monStartTime)!
        monEndPicker.date = dateFormatter.date(from: AppState.sharedInstance.activeSpot.monEndTime)!
        tueStartPicker.date = dateFormatter.date(from: AppState.sharedInstance.activeSpot.tueStartTime)!
        tueEndPicker.date = dateFormatter.date(from: AppState.sharedInstance.activeSpot.tueEndTime)!
        wedStartPicker.date = dateFormatter.date(from: AppState.sharedInstance.activeSpot.wedStartTime)!
        wedEndPicker.date = dateFormatter.date(from: AppState.sharedInstance.activeSpot.wedEndTime)!
        thuStartPicker.date = dateFormatter.date(from: AppState.sharedInstance.activeSpot.thuEndTime)!
        thuEndPicker.date = dateFormatter.date(from: AppState.sharedInstance.activeSpot.thuEndTime)!
        friStartPicker.date = dateFormatter.date(from: AppState.sharedInstance.activeSpot.friStartTime)!
        friEndPicker.date = dateFormatter.date(from: AppState.sharedInstance.activeSpot.friEndTime)!
        satStartPicker.date = dateFormatter.date(from: AppState.sharedInstance.activeSpot.satStartTime)!
        satEndPicker.date = dateFormatter.date(from: AppState.sharedInstance.activeSpot.satEndTime)!
        sunStartPicker.date = dateFormatter.date(from: AppState.sharedInstance.activeSpot.sunStartTime)!
        sunEndPicker.date = dateFormatter.date(from: AppState.sharedInstance.activeSpot.sunEndTime)!
     }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // handle monday interactive actions
    @IBAction func monStartPickerChanged(_ sender: UIDatePicker) {
        if monStartPicker.date < monEndPicker.date {
            AppState.sharedInstance.activeSpot.monStartTime = dateFormatter.string(from: sender.date)
        }
        else {
            monStartPicker.date = dateFormatter.date(from: AppState.sharedInstance.activeSpot.monStartTime)!
            sendDateAlert()
        }
    }
    
    @IBAction func monEndPickerChanged(_ sender: UIDatePicker) {
        if monStartPicker.date < monEndPicker.date {
            AppState.sharedInstance.activeSpot.monEndTime = dateFormatter.string(from: sender.date)
        }
        else {
            monEndPicker.date = dateFormatter.date(from: AppState.sharedInstance.activeSpot.monEndTime)!
            sendDateAlert()
        }
    }
    @IBAction func monSwitchStatusChanged(_ sender: UISwitch) {
        AppState.sharedInstance.activeSpot.monOn = sender.isOn
        
        if sender.isOn {
            AppState.sharedInstance.activeSpot.monStartTime = "12:00 AM"
            AppState.sharedInstance.activeSpot.monEndTime = "11:59 PM"
            monStartPicker.date = dateFormatter.date(from: AppState.sharedInstance.activeSpot.monStartTime)!
            monEndPicker.date = dateFormatter.date(from: AppState.sharedInstance.activeSpot.monEndTime)!
        }
        else {
            AppState.sharedInstance.activeSpot.monStartTime = ""
            AppState.sharedInstance.activeSpot.monEndTime = ""
        }
        
        monStartPicker.isEnabled = AppState.sharedInstance.activeSpot.monOn
        monEndPicker.isEnabled = AppState.sharedInstance.activeSpot.monOn
    }
    
    // handle tuesday interactive actions
    @IBAction func tueStartPickerChanged(_ sender: UIDatePicker) {
        if tueStartPicker.date < tueEndPicker.date {
            AppState.sharedInstance.activeSpot.tueStartTime = dateFormatter.string(from: sender.date)
        }
        else {
            tueStartPicker.date = dateFormatter.date(from: AppState.sharedInstance.activeSpot.tueStartTime)!
            sendDateAlert()
        }
    }
    
    @IBAction func tueEndPickerChanged(_ sender: UIDatePicker) {
        if tueStartPicker.date < tueEndPicker.date {
            AppState.sharedInstance.activeSpot.tueEndTime = dateFormatter.string(from: sender.date)
        }
        else {
            tueEndPicker.date = dateFormatter.date(from: AppState.sharedInstance.activeSpot.tueEndTime)!
            sendDateAlert()
        }
    }
    
    @IBAction func tueSwitchStatusChanged(_ sender: UISwitch) {
        AppState.sharedInstance.activeSpot.tueOn = sender.isOn
        
        if sender.isOn {
            AppState.sharedInstance.activeSpot.tueStartTime = "12:00 AM"
            AppState.sharedInstance.activeSpot.tueEndTime = "11:59 PM"
            tueStartPicker.date = dateFormatter.date(from: AppState.sharedInstance.activeSpot.tueStartTime)!
            tueEndPicker.date = dateFormatter.date(from: AppState.sharedInstance.activeSpot.tueEndTime)!
        }
        else {
            AppState.sharedInstance.activeSpot.tueStartTime = ""
            AppState.sharedInstance.activeSpot.tueEndTime = ""
        }
        
        tueStartPicker.isEnabled = AppState.sharedInstance.activeSpot.tueOn
        tueEndPicker.isEnabled = AppState.sharedInstance.activeSpot.tueOn
    }
    
    // handle wednesday interactive actions
    @IBAction func wedStartPickerChanged(_ sender: UIDatePicker) {
        if wedStartPicker.date < wedEndPicker.date {
            AppState.sharedInstance.activeSpot.wedStartTime = dateFormatter.string(from: sender.date)
        }
        else {
            wedStartPicker.date = dateFormatter.date(from: AppState.sharedInstance.activeSpot.wedStartTime)!
            sendDateAlert()
        }
    }
    @IBAction func wedEndPickerChanged(_ sender: UIDatePicker) {
        if wedStartPicker.date < wedEndPicker.date {
            AppState.sharedInstance.activeSpot.wedEndTime = dateFormatter.string(from: sender.date)
        }
        else {
            wedEndPicker.date = dateFormatter.date(from: AppState.sharedInstance.activeSpot.wedEndTime)!
            sendDateAlert()
        }
    }
    
    @IBAction func wedSwitchStateChanged(_ sender: UISwitch) {
        AppState.sharedInstance.activeSpot.wedOn = sender.isOn
        
        if sender.isOn {
            AppState.sharedInstance.activeSpot.wedStartTime = "12:00 AM"
            AppState.sharedInstance.activeSpot.wedEndTime = "11:59 PM"
            wedStartPicker.date = dateFormatter.date(from: AppState.sharedInstance.activeSpot.wedStartTime)!
            wedEndPicker.date = dateFormatter.date(from: AppState.sharedInstance.activeSpot.wedEndTime)!
        }
        else {
            AppState.sharedInstance.activeSpot.wedStartTime = ""
            AppState.sharedInstance.activeSpot.wedEndTime = ""
        }
        
        wedStartPicker.isEnabled = AppState.sharedInstance.activeSpot.wedOn
        wedEndPicker.isEnabled = AppState.sharedInstance.activeSpot.wedOn
    }
    
    // handle thursday interactive actions
    @IBAction func thuStartPickerChanged(_ sender: UIDatePicker) {
        if thuStartPicker.date < thuEndPicker.date {
            AppState.sharedInstance.activeSpot.thuStartTime = dateFormatter.string(from: sender.date)
        }
        else {
            thuStartPicker.date = dateFormatter.date(from: AppState.sharedInstance.activeSpot.thuStartTime)!
            sendDateAlert()
        }
    }
    @IBAction func thuEndPickerChanged(_ sender: UIDatePicker) {
        if thuStartPicker.date < thuEndPicker.date {
            AppState.sharedInstance.activeSpot.thuEndTime = dateFormatter.string(from: sender.date)
        }
        else {
            thuEndPicker.date = dateFormatter.date(from: AppState.sharedInstance.activeSpot.thuEndTime)!
            sendDateAlert()
        }
    }
    
    @IBAction func thuSwitchStateChanged(_ sender: UISwitch) {
        AppState.sharedInstance.activeSpot.thuOn = sender.isOn
        
        if sender.isOn {
            AppState.sharedInstance.activeSpot.thuStartTime = "12:00 AM"
            AppState.sharedInstance.activeSpot.thuEndTime = "11:59 PM"
            thuStartPicker.date = dateFormatter.date(from: AppState.sharedInstance.activeSpot.thuStartTime)!
            thuEndPicker.date = dateFormatter.date(from: AppState.sharedInstance.activeSpot.thuEndTime)!
        }
        else {
            AppState.sharedInstance.activeSpot.thuStartTime = ""
            AppState.sharedInstance.activeSpot.thuEndTime = ""
        }
        
        thuStartPicker.isEnabled = AppState.sharedInstance.activeSpot.thuOn
        thuEndPicker.isEnabled = AppState.sharedInstance.activeSpot.thuOn
    }
    
    // handle friday interactive actions
    @IBAction func friStartPickerChanged(_ sender: UIDatePicker) {
        if friStartPicker.date < friEndPicker.date {
            AppState.sharedInstance.activeSpot.friStartTime = dateFormatter.string(from: sender.date)
        }
        else {
            friStartPicker.date = dateFormatter.date(from: AppState.sharedInstance.activeSpot.friStartTime)!
            sendDateAlert()
        }
    }
    
    @IBAction func friEndPickerChanged(_ sender: UIDatePicker) {
        if friStartPicker.date < friEndPicker.date {
            AppState.sharedInstance.activeSpot.friEndTime = dateFormatter.string(from: sender.date)
        }
        else {
            friEndPicker.date = dateFormatter.date(from: AppState.sharedInstance.activeSpot.friEndTime)!
            sendDateAlert()
        }
    }
    
    @IBAction func friSwitchStateChanged(_ sender: UISwitch) {
        AppState.sharedInstance.activeSpot.friOn = sender.isOn
        
        if sender.isOn {
            AppState.sharedInstance.activeSpot.friStartTime = "12:00 AM"
            AppState.sharedInstance.activeSpot.friEndTime = "11:59 PM"
            friStartPicker.date = dateFormatter.date(from: AppState.sharedInstance.activeSpot.friStartTime)!
            friEndPicker.date = dateFormatter.date(from: AppState.sharedInstance.activeSpot.friEndTime)!
        }
        else {
            AppState.sharedInstance.activeSpot.friStartTime = ""
            AppState.sharedInstance.activeSpot.friEndTime = ""
        }
        
        friStartPicker.isEnabled = AppState.sharedInstance.activeSpot.friOn
        friEndPicker.isEnabled = AppState.sharedInstance.activeSpot.friOn
    }
    
    // handle saturday interactive actions
    @IBAction func satStartPickerChanged(_ sender: UIDatePicker) {
        if satStartPicker.date < satEndPicker.date {
            AppState.sharedInstance.activeSpot.satStartTime = dateFormatter.string(from: sender.date)
        }
        else {
            satStartPicker.date = dateFormatter.date(from: AppState.sharedInstance.activeSpot.satStartTime)!
            sendDateAlert()
        }
    }
    
    @IBAction func satEndPickerChanged(_ sender: UIDatePicker) {
        if satStartPicker.date < satEndPicker.date {
            AppState.sharedInstance.activeSpot.satEndTime = dateFormatter.string(from: sender.date)
        }
        else {
            satEndPicker.date = dateFormatter.date(from: AppState.sharedInstance.activeSpot.satEndTime)!
            sendDateAlert()
        }
    }
    
    @IBAction func satSwitchStatusChanged(_ sender: UISwitch) {
        AppState.sharedInstance.activeSpot.satOn = sender.isOn
        
        if sender.isOn {
            AppState.sharedInstance.activeSpot.satStartTime = "12:00 AM"
            AppState.sharedInstance.activeSpot.satEndTime = "11:59 PM"
            satStartPicker.date = dateFormatter.date(from: AppState.sharedInstance.activeSpot.satStartTime)!
            satEndPicker.date = dateFormatter.date(from: AppState.sharedInstance.activeSpot.satEndTime)!
        }
        else {
            AppState.sharedInstance.activeSpot.satStartTime = ""
            AppState.sharedInstance.activeSpot.satEndTime = ""
        }
        
        satStartPicker.isEnabled = AppState.sharedInstance.activeSpot.satOn
        satEndPicker.isEnabled = AppState.sharedInstance.activeSpot.satOn
    }
    
    // handle sunday interactive actions
    @IBAction func sunStartPickerChanged(_ sender: UIDatePicker) {
        if sunStartPicker.date < sunEndPicker.date {
            AppState.sharedInstance.activeSpot.sunStartTime = dateFormatter.string(from: sender.date)
        }
        else {
            sunStartPicker.date = dateFormatter.date(from: AppState.sharedInstance.activeSpot.sunStartTime)!
            sendDateAlert()
        }
    }
    
    @IBAction func sunEndPickerChanged(_ sender: UIDatePicker) {
        if sunStartPicker.date < sunEndPicker.date {
            AppState.sharedInstance.activeSpot.sunEndTime = dateFormatter.string(from: sender.date)
        }
        else {
            sunEndPicker.date = dateFormatter.date(from: AppState.sharedInstance.activeSpot.sunEndTime)!
            sendDateAlert()
        }
    }
    
    @IBAction func sunSwitchStatusChanged(_ sender: UISwitch) {
        AppState.sharedInstance.activeSpot.sunOn = sender.isOn
        
        if sender.isOn {
            AppState.sharedInstance.activeSpot.sunStartTime = "12:00 AM"
            AppState.sharedInstance.activeSpot.sunEndTime = "11:59 PM"
            sunStartPicker.date = dateFormatter.date(from: AppState.sharedInstance.activeSpot.sunStartTime)!
            sunEndPicker.date = dateFormatter.date(from: AppState.sharedInstance.activeSpot.sunEndTime)!
        }
        else {
            AppState.sharedInstance.activeSpot.sunStartTime = ""
            AppState.sharedInstance.activeSpot.sunEndTime = ""
        }
        
        sunStartPicker.isEnabled = AppState.sharedInstance.activeSpot.sunOn
        sunEndPicker.isEnabled = AppState.sharedInstance.activeSpot.sunOn
    }
    
    // notify user that the date is invalid
    public func sendDateAlert() {
        let alert = UIAlertController(title: "Date Error", message: "End time must be after start time", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    // 24/7 Button resets to defaults
    @IBAction func anytimeButton(_ sender: Any) {
        
        print("AnytimeButton Pressed")
        
        // Set switches to true
        monSwitch.setOn(true, animated: true)
        tueSwitch.setOn(true, animated: true)
        wedSwitch.setOn(true, animated: true)
        thuSwitch.setOn(true, animated: true)
        friSwitch.setOn(true, animated: true)
        satSwitch.setOn(true, animated: true)
        sunSwitch.setOn(true, animated: true)
        
        // re-enable datepickers
        monStartPicker.isEnabled = true
        monEndPicker.isEnabled = true
        tueStartPicker.isEnabled = true
        tueEndPicker.isEnabled = true
        wedStartPicker.isEnabled = true
        wedEndPicker.isEnabled = true
        thuStartPicker.isEnabled = true
        thuEndPicker.isEnabled = true
        friStartPicker.isEnabled = true
        friEndPicker.isEnabled = true
        satStartPicker.isEnabled = true
        satEndPicker.isEnabled = true
        sunStartPicker.isEnabled = true
        sunEndPicker.isEnabled = true
        
        // set start times to 12:00 AM
        monStartPicker.date = dateFormatter.date(from: "12:00 AM")!
        tueStartPicker.date = dateFormatter.date(from: "12:00 AM")!
        wedStartPicker.date = dateFormatter.date(from: "12:00 AM")!
        thuStartPicker.date = dateFormatter.date(from: "12:00 AM")!
        friStartPicker.date = dateFormatter.date(from: "12:00 AM")!
        satStartPicker.date = dateFormatter.date(from: "12:00 AM")!
        sunStartPicker.date = dateFormatter.date(from: "12:00 AM")!
        
        // set end times to 11:59 PM
        monEndPicker.date = dateFormatter.date(from: "11:59 PM")!
        tueEndPicker.date = dateFormatter.date(from: "11:59 PM")!
        wedEndPicker.date = dateFormatter.date(from: "11:59 PM")!
        thuEndPicker.date = dateFormatter.date(from: "11:59 PM")!
        friEndPicker.date = dateFormatter.date(from: "11:59 PM")!
        satEndPicker.date = dateFormatter.date(from: "11:59 PM")!
        sunEndPicker.date = dateFormatter.date(from: "11:59 PM")!
        
        // set ActiveSpot properties
        AppState.sharedInstance.activeSpot.monStartTime = "12:00 AM"
        AppState.sharedInstance.activeSpot.monEndTime = "11:59 PM"
        AppState.sharedInstance.activeSpot.tueStartTime = "12:00 AM"
        AppState.sharedInstance.activeSpot.tueEndTime = "11:59 PM"
        AppState.sharedInstance.activeSpot.wedStartTime = "12:00 AM"
        AppState.sharedInstance.activeSpot.wedEndTime = "11:59 PM"
        AppState.sharedInstance.activeSpot.thuStartTime = "12:00 AM"
        AppState.sharedInstance.activeSpot.thuEndTime = "11:59 PM"
        AppState.sharedInstance.activeSpot.friStartTime = "12:00 AM"
        AppState.sharedInstance.activeSpot.friEndTime = "11:59 PM"
        AppState.sharedInstance.activeSpot.satStartTime = "12:00 AM"
        AppState.sharedInstance.activeSpot.satEndTime = "11:59 PM"
        AppState.sharedInstance.activeSpot.sunStartTime = "12:00 AM"
        AppState.sharedInstance.activeSpot.sunEndTime = "11:59 PM"
        AppState.sharedInstance.activeSpot.monOn = true
        AppState.sharedInstance.activeSpot.tueOn = true
        AppState.sharedInstance.activeSpot.wedOn = true
        AppState.sharedInstance.activeSpot.thuOn = true
        AppState.sharedInstance.activeSpot.friOn = true
        AppState.sharedInstance.activeSpot.satOn = true
        AppState.sharedInstance.activeSpot.sunOn = true
    }

}
