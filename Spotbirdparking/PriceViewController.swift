//
//  PriceViewController.swift
//  Spotbirdparking
//
//  Created by user138340 on 8/22/18.
//  Copyright © 2018 Spotbird. All rights reserved.
//

import UIKit

class PriceViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var hourlyPricing: UITextField!
    @IBOutlet weak var dailyPricing: UITextField!
    @IBOutlet weak var weeklyPricing: UITextField!
    @IBOutlet weak var monthlyPricing: UITextField!
    
    @IBOutlet weak var weeklyPricingOn: UISwitch!
    @IBOutlet weak var monthlyPricingOn: UISwitch!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboardWhenTappedAround()
        
        hourlyPricing.keyboardType = UIKeyboardType.decimalPad
        dailyPricing.keyboardType = UIKeyboardType.decimalPad
        weeklyPricing.keyboardType = UIKeyboardType.decimalPad
        monthlyPricing.keyboardType = UIKeyboardType.decimalPad
        
        AppState.sharedInstance.activeSpot.applyCalculatedPricing()
        hourlyPricing.text = AppState.sharedInstance.activeSpot.hourlyPricing
        dailyPricing.text = AppState.sharedInstance.activeSpot.dailyPricing
        weeklyPricing.text = AppState.sharedInstance.activeSpot.weeklyPricing
        monthlyPricing.text = AppState.sharedInstance.activeSpot.monthlyPricing
        
        weeklyPricingOn.addTarget(self, action: #selector(weeklyPricingSwitchChanged), for: UIControlEvents.valueChanged)
        monthlyPricingOn.addTarget(self, action: #selector(monthlyPricingSwitchChanged), for: UIControlEvents.valueChanged)
        
        AppState.sharedInstance.activeSpot.pringSpotCliffNotes()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
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
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
