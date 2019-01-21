//
//  PriceViewController.swift
//  Spotbirdparking
//
//  Created by user138340 on 8/22/18.
//  Copyright © 2018 Spotbird. All rights reserved.
//

import UIKit
import Photos
import Firebase
import CoreLocation

class PriceViewController: UIViewController, UITextFieldDelegate,CLLocationManagerDelegate,TNSliderDelegate{
    
//    @IBOutlet weak var hourlyPricing: UITextField!
//    @IBOutlet weak var dailyPricing: UITextField!
//    @IBOutlet weak var weeklyPricing: UITextField!
//    @IBOutlet weak var monthlyPricing: UITextField!
    @IBOutlet weak var weeklyPricingOn: UISwitch!
    @IBOutlet weak var monthlyPricingOn: UISwitch!
    
       @IBOutlet weak var slider1: TNSlider!
       @IBOutlet weak var slider2: TNSlider!
       @IBOutlet weak var slider3: TNSlider!
       @IBOutlet weak var slider4: TNSlider!
    
    @IBOutlet weak var lbl1: UILabel!
    @IBOutlet weak var lbl2: UILabel!
    @IBOutlet weak var lbl3: UILabel!
    @IBOutlet weak var lbl4: UILabel!
    
    var controller = " "
    var refArtists: DatabaseReference!
    var locationManager = CLLocationManager()
    
        var value1 = ""
        var value2 = ""
        var value3 = ""
        var value4 = ""
    
    var sw1 = ""
    var sw2 = ""
    
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        hourlyPricing.delegate = self
//        monthlyPricing.delegate = self
//        weeklyPricing.delegate = self
//        dailyPricing.delegate = self
        
         self.hideKeyboardWhenTappedAround()
        
//        hourlyPricing.keyboardType = UIKeyboardType.decimalPad
//        dailyPricing.keyboardType = UIKeyboardType.decimalPad
//        weeklyPricing.keyboardType = UIKeyboardType.decimalPad
//        monthlyPricing.keyboardType = UIKeyboardType.decimalPad
        
        slider1.delegate = self
        slider2.delegate = self
        slider3.delegate = self
        slider4.delegate = self
 
        slider1.value = Float(AppState.sharedInstance.activeSpot.hourlyPricing)!
        slider2.value = Float(AppState.sharedInstance.activeSpot.dailyPricing)!
        slider3.value = Float(AppState.sharedInstance.activeSpot.weeklyPricing)!
        slider4.value = Float(AppState.sharedInstance.activeSpot.monthlyPricing)!
        
         lbl1.text = String(AppState.sharedInstance.user.avg1)
         lbl2.text = String(AppState.sharedInstance.user.avg2)
         lbl3.text = String(AppState.sharedInstance.user.avg3)
         lbl4.text = String(AppState.sharedInstance.user.avg4)
        
