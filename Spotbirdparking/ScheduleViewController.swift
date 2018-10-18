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
        
        monStartTime.autocorrectionType  = .no
        monEndTime.autocorrectionType = .no
        tueStartTime.autocorrectionType = .no
        tueEndTime.autocorrectionType = .no
        wedStartTime.autocorrectionType  = .no
        wedEndTime.autocorrectionType = .no
        thuStartTime.autocorrectionType = .no
        thuEndTime.autocorrectionType = .no
        friStartTime.autocorrectionType  = .no
        friEndTime.autocorrectionType = .no
        satStartTime.autocorrectionType = .no
        satEndTime.autocorrectionType = .no
        sunStartTime.autocorrectionType = .no
        sunEndTime.autocorrectionType = .no
        
         monStartTime.text = monstart
         monEndTime.text = monend
         tueStartTime.text = tuestart
         tueEndTime.text = tueend
         wedStartTime.text = wedstart
         wedEndTime.text = wedend
         thuStartTime.text = thustart
         thuEndTime.text = thustart
         friStartTime.text = fristart
         friEndTime.text = friend
         satStartTime.text = satstart
         satEndTime.text = satend
         sunStartTime.text = sunstart
         sunEndTime.text = sunend
       
        
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
        
          AppState.sharedInstance.dict_spot.setValue(monSwitch.isOn, forKey: "monswitch")
          AppState.sharedInstance.dict_spot.setValue(tueSwitch.isOn, forKey: "tueswitch")
          AppState.sharedInstance.dict_spot.setValue(wedSwitch.isOn, forKey: "wedswitch")
          AppState.sharedInstance.dict_spot.setValue(thuSwitch.isOn, forKey: "thuswitch")
          AppState.sharedInstance.dict_spot.setValue(friSwitch.isOn, forKey: "friswitch")
          AppState.sharedInstance.dict_spot.setValue(satSwitch.isOn, forKey: "satswitch")
          AppState.sharedInstance.dict_spot.setValue(sunSwitch.isOn, forKey: "sunswitch")

        
        AppState.sharedInstance.dict_spot.setValue("12:00 PM", forKey: "monStartTime")
        AppState.sharedInstance.dict_spot.setValue("12:00 AM", forKey: "monEndTime")
        AppState.sharedInstance.dict_spot.setValue("12:00 PM", forKey: "tueStartTime")
        AppState.sharedInstance.dict_spot.setValue("12:00 AM", forKey: "tueEndTime")
        AppState.sharedInstance.dict_spot.setValue("12:00 PM", forKey: "wedStartTime")
        AppState.sharedInstance.dict_spot.setValue("12:00 AM", forKey: "wedEndTime")
        AppState.sharedInstance.dict_spot.setValue("12:00 PM", forKey: "thuStartTime")
        AppState.sharedInstance.dict_spot.setValue("12:00 AM", forKey: "thuEndTime")
        AppState.sharedInstance.dict_spot.setValue("12:00 PM", forKey: "friStartTime")
        AppState.sharedInstance.dict_spot.setValue("12:00 AM", forKey: "friEndTime")
        AppState.sharedInstance.dict_spot.setValue("12:00 PM", forKey: "satStartTime")
        AppState.sharedInstance.dict_spot.setValue("12:00 AM", forKey: "satEndTime")
        AppState.sharedInstance.dict_spot.setValue("12:00 PM", forKey: "sunStartTime")
        AppState.sharedInstance.dict_spot.setValue("12:00 AM", forKey: "sunEndTime")
        
        AppState.sharedInstance.activeSpot.pringSpotCliffNotes()
        print(AppState.sharedInstance.dict_spot)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
      
    }
 
    
    // Monday
    @objc func monStartDatePickerValueChanged(_ sender: UIDatePicker) {
//        let DatePickerView: UIDatePicker = UIDatePicker()
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "hh:mm a"

         AppState.sharedInstance.dict_spot.setValue(dateFormatter.string(from: sender.date), forKey: "monStartTime")
         monStartTime.text = AppState.sharedInstance.dict_spot.value(forKey: "monStartTime") as? String
        
    }
    
    @objc func monEndDatePickerValueChanged(_ sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSTIX")
        dateFormatter.dateFormat = "hh:mm a"

        AppState.sharedInstance.dict_spot.setValue(dateFormatter.string(from: sender.date), forKey: "monEndTime")
        monEndTime.text  = AppState.sharedInstance.dict_spot.value(forKey: "monEndTime") as? String
    }
    
    @objc func monSwitchStateChanged(switchState: UISwitch) {

        AppState.sharedInstance.dict_spot.setValue(switchState.isOn, forKey: "monswitch")
        
        if switchState.isOn {

              AppState.sharedInstance.dict_spot.setValue("12:00 PM", forKey: "monStartTime")
             AppState.sharedInstance.dict_spot.setValue("12:00 AM", forKey: "monEndTime")
    
        }
        else {

            AppState.sharedInstance.dict_spot.setValue("", forKey: "monStartTime")
            AppState.sharedInstance.dict_spot.setValue("", forKey: "monEndTime")
        }
        

        monStartTime.isEnabled = ((AppState.sharedInstance.dict_spot.value(forKey: "monswitch") as? String) != nil)
        monEndTime.isEnabled = ((AppState.sharedInstance.dict_spot.value(forKey: "monswitch") as? String) != nil)
        monStartTime.text = AppState.sharedInstance.dict_spot.value(forKey: "monStartTime") as? String
        monEndTime.text  = AppState.sharedInstance.dict_spot.value(forKey: "monEndTime") as? String
    }
    
    
    // Tuesday
    @objc func tueStartDatePickerValueChanged(_ sender: UIDatePicker) {
        //        let DatePickerView: UIDatePicker = UIDatePicker()
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "hh:mm a"
 AppState.sharedInstance.dict_spot.setValue(dateFormatter.string(from: sender.date), forKey: "tueStartTime")
        tueStartTime.text  = AppState.sharedInstance.dict_spot.value(forKey: "tueStartTime") as? String
    }
    
    @objc func tueEndDatePickerValueChanged(_ sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSTIX")
        dateFormatter.dateFormat = "hh:mm a"

        AppState.sharedInstance.dict_spot.setValue(dateFormatter.string(from: sender.date), forKey: "tueEndTime")
       tueEndTime.text  = AppState.sharedInstance.dict_spot.value(forKey: "tueEndTime") as? String
    }
    
    @objc func tueSwitchStateChanged(switchState: UISwitch) {
      //  AppState.sharedInstance.activeSpot.tueOn = switchState.isOnnce.dict_spot.setValue(switchState.isOn, forKey: "tueswitch")
        
        if switchState.isOn {

            AppState.sharedInstance.dict_spot.setValue("12:00 PM", forKey: "tueStartTime")
            AppState.sharedInstance.dict_spot.setValue("12:00 AM", forKey: "tueEndTime")
        }
        else {
//            AppState.sharedInstance.activeSpot.tueStartTime = ""
//            AppState.sharedInstance.activeSpot.tueEndTime = ""
            AppState.sharedInstance.dict_spot.setValue("12:00 PM", forKey: "tueStartTime")
            AppState.sharedInstance.dict_spot.setValue("12:00 AM", forKey: "tueEndTime")
        }
        

        
        tueStartTime.isEnabled = (AppState.sharedInstance.dict_spot.value(forKey: "tueswitch") as? Bool)!
        tueEndTime.isEnabled = (AppState.sharedInstance.dict_spot.value(forKey: "tueswitch") as? Bool)!
        tueStartTime.text = AppState.sharedInstance.dict_spot.value(forKey: "tueStartTime") as? String
        tueEndTime.text  = AppState.sharedInstance.dict_spot.value(forKey: "tueEndTime") as? String
    }
    
    // Wednesday
    @objc func wedStartDatePickerValueChanged(_ sender: UIDatePicker) {
        //        let DatePickerView: UIDatePicker = UIDatePicker()
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "hh:mm a"
//        AppState.sharedInstance.activeSpot.wedStartTime = dateFormatter.string(from: sender.date)
//        wedStartTime.text = AppState.sharedInstance.activeSpot.wedStartTime
        
        AppState.sharedInstance.dict_spot.setValue(dateFormatter.string(from: sender.date), forKey: "wedStartTime")
        wedStartTime.text  = AppState.sharedInstance.dict_spot.value(forKey: "wedStartTime") as? String
    }
    
    @objc func wedEndDatePickerValueChanged(_ sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSTIX")
        dateFormatter.dateFormat = "hh:mm a"
  AppState.sharedInstance.dict_spot.setValue(dateFormatter.string(from: sender.date), forKey: "wedEndTime")
        wedEndTime.text  = AppState.sharedInstance.dict_spot.value(forKey: "wedEndTime") as? String
    }
    
    @objc func wedSwitchStateChanged(switchState: UISwitch) {
      //  AppState.sharedInstance.activeSpot.wedOn = switchState.isOn
    AppState.sharedInstance.dict_spot.setValue(switchState.isOn, forKey: "wedswitch")
        
        if switchState.isOn {
//            AppState.sharedInstance.activeSpot.wedStartTime = "12:00 AM"
//            AppState.sharedInstance.activeSpot.wedEndTime = "12:00 PM"
            AppState.sharedInstance.dict_spot.setValue("12:00 PM", forKey: "wedStartTime")
            AppState.sharedInstance.dict_spot.setValue("12:00 AM", forKey: "wedEndTime")
        }
        else {

            AppState.sharedInstance.dict_spot.setValue("", forKey: "wedStartTime")
            AppState.sharedInstance.dict_spot.setValue("", forKey: "wedEndTime")
        }

        wedStartTime.isEnabled = (AppState.sharedInstance.dict_spot.value(forKey: "wedswitch")  as? Bool)!
        wedEndTime.isEnabled = (AppState.sharedInstance.dict_spot.value(forKey: "wedswitch")  as? Bool)!
        wedStartTime.text = AppState.sharedInstance.dict_spot.value(forKey: "wedStartTime") as? String
        wedEndTime.text  = AppState.sharedInstance.dict_spot.value(forKey: "wedEndTime") as? String
    }
    
    // Thursday
    @objc func thuStartDatePickerValueChanged(_ sender: UIDatePicker) {
        //        let DatePickerView: UIDatePicker = UIDatePicker()
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "hh:mm a"
//        AppState.sharedInstance.activeSpot.thuStartTime = dateFormatter.string(from: sender.date)
//        thuStartTime.text = AppState.sharedInstance.activeSpot.thuStartTime
        AppState.sharedInstance.dict_spot.setValue(dateFormatter.string(from: sender.date), forKey: "thuStartTime")
        thuStartTime.text  = AppState.sharedInstance.dict_spot.value(forKey: "thuStartTime") as? String
    }
    
    @objc func thuEndDatePickerValueChanged(_ sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSTIX")
        dateFormatter.dateFormat = "hh:mm a"
//        AppState.sharedInstance.activeSpot.thuEndTime = dateFormatter.string(from: sender.date)
//        thuEndTime.text = AppState.sharedInstance.activeSpot.thuEndTime
        AppState.sharedInstance.dict_spot.setValue(dateFormatter.string(from: sender.date), forKey: "thuEndTime")
        thuEndTime.text  = AppState.sharedInstance.dict_spot.value(forKey: "thuEndTime") as? String
    }
    
    @objc func thuSwitchStateChanged(switchState: UISwitch) {

         AppState.sharedInstance.dict_spot.setValue(switchState.isOn, forKey: "thuswitch")
        
        if switchState.isOn {

            AppState.sharedInstance.dict_spot.setValue("12:00 PM", forKey: "thuStartTime")
            AppState.sharedInstance.dict_spot.setValue("12:00 AM", forKey: "thuEndTime")
        }
        else {

            AppState.sharedInstance.dict_spot.setValue("", forKey: "thuStartTime")
            AppState.sharedInstance.dict_spot.setValue("", forKey: "thuEndTime")
        }
        

        thuStartTime.isEnabled = (AppState.sharedInstance.dict_spot.value(forKey: "thuswitch")  as? Bool)!
        thuEndTime.isEnabled = (AppState.sharedInstance.dict_spot.value(forKey: "thuswitch")  as? Bool)!
        thuStartTime.text = AppState.sharedInstance.dict_spot.value(forKey: "thuStartTime") as? String
        thuEndTime.text = AppState.sharedInstance.dict_spot.value(forKey: "thuEndTime") as? String
    }
    
    // Friday
    @objc func friStartDatePickerValueChanged(_ sender: UIDatePicker) {
        //        let DatePickerView: UIDatePicker = UIDatePicker()
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "hh:mm a"
//        AppState.sharedInstance.activeSpot.friStartTime = dateFormatter.string(from: sender.date)
//        friStartTime.text = AppState.sharedInstance.activeSpot.friStartTime
        AppState.sharedInstance.dict_spot.setValue(dateFormatter.string(from: sender.date), forKey: "friStartTime")
        friStartTime.text = AppState.sharedInstance.dict_spot.value(forKey: "friStartTime") as? String
    }
    
    @objc func friEndDatePickerValueChanged(_ sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSTIX")
        dateFormatter.dateFormat = "hh:mm a"
//        AppState.sharedInstance.activeSpot.friEndTime = dateFormatter.string(from: sender.date)
//        friEndTime.text = AppState.sharedInstance.activeSpot.friEndTime
        AppState.sharedInstance.dict_spot.setValue(dateFormatter.string(from: sender.date), forKey: "friEndTime")
        friEndTime.text = AppState.sharedInstance.dict_spot.value(forKey: "friEndTime") as? String
    }
    
    @objc func friSwitchStateChanged(switchState: UISwitch) {

        AppState.sharedInstance.dict_spot.setValue(switchState.isOn, forKey: "friswitch")
        
        if switchState.isOn {

            AppState.sharedInstance.dict_spot.setValue("12:00 PM", forKey: "friStartTime")
            AppState.sharedInstance.dict_spot.setValue("12:00 AM", forKey: "friEndTime")
        }
        else {

            AppState.sharedInstance.dict_spot.setValue("", forKey: "friStartTime")
            AppState.sharedInstance.dict_spot.setValue("", forKey: "friEndTime")
        }
        
        friStartTime.isEnabled = (AppState.sharedInstance.dict_spot.value(forKey: "friswitch")  as? Bool)!
        friEndTime.isEnabled = (AppState.sharedInstance.dict_spot.value(forKey: "friswitch") as? Bool)!
        friStartTime.text = AppState.sharedInstance.dict_spot.value(forKey: "friStartTime") as? String
        friEndTime.text = AppState.sharedInstance.dict_spot.value(forKey: "friEndTime") as? String
    }
    
    // Saturday
    @objc func satStartDatePickerValueChanged(_ sender: UIDatePicker) {
        //        let DatePickerView: UIDatePicker = UIDatePicker()
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "hh:mm a"
     //   AppState.sharedInstance.activeSpot.satStartTime = dateFormatter.string(from: sender.date)
        //satStartTime.text = AppState.sharedInstance.activeSpot.satStartTime
        
        AppState.sharedInstance.dict_spot.setValue(dateFormatter.string(from: sender.date), forKey: "satStartTime")
        friStartTime.text = AppState.sharedInstance.dict_spot.value(forKey: "satStartTime") as? String
    }
    
    @objc func satEndDatePickerValueChanged(_ sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSTIX")
        dateFormatter.dateFormat = "hh:mm a"

        AppState.sharedInstance.dict_spot.setValue(dateFormatter.string(from: sender.date), forKey: "satEndTime")
        satEndTime.text = AppState.sharedInstance.dict_spot.value(forKey: "satEndTime") as? String
    }
    
    @objc func satSwitchStateChanged(switchState: UISwitch) {
      //  AppState.sharedInstance.activeSpot.satOn = switchState.isOn
           AppState.sharedInstance.dict_spot.setValue(switchState.isOn, forKey: "satswitch")
        
        if switchState.isOn {

      AppState.sharedInstance.dict_spot.setValue("12:00 PM", forKey: "satStartTime")
      AppState.sharedInstance.dict_spot.setValue("12:00 AM", forKey: "satEndTime")
        }
        else {

            AppState.sharedInstance.dict_spot.setValue("", forKey: "satStartTime")
            AppState.sharedInstance.dict_spot.setValue("", forKey: "satEndTime")
        }

        satStartTime.isEnabled = (AppState.sharedInstance.dict_spot.value(forKey: "satswitch") as? Bool)!
        satEndTime.isEnabled = (AppState.sharedInstance.dict_spot.value(forKey: "satswitch") as? Bool)!
        satStartTime.text = AppState.sharedInstance.dict_spot.value(forKey: "satStartTime") as? String
        satEndTime.text = AppState.sharedInstance.dict_spot.value(forKey: "satEndTime") as? String
    }
    
    // Sunday
    @objc func sunStartDatePickerValueChanged(_ sender: UIDatePicker) {
        //        let DatePickerView: UIDatePicker = UIDatePicker()
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "hh:mm a"
//        AppState.sharedInstance.activeSpot.sunStartTime = dateFormatter.string(from: sender.date)
//        sunStartTime.text = AppState.sharedInstance.activeSpot.sunStartTime
        
        AppState.sharedInstance.dict_spot.setValue(dateFormatter.string(from: sender.date), forKey: "sunStartTime")
        sunStartTime.text = AppState.sharedInstance.dict_spot.value(forKey: "sunStartTime") as? String
    }
    
    @objc func sunEndDatePickerValueChanged(_ sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSTIX")
        dateFormatter.dateFormat = "hh:mm a"
//        AppState.sharedInstance.activeSpot.sunEndTime = dateFormatter.string(from: sender.date)
//        sunEndTime.text = AppState.sharedInstance.activeSpot.sunEndTime
        AppState.sharedInstance.dict_spot.setValue(dateFormatter.string(from: sender.date), forKey: "sunEndTime")
        sunEndTime.text = AppState.sharedInstance.dict_spot.value(forKey: "sunEndTime") as! String
    }
    
    @objc func sunSwitchStateChanged(switchState: UISwitch) {
     //   AppState.sharedInstance.activeSpot.sunOn = switchState.isOn
        
          AppState.sharedInstance.dict_spot.setValue(switchState.isOn, forKey: "sunswitch")
        
        if switchState.isOn {
  AppState.sharedInstance.dict_spot.setValue("12:00 PM", forKey: "sunStartTime")
              AppState.sharedInstance.dict_spot.setValue("12:00 AM", forKey: "sunEndTime")
        }
        else {

            AppState.sharedInstance.dict_spot.setValue("", forKey: "sunStartTime")
            AppState.sharedInstance.dict_spot.setValue("", forKey: "sunEndTime")
        }
        
        sunStartTime.isEnabled = AppState.sharedInstance.dict_spot.value(forKey: "sunswitch") as! Bool
        sunEndTime.isEnabled = AppState.sharedInstance.dict_spot.value(forKey: "sunswitch") as! Bool
        sunStartTime.text = AppState.sharedInstance.dict_spot.value(forKey: "sunStartTime") as? String
        sunEndTime.text = AppState.sharedInstance.dict_spot.value(forKey: "sunEndTime") as? String
    }

}
