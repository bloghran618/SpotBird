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
    @IBOutlet weak var lbl1_mini: UILabel!
    @IBOutlet weak var lbl1_max: UILabel!
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
        
        
//        let alert = UIAlertController.init(title: "Spotprice", message: AppState.sharedInstance.activeSpot.basePricing, preferredStyle: .alert)
//          let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
//        alert.addAction(defaultAction)
//        self.present(alert, animated: true, completion: nil)
        
        Slide1.minimumValue = 5
        Slide1.maximumValue = 8
        
        lbl1_price.text = "$ 5"
        if AppState.sharedInstance.activeSpot.basePricing != ""{
            let basePRice = AppState.sharedInstance.activeSpot.basePricing.replacingOccurrences(of: "$", with: "")
            print(basePRice)
            Slide1.value = (basePRice as NSString).floatValue
            
            print(basePRice)
            
            lbl1_price.text =  "$\(Slide1.value)"
        }
        
        
       // lbl1_price.text = "$ \(AppState.sharedInstance.activeSpot.hourlyPricing)"
        lbl2_price.text = "$ \(AppState.sharedInstance.activeSpot.dailyPricing)"
        
        if AppState.sharedInstance.activeSpot.weeklyOn == true{
            lbl3_price.text = "$ \(AppState.sharedInstance.activeSpot.weeklyPricing)"
        }
        else{
            lbl3_price.isHidden = true
        }
        
        if AppState.sharedInstance.activeSpot.monthlyOn == true{
            lbl4_price.text = "$ \(AppState.sharedInstance.activeSpot.monthlyPricing)"
        }
        else{
            lbl4_price.isHidden = true
        }
        
        lbl1.text = String(AppState.sharedInstance.user.avg1)
        lbl2.text = String(AppState.sharedInstance.user.avg2)
        lbl3.text = String(AppState.sharedInstance.user.avg3)
        lbl4.text = String(AppState.sharedInstance.user.avg4)
        
        weeklyPricingOn.addTarget(self, action: #selector(weeklyPricingSwitchChanged), for: UIControlEvents.valueChanged)
        monthlyPricingOn.addTarget(self, action: #selector(monthlyPricingSwitchChanged), for: UIControlEvents.valueChanged)
        
        lbl1_mini.text = "$ 5"
        lbl1_max.text = "$ 8"
        
        
        print((AppState.sharedInstance.activeSpot.monthlyPricing))
        
        weeklyPricingOn.isOn = AppState.sharedInstance.activeSpot.weeklyOn
        monthlyPricingOn.isOn = AppState.sharedInstance.activeSpot.monthlyOn
        
    }
    
    @IBAction func Slide1(_ sender: Any) {
        let index = String(format: "%.2f", ((Slide1!.value)))
        AppState.sharedInstance.activeSpot.hourlyPricing = index
        value1 = "101"
        lbl1_price.text = "$ \(AppState.sharedInstance.activeSpot.hourlyPricing)"
        
        let value = (10/100)*(index as NSString).floatValue
        
        //  let value = (index as NSString).floatValue
        
        // base price
        AppState.sharedInstance.activeSpot.basePricing = index
        lbl1_price.text =  AppState.sharedInstance.activeSpot.basePricing
        
        let hr =  24 * value + (index as NSString).floatValue
        let week =   168 * value + (index as NSString).floatValue
        let month =  730.001 * value + (index as NSString).floatValue
        
        print(hr)
        print(week)
        print(month)
        
        lbl2_price.text = "$\(String(format: "%.2f", ((hr))))"
        lbl3_price.text = "$\(String(format: "%.2f", ((week))))"
        lbl4_price.text = "$\(String(format: "%.2f", ((month))))"
        
    }
    
    /*
     @IBAction func Slide2(_ sender: Any) {
     let index = String(format: "%.2f", ((Slide2!.value)))
     AppState.sharedInstance.activeSpot.dailyPricing = index
     value2 = "102"
     lbl2_price.text = "$ \(AppState.sharedInstance.activeSpot.dailyPricing)"
     
     
     }
     
     @IBAction func Slide3(_ sender: Any) {
     let index = String(format: "%.2f", ((Slide3!.value)))
     AppState.sharedInstance.activeSpot.weeklyPricing = index
     value2 = "103"
     lbl3_price.text = "$ \(AppState.sharedInstance.activeSpot.weeklyPricing)"
     
     }
     
     @IBAction func Slide4(_ sender: Any) {
     let index = String(format: "%.2f", ((Slide4!.value)))
     AppState.sharedInstance.activeSpot.monthlyPricing = index
     value2 = "104"
     lbl4_price.text = "$ \(AppState.sharedInstance.activeSpot.monthlyPricing)"
     
     }
     */
    
    
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
            lbl3_price.isHidden = false
            
        }
        else {
            AppState.sharedInstance.activeSpot.weeklyPricing = ""
            //   weeklyPricing.text = ""
            sw1 = "off"
            lbl3_price.isHidden = true
        }
        
        // weeklyPricing.isEnabled = switchState.isOn
        
        // Slide3.isEnabled  = switchState.isOn
        // lbl3_price.isHidden = switchState.isOn
    }
    
    @objc func monthlyPricingSwitchChanged(switchState: UISwitch) {
        AppState.sharedInstance.activeSpot.monthlyOn = switchState.isOn
        if switchState.isOn {
            AppState.sharedInstance.activeSpot.monthlyPricing = AppState.sharedInstance.activeSpot.calculateReccomendedPricing()[3]
            // monthlyPricing.text = AppState.sharedInstance.activeSpot.monthlyPricing
            sw2 = "on"
            lbl4_price.isHidden = false
        }
        else {
            AppState.sharedInstance.activeSpot.monthlyPricing = ""
            //   monthlyPricing.text = ""
            sw2 = "off"
            lbl4_price.isHidden = true
        }
        //  monthlyPricing.isEnabled = switchState.isOn
        //   Slide4.isEnabled  = switchState.isOn
        // lbl4_price.isHidden = switchState.isOn
    }
    
    @IBAction func postSpot(_ sender: Any) {
        //        hourlyPricing.resignFirstResponder()
        //        dailyPricing.resignFirstResponder()
        //        weeklyPricing.resignFirstResponder()
        //        monthlyPricing.resignFirstResponder()
        
        if value1 == ""{
            AppState.sharedInstance.activeSpot.hourlyPricing = String(Float(Slide1.value))
        }
        if value2 == ""{
            // AppState.sharedInstance.activeSpot.dailyPricing = String(Float(Slide2.value))
            AppState.sharedInstance.activeSpot.dailyPricing = lbl2_price.text!
        }
        
        
        if sw1 == "off"{
            AppState.sharedInstance.activeSpot.weeklyPricing = ""
        }
        else{
            if value3 == ""{
                // AppState.sharedInstance.activeSpot.weeklyPricing = String(format: "%.2f", ((Slide3!.value )))
                AppState.sharedInstance.activeSpot.weeklyPricing = lbl3_price.text!
            }
        }
        
        if sw1 == "off"{
            AppState.sharedInstance.activeSpot.monthlyPricing = ""
        }
        else{
            if value4 == ""{
                //    AppState.sharedInstance.activeSpot.monthlyPricing = String(format: "%.2f", ((Slide4!.value )))
                AppState.sharedInstance.activeSpot.monthlyPricing = lbl4_price.text!
            }
        }
        
        AppState.sharedInstance.activeSpot.basePricing = lbl1_price.text!
        
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