        weeklyPricingOn.addTarget(self, action: #selector(weeklyPricingSwitchChanged), for: UIControlEvents.valueChanged)
        monthlyPricingOn.addTarget(self, action: #selector(monthlyPricingSwitchChanged), for: UIControlEvents.valueChanged)
        
        
        slider1.minimum = 5
        slider1.maximum = 8
        slider2.minimum = 120
        slider2.maximum = 192
        slider3.minimum = 840
        slider3.maximum = 1344
        slider4.minimum = 3600
        slider4.maximum = 5760
        
        
        print((AppState.sharedInstance.activeSpot.monthlyPricing))
        
        }
    
    func slider(_ slider: TNSlider, displayTextForValue value: Float) -> String {
//        print(String(format: "%.2f%%", value))
//
//         print(String(value))
        
        return String(value)
    }
    
    @IBAction func sliderValueChanged(_ sender: TNSlider) {
        
       
        let value = Int(sender.value)
        
        if sender.tag == 101 {
         AppState.sharedInstance.activeSpot.hourlyPricing = String(value)
            value1 = "101"
            
        }
        else  if sender.tag  == 102 {
         AppState.sharedInstance.activeSpot.dailyPricing = String(value)
            value1 = "102"
        }
        else if sender.tag == 103{
         AppState.sharedInstance.activeSpot.weeklyPricing = String(value)
            value3 = "103"
            
            
        }else{
         AppState.sharedInstance.activeSpot.monthlyPricing = String(value)
               value4 = "104"
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
     }
    
   func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
//        if (textField == hourlyPricing) {
//            AppState.sharedInstance.activeSpot.hourlyPricing = hourlyPricing.text!
//        }
//        else if (textField == dailyPricing) {
//            AppState.sharedInstance.activeSpot.dailyPricing = dailyPricing.text!
//        }
//        else if (textField == weeklyPricing) {
//            AppState.sharedInstance.activeSpot.weeklyPricing = weeklyPricing.text!
//        }
//        else if (textField == monthlyPricing) {
//            AppState.sharedInstance.activeSpot.monthlyPricing = monthlyPricing.text!
//        }
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
//        if (textField == hourlyPricing) {
//            AppState.sharedInstance.activeSpot.hourlyPricing = hourlyPricing.text!
//        }
//        else if (textField == dailyPricing) {
//            AppState.sharedInstance.activeSpot.dailyPricing = dailyPricing.text!
//        }
//        else if (textField == weeklyPricing) {
//            AppState.sharedInstance.activeSpot.weeklyPricing = weeklyPricing.text!
//        }
//        else if (textField == monthlyPricing) {
//            AppState.sharedInstance.activeSpot.monthlyPricing = monthlyPricing.text!
//        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        hourlyPricing.resignFirstResponder()
//        dailyPricing.resignFirstResponder()
//        weeklyPricing.resignFirstResponder()
//        monthlyPricing.resignFirstResponder()
        return true
    }
    
    @objc func weeklyPricingSwitchChanged(switchState: UISwitch) {
        AppState.sharedInstance.activeSpot.weeklyOn = switchState.isOn
        
        if switchState.isOn {
            AppState.sharedInstance.activeSpot.weeklyPricing = AppState.sharedInstance.activeSpot.calculateReccomendedPricing()[2]
         //   weeklyPricing.text = AppState.sharedInstance.activeSpot.weeklyPricing
            sw1 = "on"
         
        }
        else {
            AppState.sharedInstance.activeSpot.weeklyPricing = ""
         //   weeklyPricing.text = ""
            sw1 = "off"
        }
        
       // weeklyPricing.isEnabled = switchState.isOn
        
        slider3.isEnabled  = switchState.isOn
    }
    
    @objc func monthlyPricingSwitchChanged(switchState: UISwitch) {
        AppState.sharedInstance.activeSpot.monthlyOn = switchState.isOn
        if switchState.isOn {
            AppState.sharedInstance.activeSpot.monthlyPricing = AppState.sharedInstance.activeSpot.calculateReccomendedPricing()[3]
           // monthlyPricing.text = AppState.sharedInstance.activeSpot.monthlyPricing
             sw2 = "on"
        }
        else {
            AppState.sharedInstance.activeSpot.monthlyPricing = ""
         //   monthlyPricing.text = ""
             sw2 = "off"
        }
      //  monthlyPricing.isEnabled = switchState.isOn
          slider4.isEnabled  = switchState.isOn
    }
    
    @IBAction func postSpot(_ sender: Any) {
//        hourlyPricing.resignFirstResponder()
//        dailyPricing.resignFirstResponder()
//        weeklyPricing.resignFirstResponder()
//        monthlyPricing.resignFirstResponder()
        
        if value1 == ""{
            AppState.sharedInstance.activeSpot.hourlyPricing = String(Int(slider1.value))
        }
        if value2 == ""{
              AppState.sharedInstance.activeSpot.dailyPricing = String(Int(slider2.value))
        }
        
        
        if sw1 == "off"{
         AppState.sharedInstance.activeSpot.weeklyPricing = ""
        }
        else{
            if value3 == ""{
            AppState.sharedInstance.activeSpot.weeklyPricing = String(Int(slider3.value))
            }
        }
        
        
        if sw1 == "off"{
            AppState.sharedInstance.activeSpot.monthlyPricing = ""
        }
        else{
            if value4 == ""{
                AppState.sharedInstance.activeSpot.monthlyPricing = String(Int(slider4.value))
            }
        }
        
        
        let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
        self.navigationController!.popToViewController(viewControllers[viewControllers.count - 5], animated: true)
        
        AppState.sharedInstance.change = "change"

        if AppState.sharedInstance.activeSpot.spot_id == "" {
         AppState.sharedInstance.activeSpot.Save_Spot(SpotID:"")
        }
        else{
         AppState.sharedInstance.activeSpot.Save_Spot(SpotID:AppState.sharedInstance.activeSpot.spot_id)
        }
        
     }
}

