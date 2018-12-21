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

class PriceViewController: UIViewController, UITextFieldDelegate,CLLocationManagerDelegate {
    
    @IBOutlet weak var hourlyPricing: UITextField!
    @IBOutlet weak var dailyPricing: UITextField!
    @IBOutlet weak var weeklyPricing: UITextField!
    @IBOutlet weak var monthlyPricing: UITextField!
    @IBOutlet weak var weeklyPricingOn: UISwitch!
    @IBOutlet weak var monthlyPricingOn: UISwitch!
    
    var controller = " "
    var refArtists: DatabaseReference!
    var locationManager = CLLocationManager()
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hourlyPricing.delegate = self
        monthlyPricing.delegate = self
        weeklyPricing.delegate = self
        dailyPricing.delegate = self
        
        self.hideKeyboardWhenTappedAround()
        
        hourlyPricing.keyboardType = UIKeyboardType.decimalPad
        dailyPricing.keyboardType = UIKeyboardType.decimalPad
        weeklyPricing.keyboardType = UIKeyboardType.decimalPad
        monthlyPricing.keyboardType = UIKeyboardType.decimalPad
        
        hourlyPricing.text = AppState.sharedInstance.activeSpot.hourlyPricing
        dailyPricing.text = AppState.sharedInstance.activeSpot.dailyPricing
        weeklyPricing.text = AppState.sharedInstance.activeSpot.weeklyPricing
        monthlyPricing.text = AppState.sharedInstance.activeSpot.monthlyPricing
        
        weeklyPricingOn.addTarget(self, action: #selector(weeklyPricingSwitchChanged), for: UIControlEvents.valueChanged)
        monthlyPricingOn.addTarget(self, action: #selector(monthlyPricingSwitchChanged), for: UIControlEvents.valueChanged)
     }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
     }
    
   func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
        if (textField == hourlyPricing) {
            AppState.sharedInstance.activeSpot.hourlyPricing = hourlyPricing.text!
        }
        else if (textField == dailyPricing) {
            AppState.sharedInstance.activeSpot.dailyPricing = dailyPricing.text!
        }
        else if (textField == weeklyPricing) {
            AppState.sharedInstance.activeSpot.weeklyPricing = weeklyPricing.text!
        }
        else if (textField == monthlyPricing) {
            AppState.sharedInstance.activeSpot.monthlyPricing = monthlyPricing.text!
        }
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if (textField == hourlyPricing) {
            AppState.sharedInstance.activeSpot.hourlyPricing = hourlyPricing.text!
        }
        else if (textField == dailyPricing) {
            AppState.sharedInstance.activeSpot.dailyPricing = dailyPricing.text!
        }
        else if (textField == weeklyPricing) {
            AppState.sharedInstance.activeSpot.weeklyPricing = weeklyPricing.text!
        }
        else if (textField == monthlyPricing) {
            AppState.sharedInstance.activeSpot.monthlyPricing = monthlyPricing.text!
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        hourlyPricing.resignFirstResponder()
        dailyPricing.resignFirstResponder()
        weeklyPricing.resignFirstResponder()
        monthlyPricing.resignFirstResponder()
        return true
    }
    
    @objc func weeklyPricingSwitchChanged(switchState: UISwitch) {
        AppState.sharedInstance.activeSpot.weeklyOn = switchState.isOn
        
        if switchState.isOn {
            AppState.sharedInstance.activeSpot.weeklyPricing = AppState.sharedInstance.activeSpot.calculateReccomendedPricing()[2]
            weeklyPricing.text = AppState.sharedInstance.activeSpot.weeklyPricing
        }
        else {
            AppState.sharedInstance.activeSpot.weeklyPricing = ""
            weeklyPricing.text = ""
        }
        
        weeklyPricing.isEnabled = switchState.isOn
    }
    
    @objc func monthlyPricingSwitchChanged(switchState: UISwitch) {
        AppState.sharedInstance.activeSpot.monthlyOn = switchState.isOn
        if switchState.isOn {
            AppState.sharedInstance.activeSpot.monthlyPricing = AppState.sharedInstance.activeSpot.calculateReccomendedPricing()[3]
            monthlyPricing.text = AppState.sharedInstance.activeSpot.monthlyPricing
        }
        else {
            AppState.sharedInstance.activeSpot.monthlyPricing = ""
            monthlyPricing.text = ""
        }
        monthlyPricing.isEnabled = switchState.isOn
    }
    
    @IBAction func postSpot(_ sender: Any) {
        hourlyPricing.resignFirstResponder()
        dailyPricing.resignFirstResponder()
        weeklyPricing.resignFirstResponder()
        monthlyPricing.resignFirstResponder()
        
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

