//
//  ScheduleViewController.swift
//  Spotbirdparking
//
//  Created by user138340 on 8/7/18.
//  Copyright © 2018 Spotbird. All rights reserved.
//

import UIKit

class ScheduleViewController: UIViewController, UITextFieldDelegate{
    
    @IBOutlet weak var monSwitch: UISwitch!
    @IBOutlet weak var monStartTime: UITextField!
    @IBOutlet weak var monEndTime: UITextField!
    
    @IBOutlet weak var tueSwitch: UISwitch!
    @IBOutlet weak var tueStartTime: UITextField!
    @IBOutlet weak var tueEndTime: UITextField!
    
    @IBOutlet weak var wedSwitch: UISwitch!
    @IBOutlet weak var wedStartTime: UITextField!
    @IBOutlet weak var wedEndTime: UITextField!
    
    @IBOutlet weak var thuSwitch: UISwitch!
    @IBOutlet weak var thuStartTime: UITextField!
    @IBOutlet weak var thuEndTime: UITextField!
    
    @IBOutlet weak var friSwitch: UISwitch!
    @IBOutlet weak var friStartTime: UITextField!
    @IBOutlet weak var friEndTime: UITextField!
    
    @IBOutlet weak var satSwitch: UISwitch!
    @IBOutlet weak var satStartTime: UITextField!
    @IBOutlet weak var satEndTime: UITextField!
    
    @IBOutlet weak var sunSwitch: UISwitch!
    @IBOutlet weak var sunStartTime: UITextField!
    @IBOutlet weak var sunEndTime: UITextField!
    
    let monstart = "12:00 PM"
    let monend = " 12:00 AM"
    let tuestart = "12:00 PM"
    let tueend = "12:00 AM"
    let wedstart = "12:00 PM"
    let wedend = "12:00 AM"
    let thustart = "12:00 PM"
    let thuend = "12:00 AM"
    let fristart = "12:00 PM"
    let friend = "12:00 AM"
    let satstart = "12:00 PM"
    let satend = "12:00 AM"
    let sunstart = "12:00 PM"
    let sunend = "12:00 AM"
    
    private var datePicker: UIDatePicker?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
      self.hideKeyboardWhenTappedAround()
        
