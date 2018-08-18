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
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    @IBAction func monStartValueChanged(_ sender: Any) {
//        let DatePickerView: UIDatePicker = UIDatePicker()
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "hh:mm"
//        monStartTime.text = dateFormatter.string(from: DatePickerView.date)
//    }
    
    // Monday
    @objc func monStartDatePickerValueChanged(_ sender: UIDatePicker) {
//        let DatePickerView: UIDatePicker = UIDatePicker()
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "hh:mm a"
        monStartTime.text = dateFormatter.string(from: sender.date)
    }
    
    @objc func monEndDatePickerValueChanged(_ sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSTIX")
        dateFormatter.dateFormat = "hh:mm a"
        monEndTime.text = dateFormatter.string(from: sender.date)
    }
    
    @objc func monSwitchStateChanged(switchState: UISwitch) {
        if switchState.isOn {
            monStartTime.isEnabled = true
            monEndTime.isEnabled = true
            monStartTime.text = "12:00 AM"
            monEndTime.text = "12:00 PM"
        }
        else {
            monStartTime.isEnabled = false
            monEndTime.isEnabled = false
            monStartTime.text = ""
            monEndTime.text = ""
        }
    }
    
    
    // Tuesday
    @objc func tueStartDatePickerValueChanged(_ sender: UIDatePicker) {
        //        let DatePickerView: UIDatePicker = UIDatePicker()
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "hh:mm a"
        tueStartTime.text = dateFormatter.string(from: sender.date)
    }
    
    @objc func tueEndDatePickerValueChanged(_ sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSTIX")
        dateFormatter.dateFormat = "hh:mm a"
        tueEndTime.text = dateFormatter.string(from: sender.date)
    }
    
    @objc func tueSwitchStateChanged(switchState: UISwitch) {
        if switchState.isOn {
            tueStartTime.isEnabled = true
            tueEndTime.isEnabled = true
            tueStartTime.text = "12:00 AM"
            tueEndTime.text = "12:00 PM"
        }
        else {
            tueStartTime.isEnabled = false
            tueEndTime.isEnabled = false
            tueStartTime.text = ""
            tueEndTime.text = ""
        }
    }
    
    // Wednesday
    @objc func wedStartDatePickerValueChanged(_ sender: UIDatePicker) {
        //        let DatePickerView: UIDatePicker = UIDatePicker()
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "hh:mm a"
        wedStartTime.text = dateFormatter.string(from: sender.date)
    }
    
    @objc func wedEndDatePickerValueChanged(_ sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSTIX")
        dateFormatter.dateFormat = "hh:mm a"
        wedEndTime.text = dateFormatter.string(from: sender.date)
    }
    
    @objc func wedSwitchStateChanged(switchState: UISwitch) {
        if switchState.isOn {
            wedStartTime.isEnabled = true
            wedEndTime.isEnabled = true
            wedStartTime.text = "12:00 AM"
            wedEndTime.text = "12:00 PM"
        }
        else {
            wedStartTime.isEnabled = false
            wedEndTime.isEnabled = false
            wedStartTime.text = ""
            wedEndTime.text = ""
        }
    }
    
    // Thursday
    @objc func thuStartDatePickerValueChanged(_ sender: UIDatePicker) {
        //        let DatePickerView: UIDatePicker = UIDatePicker()
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "hh:mm a"
        thuStartTime.text = dateFormatter.string(from: sender.date)
    }
    
    @objc func thuEndDatePickerValueChanged(_ sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSTIX")
        dateFormatter.dateFormat = "hh:mm a"
        thuEndTime.text = dateFormatter.string(from: sender.date)
    }
    
    @objc func thuSwitchStateChanged(switchState: UISwitch) {
        if switchState.isOn {
            thuStartTime.isEnabled = true
            thuEndTime.isEnabled = true
            thuStartTime.text = "12:00 AM"
            thuEndTime.text = "12:00 PM"
        }
        else {
            thuStartTime.isEnabled = false
            thuEndTime.isEnabled = false
            thuStartTime.text = ""
            thuEndTime.text = ""
        }
    }
    
    // Friday
    @objc func friStartDatePickerValueChanged(_ sender: UIDatePicker) {
        //        let DatePickerView: UIDatePicker = UIDatePicker()
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "hh:mm a"
        friStartTime.text = dateFormatter.string(from: sender.date)
    }
    
    @objc func friEndDatePickerValueChanged(_ sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSTIX")
        dateFormatter.dateFormat = "hh:mm a"
        friEndTime.text = dateFormatter.string(from: sender.date)
    }
    
    @objc func friSwitchStateChanged(switchState: UISwitch) {
        if switchState.isOn {
            friStartTime.isEnabled = true
            friEndTime.isEnabled = true
            friStartTime.text = "12:00 AM"
            friEndTime.text = "12:00 PM"
        }
        else {
            friStartTime.isEnabled = false
            friEndTime.isEnabled = false
            friStartTime.text = ""
            friEndTime.text = ""
        }
    }
    
    // Saturday
    @objc func satStartDatePickerValueChanged(_ sender: UIDatePicker) {
        //        let DatePickerView: UIDatePicker = UIDatePicker()
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "hh:mm a"
        satStartTime.text = dateFormatter.string(from: sender.date)
    }
    
    @objc func satEndDatePickerValueChanged(_ sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSTIX")
        dateFormatter.dateFormat = "hh:mm a"
        satEndTime.text = dateFormatter.string(from: sender.date)
    }
    
    @objc func satSwitchStateChanged(switchState: UISwitch) {
        if switchState.isOn {
            satStartTime.isEnabled = true
            satEndTime.isEnabled = true
            satStartTime.text = "12:00 AM"
            satEndTime.text = "12:00 PM"
        }
        else {
            satStartTime.isEnabled = false
            satEndTime.isEnabled = false
            satStartTime.text = ""
            satEndTime.text = ""
        }
    }
    
    // Sunday
    @objc func sunStartDatePickerValueChanged(_ sender: UIDatePicker) {
        //        let DatePickerView: UIDatePicker = UIDatePicker()
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "hh:mm a"
        sunStartTime.text = dateFormatter.string(from: sender.date)
    }
    
    @objc func sunEndDatePickerValueChanged(_ sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSTIX")
        dateFormatter.dateFormat = "hh:mm a"
        sunEndTime.text = dateFormatter.string(from: sender.date)
    }
    
    @objc func sunSwitchStateChanged(switchState: UISwitch) {
        if switchState.isOn {
            sunStartTime.isEnabled = true
            sunEndTime.isEnabled = true
            sunStartTime.text = "12:00 AM"
            sunEndTime.text = "12:00 PM"
        }
        else {
            sunStartTime.isEnabled = false
            sunEndTime.isEnabled = false
            sunStartTime.text = ""
            sunEndTime.text = ""
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
