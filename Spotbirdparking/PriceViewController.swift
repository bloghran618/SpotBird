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

class PriceViewController: UIViewController, UITextFieldDelegate,CLLocationManagerDelegate{
    
    //    @IBOutlet weak var hourlyPricing: UITextField!
    //    @IBOutlet weak var dailyPricing: UITextField!
    //    @IBOutlet weak var weeklyPricing: UITextField!
    //    @IBOutlet weak var monthlyPricing: UITextField!
    @IBOutlet weak var weeklyPricingOn: UISwitch!
    @IBOutlet weak var monthlyPricingOn: UISwitch!
    @IBOutlet weak var lbl1: UILabel!
    @IBOutlet weak var lbl2: UILabel!
    @IBOutlet weak var lbl3: UILabel!
    @IBOutlet weak var lbl4: UILabel!
    @IBOutlet weak var Slide1: UISlider!
    @IBOutlet weak var Slide2: UISlider!
    @IBOutlet weak var Slide3: UISlider!
    @IBOutlet weak var Slide4: UISlider!
    
    @IBOutlet weak var lbl1_mini: UILabel!
    @IBOutlet weak var lbl2_mini: UILabel!
    @IBOutlet weak var lbl3_mini: UILabel!
    @IBOutlet weak var lbl4_mini: UILabel!
    
    @IBOutlet weak var lbl1_max: UILabel!
    @IBOutlet weak var lbl2_max: UILabel!
    @IBOutlet weak var lbl3_max: UILabel!
    @IBOutlet weak var lbl4_max: UILabel!
    
    @IBOutlet weak var lbl1_price: UILabel!
    @IBOutlet weak var lbl2_price: UILabel!
    @IBOutlet weak var lbl3_price: UILabel!
    @IBOutlet weak var lbl4_price: UILabel!
    
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
        
       
        Slide1.minimumValue = 4
        Slide1.maximumValue = 7
        
        Slide2.minimumValue = 119
        Slide2.maximumValue = 191
        
        Slide3.minimumValue = 839
        Slide3.maximumValue = 1343
        
        Slide4.minimumValue = 3599
        Slide4.maximumValue = 5759
        
        Slide1.value = Float(AppState.sharedInstance.activeSpot.hourlyPricing)!
        Slide2.value = Float(AppState.sharedInstance.activeSpot.dailyPricing)!
        Slide3.value = Float(AppState.sharedInstance.activeSpot.weeklyPricing)!
        Slide4.value = Float(AppState.sharedInstance.activeSpot.monthlyPricing)!
        
        lbl1_price.text = "$ \(AppState.sharedInstance.activeSpot.hourlyPricing)"
        lbl2_price.text = "$ \(AppState.sharedInstance.activeSpot.dailyPricing)"
        lbl3_price.text = "$ \(AppState.sharedInstance.activeSpot.weeklyPricing)"
        lbl4_price.text = "$ \(AppState.sharedInstance.activeSpot.monthlyPricing)"
        
        
        lbl1.text = String(AppState.sharedInstance.user.avg1)
        lbl2.text = String(AppState.sharedInstance.user.avg2)
        lbl3.text = String(AppState.sharedInstance.user.avg3)
        lbl4.text = String(AppState.sharedInstance.user.avg4)
        
        weeklyPricingOn.addTarget(self, action: #selector(weeklyPricingSwitchChanged), for: UIControlEvents.valueChanged)
        monthlyPricingOn.addTarget(self, action: #selector(monthlyPricingSwitchChanged), for: UIControlEvents.valueChanged)
        
        
        
        
        lbl1_mini.text = "$ 5"
        lbl1_max.text = "$ 8"
        
        lbl2_mini.text = "$ 120"
        lbl2_max.text = "$ 192"
        
        lbl3_mini.text = "$ 840"
        lbl3_max.text = "1344"
        
        lbl4_mini.text = "$ 3600"
        lbl4_max.text = "$ 5760"
        
        
        print((AppState.sharedInstance.activeSpot.monthlyPricing))
        
    }
    
    
    
    @IBAction func Slide1(_ sender: Any) {
        let index = (Int)(Slide1!.value + 1)
        AppState.sharedInstance.activeSpot.hourlyPricing = String(index)
        value1 = "101"
        lbl1_price.text = "$ \(String(index))"
    }
    
    
    @IBAction func Slide2(_ sender: Any) {
        let index = (Int)(Slide2!.value + 1)
        AppState.sharedInstance.activeSpot.dailyPricing = String(index)
        value2 = "102"
        lbl2_price.text = "$ \(String(index))"
        
    }
    
    
    @IBAction func Slide3(_ sender: Any) {
        let index = (Int)(Slide3!.value + 1)
        AppState.sharedInstance.activeSpot.weeklyPricing = String(index)
        value2 = "103"
        lbl3_price.text = "$ \(String(index))"
        
    }
    
    
    @IBAction func Slide4(_ sender: Any) {
        let index = (Int)(Slide4!.value + 1)
        AppState.sharedInstance.activeSpot.monthlyPricing = String(index)
        value2 = "104"
        lbl4_price.text = "$ \(String(index))"
        
    }
    
    
    
    //    @IBAction func sliderValueChanged(_ sender: TNSlider) {
    //
    //
    //        let value = Int(sender.value)
    //
    //        if sender.tag == 101 {
    //            AppState.sharedInstance.activeSpot.hourlyPricing = String(value)
    //            value1 = "101"
    //
    //        }
    //        else  if sender.tag  == 102 {
    //            AppState.sharedInstance.activeSpot.dailyPricing = String(value)
    //            value2 = "102"
    //        }
    //        else if sender.tag == 103{
    //            AppState.sharedInstance.activeSpot.weeklyPricing = String(value)
    //            value3 = "103"
    //
    //
    //        }else{
    //            AppState.sharedInstance.activeSpot.monthlyPricing = String(value)
    //            value4 = "104"
    //        }
    //    }
    
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
        
        Slide3.isEnabled  = switchState.isOn
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
        Slide4.isEnabled  = switchState.isOn
    }
    
    @IBAction func postSpot(_ sender: Any) {
        //        hourlyPricing.resignFirstResponder()
        //        dailyPricing.resignFirstResponder()
        //        weeklyPricing.resignFirstResponder()
        //        monthlyPricing.resignFirstResponder()
        
        if value1 == ""{
            AppState.sharedInstance.activeSpot.hourlyPricing = String(Int(Slide1.value))
        }
        if value2 == ""{
            AppState.sharedInstance.activeSpot.dailyPricing = String(Int(Slide2.value))
        }
        
        
        if sw1 == "off"{
            AppState.sharedInstance.activeSpot.weeklyPricing = ""
        }
        else{
            if value3 == ""{
                AppState.sharedInstance.activeSpot.weeklyPricing = String(Int(Slide3.value))
            }
        }
        
        if sw1 == "off"{
            AppState.sharedInstance.activeSpot.monthlyPricing = ""
        }
        else{
            if value4 == ""{
                AppState.sharedInstance.activeSpot.monthlyPricing = String(Int(Slide4.value))
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