        // Monday controls
        let monStartDatePicker = UIDatePicker()
        monStartDatePicker.datePickerMode = UIDatePickerMode.time
        monStartDatePicker.addTarget(self, action: #selector(monStartDatePickerValueChanged), for: .valueChanged)
        monStartTime.inputView = monStartDatePicker
        
        let monEndDatePicker = UIDatePicker()
        monEndDatePicker.datePickerMode = UIDatePickerMode.time
        monEndDatePicker.addTarget(self, action: #selector(monEndDatePickerValueChanged), for: .valueChanged)
        monEndTime.inputView = monEndDatePicker
        
        monSwitch.addTarget(self, action: #selector(monSwitchStateChanged), for: UIControlEvents.valueChanged)
        
        // Tuesday controls
        let tueStartDatePicker = UIDatePicker()
        tueStartDatePicker.datePickerMode = UIDatePickerMode.time
        tueStartDatePicker.addTarget(self, action: #selector(tueStartDatePickerValueChanged), for: .valueChanged)
        tueStartTime.inputView = tueStartDatePicker
        
        let tueEndDatePicker = UIDatePicker()
        tueEndDatePicker.datePickerMode = UIDatePickerMode.time
        tueEndDatePicker.addTarget(self, action: #selector(tueEndDatePickerValueChanged), for: .valueChanged)
        tueEndTime.inputView = tueEndDatePicker
        
        tueSwitch.addTarget(self, action: #selector(tueSwitchStateChanged), for: UIControlEvents.valueChanged)
        
        // Wednesday Controls
        let wedStartDatePicker = UIDatePicker()
        wedStartDatePicker.datePickerMode = UIDatePickerMode.time
        wedStartDatePicker.addTarget(self, action: #selector(wedStartDatePickerValueChanged), for: .valueChanged)
        wedStartTime.inputView = wedStartDatePicker
        
        let wedEndDatePicker = UIDatePicker()
        wedEndDatePicker.datePickerMode = UIDatePickerMode.time
        wedEndDatePicker.addTarget(self, action: #selector(wedEndDatePickerValueChanged), for: .valueChanged)
        wedEndTime.inputView = wedEndDatePicker
        
        wedSwitch.addTarget(self, action: #selector(wedSwitchStateChanged), for: UIControlEvents.valueChanged)
        
        // Thursday Controls
        let thuStartDatePicker = UIDatePicker()
        thuStartDatePicker.datePickerMode = UIDatePickerMode.time
        thuStartDatePicker.addTarget(self, action: #selector(thuStartDatePickerValueChanged), for: .valueChanged)
        thuStartTime.inputView = thuStartDatePicker
        
        let thuEndDatePicker = UIDatePicker()
        thuEndDatePicker.datePickerMode = UIDatePickerMode.time
        thuEndDatePicker.addTarget(self, action: #selector(thuEndDatePickerValueChanged), for: .valueChanged)
        thuEndTime.inputView = thuEndDatePicker
        
        thuSwitch.addTarget(self, action: #selector(thuSwitchStateChanged), for: UIControlEvents.valueChanged)
        
        
        // Friday Controls
        let friStartDatePicker = UIDatePicker()
        friStartDatePicker.datePickerMode = UIDatePickerMode.time
        friStartDatePicker.addTarget(self, action: #selector(friStartDatePickerValueChanged), for: .valueChanged)
        friStartTime.inputView = friStartDatePicker
        
        let friEndDatePicker = UIDatePicker()
        friEndDatePicker.datePickerMode = UIDatePickerMode.time
        friEndDatePicker.addTarget(self, action: #selector(friEndDatePickerValueChanged), for: .valueChanged)
        friEndTime.inputView = friEndDatePicker
        
        friSwitch.addTarget(self, action: #selector(friSwitchStateChanged), for: UIControlEvents.valueChanged)
        
        // Saturday controls
        let satStartDatePicker = UIDatePicker()
        satStartDatePicker.datePickerMode = UIDatePickerMode.time
        satStartDatePicker.addTarget(self, action: #selector(satStartDatePickerValueChanged), for: .valueChanged)
        satStartTime.inputView = satStartDatePicker
        
        let satEndDatePicker = UIDatePicker()
        satEndDatePicker.datePickerMode = UIDatePickerMode.time
        satEndDatePicker.addTarget(self, action: #selector(satEndDatePickerValueChanged), for: .valueChanged)
        satEndTime.inputView = satEndDatePicker
        
        satSwitch.addTarget(self, action: #selector(satSwitchStateChanged), for: UIControlEvents.valueChanged)
        
        // Sunday Controls
        let sunStartDatePicker = UIDatePicker()
        sunStartDatePicker.datePickerMode = UIDatePickerMode.time
        sunStartDatePicker.addTarget(self, action: #selector(sunStartDatePickerValueChanged), for: .valueChanged)
        sunStartTime.inputView = sunStartDatePicker
        
        let sunEndDatePicker = UIDatePicker()
        sunEndDatePicker.datePickerMode = UIDatePickerMode.time
        sunEndDatePicker.addTarget(self, action: #selector(sunEndDatePickerValueChanged), for: .valueChanged)
        sunEndTime.inputView = sunEndDatePicker
        
        sunSwitch.addTarget(self, action: #selector(sunSwitchStateChanged), for: UIControlEvents.valueChanged)
        
        monStartTime.text = AppState.sharedInstance.activeSpot.monStartTime
        monEndTime.text = AppState.sharedInstance.activeSpot.monEndTime
        tueStartTime.text = AppState.sharedInstance.activeSpot.tueStartTime
        tueEndTime.text = AppState.sharedInstance.activeSpot.tueEndTime
        wedStartTime.text = AppState.sharedInstance.activeSpot.wedStartTime
        wedEndTime.text = AppState.sharedInstance.activeSpot.wedEndTime
        thuStartTime.text = AppState.sharedInstance.activeSpot.thuStartTime
        thuEndTime.text = AppState.sharedInstance.activeSpot.thuEndTime
        friStartTime.text = AppState.sharedInstance.activeSpot.friStartTime
        friEndTime.text = AppState.sharedInstance.activeSpot.friEndTime
        satStartTime.text = AppState.sharedInstance.activeSpot.satStartTime
        satEndTime.text = AppState.sharedInstance.activeSpot.satEndTime
        sunStartTime.text = AppState.sharedInstance.activeSpot.sunStartTime
        sunEndTime.text = AppState.sharedInstance.activeSpot.sunEndTime
        
        monSwitch.setOn(AppState.sharedInstance.activeSpot.monOn, animated: true)
        tueSwitch.setOn(AppState.sharedInstance.activeSpot.tueOn, animated: true)
        wedSwitch.setOn(AppState.sharedInstance.activeSpot.wedOn, animated: true)
        thuSwitch.setOn(AppState.sharedInstance.activeSpot.thuOn, animated: true)
        friSwitch.setOn(AppState.sharedInstance.activeSpot.friOn, animated: true)
        satSwitch.setOn(AppState.sharedInstance.activeSpot.satOn, animated: true)
        sunSwitch.setOn(AppState.sharedInstance.activeSpot.sunOn, animated: true)
        
     }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
   // Monday
    @objc func monStartDatePickerValueChanged(_ sender: UIDatePicker) {
        //        let DatePickerView: UIDatePicker = UIDatePicker()
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "hh:mm a"
        AppState.sharedInstance.activeSpot.monStartTime = dateFormatter.string(from: sender.date)
        monStartTime.text = AppState.sharedInstance.activeSpot.monStartTime
    }
    
    @objc func monEndDatePickerValueChanged(_ sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSTIX")
        dateFormatter.dateFormat = "hh:mm a"
        AppState.sharedInstance.activeSpot.monEndTime = dateFormatter.string(from: sender.date)
        monEndTime.text = AppState.sharedInstance.activeSpot.monEndTime
    }
    
    @objc func monSwitchStateChanged(switchState: UISwitch) {
        AppState.sharedInstance.activeSpot.monOn = switchState.isOn
        
        if switchState.isOn {
            AppState.sharedInstance.activeSpot.monStartTime = "12:00 AM"
            AppState.sharedInstance.activeSpot.monEndTime = "12:00 PM"
        }
        else {
            AppState.sharedInstance.activeSpot.monStartTime = ""
            AppState.sharedInstance.activeSpot.monEndTime = ""
        }
        
        monStartTime.isEnabled = AppState.sharedInstance.activeSpot.monOn
        monEndTime.isEnabled = AppState.sharedInstance.activeSpot.monOn
        monStartTime.text = AppState.sharedInstance.activeSpot.monStartTime
        monEndTime.text = AppState.sharedInstance.activeSpot.monEndTime
    }
    
    
    // Tuesday
    @objc func tueStartDatePickerValueChanged(_ sender: UIDatePicker) {
        //        let DatePickerView: UIDatePicker = UIDatePicker()
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "hh:mm a"
        AppState.sharedInstance.activeSpot.tueStartTime = dateFormatter.string(from: sender.date)
        tueStartTime.text = AppState.sharedInstance.activeSpot.tueStartTime
    }
    
    @objc func tueEndDatePickerValueChanged(_ sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSTIX")
        dateFormatter.dateFormat = "hh:mm a"
        AppState.sharedInstance.activeSpot.tueEndTime = dateFormatter.string(from: sender.date)
        tueEndTime.text = AppState.sharedInstance.activeSpot.tueEndTime
    }
    
    @objc func tueSwitchStateChanged(switchState: UISwitch) {
        AppState.sharedInstance.activeSpot.tueOn = switchState.isOn
        
        if switchState.isOn {
            AppState.sharedInstance.activeSpot.tueStartTime = "12:00 AM"
            AppState.sharedInstance.activeSpot.tueEndTime = "12:00 PM"
        }
        else {
            AppState.sharedInstance.activeSpot.tueStartTime = ""
            AppState.sharedInstance.activeSpot.tueEndTime = ""
        }
        
        tueStartTime.isEnabled = AppState.sharedInstance.activeSpot.tueOn
        tueEndTime.isEnabled = AppState.sharedInstance.activeSpot.tueOn
        tueStartTime.text = AppState.sharedInstance.activeSpot.tueStartTime
        tueEndTime.text = AppState.sharedInstance.activeSpot.tueEndTime
    }
    
    // Wednesday
    @objc func wedStartDatePickerValueChanged(_ sender: UIDatePicker) {
        //        let DatePickerView: UIDatePicker = UIDatePicker()
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "hh:mm a"
        AppState.sharedInstance.activeSpot.wedStartTime = dateFormatter.string(from: sender.date)
        wedStartTime.text = AppState.sharedInstance.activeSpot.wedStartTime
    }
    
    @objc func wedEndDatePickerValueChanged(_ sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSTIX")
        dateFormatter.dateFormat = "hh:mm a"
        AppState.sharedInstance.activeSpot.wedEndTime = dateFormatter.string(from: sender.date)
        wedEndTime.text = AppState.sharedInstance.activeSpot.wedEndTime
    }
    
    @objc func wedSwitchStateChanged(switchState: UISwitch) {
        AppState.sharedInstance.activeSpot.wedOn = switchState.isOn
        
        if switchState.isOn {
            AppState.sharedInstance.activeSpot.wedStartTime = "12:00 AM"
            AppState.sharedInstance.activeSpot.wedEndTime = "12:00 PM"
        }
        else {
            AppState.sharedInstance.activeSpot.wedStartTime = ""
            AppState.sharedInstance.activeSpot.wedEndTime = ""
        }
        
        wedStartTime.isEnabled = AppState.sharedInstance.activeSpot.wedOn
        wedEndTime.isEnabled = AppState.sharedInstance.activeSpot.wedOn
        wedStartTime.text = AppState.sharedInstance.activeSpot.wedStartTime
        wedEndTime.text = AppState.sharedInstance.activeSpot.wedEndTime
    }
    
    // Thursday
    @objc func thuStartDatePickerValueChanged(_ sender: UIDatePicker) {
        //        let DatePickerView: UIDatePicker = UIDatePicker()
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "hh:mm a"
        AppState.sharedInstance.activeSpot.thuStartTime = dateFormatter.string(from: sender.date)
        thuStartTime.text = AppState.sharedInstance.activeSpot.thuStartTime
    }
    
    @objc func thuEndDatePickerValueChanged(_ sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSTIX")
        dateFormatter.dateFormat = "hh:mm a"
        AppState.sharedInstance.activeSpot.thuEndTime = dateFormatter.string(from: sender.date)
        thuEndTime.text = AppState.sharedInstance.activeSpot.thuEndTime
    }
    
    @objc func thuSwitchStateChanged(switchState: UISwitch) {
        AppState.sharedInstance.activeSpot.thuOn = switchState.isOn
        
        if switchState.isOn {
            AppState.sharedInstance.activeSpot.thuStartTime = "12:00 AM"
            AppState.sharedInstance.activeSpot.thuEndTime = "12:00 PM"
        }
        else {
            AppState.sharedInstance.activeSpot.thuStartTime = ""
            AppState.sharedInstance.activeSpot.thuEndTime = ""
        }
        
        thuStartTime.isEnabled = AppState.sharedInstance.activeSpot.thuOn
        thuEndTime.isEnabled = AppState.sharedInstance.activeSpot.thuOn
        thuStartTime.text = AppState.sharedInstance.activeSpot.thuStartTime
        thuEndTime.text = AppState.sharedInstance.activeSpot.thuEndTime
    }
    
    // Friday
    @objc func friStartDatePickerValueChanged(_ sender: UIDatePicker) {
        //        let DatePickerView: UIDatePicker = UIDatePicker()
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "hh:mm a"
        AppState.sharedInstance.activeSpot.friStartTime = dateFormatter.string(from: sender.date)
        friStartTime.text = AppState.sharedInstance.activeSpot.friStartTime
    }
    
    @objc func friEndDatePickerValueChanged(_ sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSTIX")
        dateFormatter.dateFormat = "hh:mm a"
        AppState.sharedInstance.activeSpot.friEndTime = dateFormatter.string(from: sender.date)
        friEndTime.text = AppState.sharedInstance.activeSpot.friEndTime
    }
    
    @objc func friSwitchStateChanged(switchState: UISwitch) {
        AppState.sharedInstance.activeSpot.friOn = switchState.isOn
        
        if switchState.isOn {
            AppState.sharedInstance.activeSpot.friStartTime = "12:00 AM"
            AppState.sharedInstance.activeSpot.friEndTime = "12:00 PM"
        }
        else {
            AppState.sharedInstance.activeSpot.friStartTime = ""
            AppState.sharedInstance.activeSpot.friEndTime = ""
        }
        
        friStartTime.isEnabled = AppState.sharedInstance.activeSpot.friOn
        friEndTime.isEnabled = AppState.sharedInstance.activeSpot.friOn
        friStartTime.text = AppState.sharedInstance.activeSpot.friStartTime
        friEndTime.text = AppState.sharedInstance.activeSpot.friEndTime
    }
    
    // Saturday
    @objc func satStartDatePickerValueChanged(_ sender: UIDatePicker) {
        //        let DatePickerView: UIDatePicker = UIDatePicker()
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "hh:mm a"
        AppState.sharedInstance.activeSpot.satStartTime = dateFormatter.string(from: sender.date)
        satStartTime.text = AppState.sharedInstance.activeSpot.satStartTime
    }
    
    @objc func satEndDatePickerValueChanged(_ sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSTIX")
        dateFormatter.dateFormat = "hh:mm a"
        AppState.sharedInstance.activeSpot.satEndTime = dateFormatter.string(from: sender.date)
        satEndTime.text = AppState.sharedInstance.activeSpot.satEndTime
    }
    
    @objc func satSwitchStateChanged(switchState: UISwitch) {
        AppState.sharedInstance.activeSpot.satOn = switchState.isOn
        
        if switchState.isOn {
            AppState.sharedInstance.activeSpot.satStartTime = "12:00 AM"
            AppState.sharedInstance.activeSpot.satEndTime = "12:00 PM"
        }
        else {
            AppState.sharedInstance.activeSpot.satStartTime = ""
            AppState.sharedInstance.activeSpot.satEndTime = ""
        }
        
        satStartTime.isEnabled = AppState.sharedInstance.activeSpot.satOn
        satEndTime.isEnabled = AppState.sharedInstance.activeSpot.satOn
        satStartTime.text = AppState.sharedInstance.activeSpot.satStartTime
        satEndTime.text = AppState.sharedInstance.activeSpot.satEndTime
    }
    
    // Sunday
    @objc func sunStartDatePickerValueChanged(_ sender: UIDatePicker) {
        //        let DatePickerView: UIDatePicker = UIDatePicker()
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "hh:mm a"
        AppState.sharedInstance.activeSpot.sunStartTime = dateFormatter.string(from: sender.date)
        sunStartTime.text = AppState.sharedInstance.activeSpot.sunStartTime
    }
    
    @objc func sunEndDatePickerValueChanged(_ sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSTIX")
        dateFormatter.dateFormat = "hh:mm a"
        AppState.sharedInstance.activeSpot.sunEndTime = dateFormatter.string(from: sender.date)
        sunEndTime.text = AppState.sharedInstance.activeSpot.sunEndTime
    }
    
    @objc func sunSwitchStateChanged(switchState: UISwitch) {
        AppState.sharedInstance.activeSpot.sunOn = switchState.isOn
        
        if switchState.isOn {
            AppState.sharedInstance.activeSpot.sunStartTime = "12:00 AM"
            AppState.sharedInstance.activeSpot.sunEndTime = "12:00 PM"
        }
        else {
            AppState.sharedInstance.activeSpot.sunStartTime = ""
            AppState.sharedInstance.activeSpot.sunEndTime = ""
        }
        
        sunStartTime.isEnabled = AppState.sharedInstance.activeSpot.sunOn
        sunEndTime.isEnabled = AppState.sharedInstance.activeSpot.sunOn
        sunStartTime.text = AppState.sharedInstance.activeSpot.sunStartTime
        sunEndTime.text = AppState.sharedInstance.activeSpot.sunEndTime
    }
    
}
