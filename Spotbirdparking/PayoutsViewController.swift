//
//  PayoutsViewController.swift
//  Spotbirdparking
//
//  Created by user138340 on 12/17/18.
//  Copyright © 2018 Spotbird. All rights reserved.
//

import UIKit

class PayoutsViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {

    
    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var lastNameField: UITextField!
    @IBOutlet weak var line1AddressField: UITextField!
    @IBOutlet weak var line2AddressField: UITextField!
    @IBOutlet weak var cityAddressField: UITextField!
    @IBOutlet weak var stateAddressField: UITextField!
    @IBOutlet weak var stateDropDown: UIPickerView!
    @IBOutlet weak var zipAddressField: UITextField!
    @IBOutlet weak var dateOfBirthDatePicker: UIDatePicker!
    @IBOutlet weak var last4SocialField: UITextField!
    @IBOutlet weak var routingNumberField: UITextField!
    @IBOutlet weak var accountNumberField: UITextField!
    
    let states = [["Alabama", "AL"], ["Alaska", "AK"], ["Arizona", "AZ"], ["Arkansas", "AR"], ["California", "CA"], ["Colorado", "CO"], ["Connecticut", "CT"], ["Delaware", "DE"], ["Florida", "FA"], ["Georgia", "GA"], ["Hawaii", "HI"], ["Idaho", "ID"], ["Illinois", "IL"], ["Indiana", "IN"], ["Iowa", "IA"], ["Kansas", "KS"], ["Kentucky", "KY"], ["Lousiana", "LA"], ["Maine", "ME"], ["Maryland", "MD"], ["Massachusetts", "MA"], ["Michigan", "MI"], ["Minnesota", "MN"], ["Mississippi", "MS"], ["Missouri", "MO"], ["Montana", "MT"], ["Nebraska", "NE"], ["Nevada", "NV"], ["New Hampshire", "NH"], ["New Jersey", "NJ"], ["New Mexico", "NM"], ["New York", "NY"], ["North Carolina", "NC"], ["North Dakota", "ND"], ["Ohio", "OH"], ["Oklahoma", "OK"], ["Oregon", "OR"], ["Pennsylvania", "PA"], ["Rhode Island", "RI"], ["South Carolina", "SC"], ["South Dakota", "SD"], ["Tennessee", "TN"], ["Texas", "TX"], ["Utah", "UT"], ["Vermont", "VT"], ["Virginia", "VA"], ["Washington", "WA"], ["West Virginia", "WV"], ["Wisconsin", "WI"], ["Wyoming", "WY"]]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hideKeyboardWhenTappedAround()
        
        self.zipAddressField.keyboardType = UIKeyboardType.numberPad
        self.last4SocialField.keyboardType = UIKeyboardType.numberPad
        self.routingNumberField.keyboardType = UIKeyboardType.numberPad
        self.accountNumberField.keyboardType = UIKeyboardType.numberPad
        
        print(states.count)
    }
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int{
        return 1
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        return states.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        self.view.endEditing(true)
        return states[row][0]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        self.stateAddressField.text = self.states[row][1]
        self.stateDropDown.isHidden = true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if textField == self.stateAddressField {
            self.stateDropDown.isHidden = false
            textField.endEditing(true)
        }
    }
    

}
