//
//  PayoutsViewController.swift
//  Spotbirdparking
//
//  Created by user138340 on 12/17/18.
//  Copyright © 2018 Spotbird. All rights reserved.
//

import UIKit
import Stripe

class PayoutsViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {

    // Fields and controls
    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var lastNameField: UITextField!
    @IBOutlet weak var line1AddressField: UITextField!
    @IBOutlet weak var line2AddressField: UITextField!
    @IBOutlet weak var cityAddressField: UITextField!
    @IBOutlet weak var stateAddressField: UITextField!
    @IBOutlet weak var stateDoneButton: UIButton!
    @IBOutlet weak var stateDropDown: UIPickerView!
    @IBOutlet weak var zipAddressField: UITextField!
    @IBOutlet weak var dateOfBirthDatePicker: UIDatePicker!
    @IBOutlet weak var last4SocialField: UITextField!
    @IBOutlet weak var routingNumberField: UITextField!
    @IBOutlet weak var accountNumberField: UITextField!
    
    
    // Validation Labels
    @IBOutlet weak var firstNameValidation: UILabel!
    @IBOutlet weak var lastNameValidation: UILabel!
    @IBOutlet weak var addressLine1Validation: UILabel!
    @IBOutlet weak var cityValidation: UILabel!
    @IBOutlet weak var stateValidation: UILabel!
    @IBOutlet weak var zipValidation: UILabel!
    @IBOutlet weak var last4SocialValidation: UILabel!
    @IBOutlet weak var routingNumberValidation: UILabel!
    @IBOutlet weak var accountNumberValidation: UILabel!
    
    // Other
    @IBOutlet weak var termsLabel: UILabel!
    
    
    let states = [["Alabama", "AL"], ["Alaska", "AK"], ["Arizona", "AZ"], ["Arkansas", "AR"], ["California", "CA"], ["Colorado", "CO"], ["Connecticut", "CT"], ["Delaware", "DE"], ["Florida", "FA"], ["Georgia", "GA"], ["Hawaii", "HI"], ["Idaho", "ID"], ["Illinois", "IL"], ["Indiana", "IN"], ["Iowa", "IA"], ["Kansas", "KS"], ["Kentucky", "KY"], ["Lousiana", "LA"], ["Maine", "ME"], ["Maryland", "MD"], ["Massachusetts", "MA"], ["Michigan", "MI"], ["Minnesota", "MN"], ["Mississippi", "MS"], ["Missouri", "MO"], ["Montana", "MT"], ["Nebraska", "NE"], ["Nevada", "NV"], ["New Hampshire", "NH"], ["New Jersey", "NJ"], ["New Mexico", "NM"], ["New York", "NY"], ["North Carolina", "NC"], ["North Dakota", "ND"], ["Ohio", "OH"], ["Oklahoma", "OK"], ["Oregon", "OR"], ["Pennsylvania", "PA"], ["Rhode Island", "RI"], ["South Carolina", "SC"], ["South Dakota", "SD"], ["Tennessee", "TN"], ["Texas", "TX"], ["Utah", "UT"], ["Vermont", "VT"], ["Virginia", "VA"], ["Washington", "WA"], ["West Virginia", "WV"], ["Wisconsin", "WI"], ["Wyoming", "WY"]]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Spinner.stop()
        hideKeyboardWhenTappedAround()
        
        // set delegates
        firstNameField.delegate = self
        lastNameField.delegate = self
        line1AddressField.delegate = self
        line2AddressField.delegate = self
        cityAddressField.delegate = self
        stateAddressField.delegate = self
        zipAddressField.delegate = self
        last4SocialField.delegate = self
        accountNumberField.delegate = self
        routingNumberField.delegate = self
        
        hideAllValidationFields()
        self.hideKeyboardWhenTappedAround()
        
        self.zipAddressField.keyboardType = UIKeyboardType.numberPad
        self.last4SocialField.keyboardType = UIKeyboardType.numberPad
        self.routingNumberField.keyboardType = UIKeyboardType.numberPad
        self.accountNumberField.keyboardType = UIKeyboardType.numberPad
        
        // set the first and last name fields if info availible
        if(AppState.sharedInstance.user.firstName != "") {
            self.firstNameField.text = AppState.sharedInstance.user.firstName
        }
        if(AppState.sharedInstance.user.lastName != "") {
            self.lastNameField.text = AppState.sharedInstance.user.lastName
        }
        
        // default state (launch is in Philly, most spots should be in PA
        self.stateAddressField.text = "PA"
        
        termsLabel.numberOfLines = 0
    }
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int{
        return 1
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        return states.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return states[row][0]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
//        self.stateAddressField.text = self.states[row][1]
    }
    
    @IBAction func stateDoneButtonClicked(_ sender: Any) {
        self.stateAddressField.text = self.states[stateDropDown.selectedRow(inComponent: 0)][1]
        self.stateDropDown.isHidden = true
        self.stateDoneButton.isHidden = true
        stateValidation.isHidden = true
    }
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if textField == self.stateAddressField {
            self.stateDropDown.isHidden = false
            self.stateDoneButton.isHidden = false
//            textField.endEditing(true)
            
            // hide keyboard
//            firstNameField.resignFirstResponder()
//            lastNameField.resignFirstResponder()
//            line1AddressField.resignFirstResponder()
//            line2AddressField.resignFirstResponder()
//            cityAddressField.resignFirstResponder()
//            stateAddressField.resignFirstResponder()
//            zipAddressField.resignFirstResponder()
//            last4SocialField.resignFirstResponder()
//            accountNumberField.resignFirstResponder()
//            routingNumberField.resignFirstResponder()
//            textField.resignFirstResponder()
        }
    }
    
    // Dynamically hide validation fields when text field returned
    func textFieldDidEndEditing(_ textField: UITextField) {
        print("Text field should return")
        if(textField == firstNameField && firstNameField.text != "") {
            firstNameValidation.isHidden = true
        }
        if(textField == lastNameField && lastNameField.text != "") {
            lastNameValidation.isHidden = true
        }
        if(textField == line1AddressField && line1AddressField.text != "") {
            addressLine1Validation.isHidden = true
        }
        if(textField == cityAddressField && cityAddressField.text != "") {
            cityValidation.isHidden = true
        }
        if(textField == stateAddressField && stateAddressField.text != "") {
            stateValidation.isHidden = true
        }
        if(textField == zipAddressField && zipAddressField.text != "") {
            zipValidation.isHidden = true
        }
        if(textField == last4SocialField && last4SocialField.text != "") {
            last4SocialValidation.isHidden = true
        }
        if(textField == accountNumberField && accountNumberField.text != "") {
            accountNumberValidation.isHidden = true
        }
        if(textField == routingNumberField && routingNumberField.text != "") {
            routingNumberValidation.isHidden = true
        }
    }
    
    // Hide all validation fields
    func hideAllValidationFields() {
        firstNameValidation.isHidden = true
        lastNameValidation.isHidden = true
        addressLine1Validation.isHidden = true
        cityValidation.isHidden = true
        stateValidation.isHidden = true
        zipValidation.isHidden = true
        last4SocialValidation.isHidden = true
        accountNumberValidation.isHidden = true
        routingNumberValidation.isHidden = true
    }
    
    // Function which activates when you hit the "submit info" button
    @IBAction func submitInfo(_ sender: Any) {
        
        Spinner.start()
        
        print("Lets submit some info!")
        let firstName = firstNameField.text
        let lastName = lastNameField.text
        let line1Address = line1AddressField.text
        let line2Address = line2AddressField.text
        let cityAddress = cityAddressField.text
        let stateAddress = stateAddressField.text
        let zipAddress = zipAddressField.text
        var dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd"
        let dateOfBirthDay = dateFormatter.string(from: dateOfBirthDatePicker.date)
        dateFormatter.dateFormat = "M"
        let dateOfBirthMonth = dateFormatter.string(from: dateOfBirthDatePicker.date)
        dateFormatter.dateFormat = "yyyy"
        let dateOfBirthYear = dateFormatter.string(from: dateOfBirthDatePicker.date)
        let last4Social = last4SocialField.text
        let routingNumber = routingNumberField.text
        let accountNumber = accountNumberField.text
        
        // Do a "first pass" validation
        var isValid = true
        hideAllValidationFields()
        if(firstName == "") {
            firstNameValidation.isHidden = false
            isValid = false
        }
        if(lastName == "") {
            lastNameValidation.isHidden = false
            isValid = false
        }
        if(line1Address == "") {
            addressLine1Validation.isHidden = false
            isValid = false
        }
        if(cityAddress == "") {
            cityValidation.isHidden = false
            isValid = false
        }
        if(stateAddress == "") {
            stateValidation.isHidden = false
            isValid = false
        }
        if(zipAddress == "") {
            zipValidation.isHidden = false
            isValid = false
        }
        if(last4Social == "") {
            last4SocialValidation.isHidden = false
            isValid = false
        }
        if(accountNumber == "") {
            accountNumberValidation.isHidden = false
            isValid = false
        }
        if(routingNumber == "") {
            routingNumberValidation.isHidden = false
            isValid = false
        }
        
        // if the form passes "first pass" validation
        if(isValid) {
        
            // dictionary containing info - might not need
            let params: [String: String] = [
                "first_name": firstName ?? "",
                "last_name": lastName ?? "",
                "line_1_address": line1Address ?? "",
                "line_2_address": line2Address ?? "",
                "city_address": cityAddress ?? "",
                "state_address": stateAddress ?? "",
                "zip_address": zipAddress ?? "",
                "dob_day": dateOfBirthDay,
                "dob_month": dateOfBirthMonth,
                "dob_year": dateOfBirthYear,
                "last_4_social": last4Social ?? "",
                "routing_number": routingNumber ?? "",
                "account_number": accountNumber ?? ""
                ]
            
            print(params)
            
            
            // STPBankAccountParams() object creation
            var bankAccount = STPBankAccountParams()
            bankAccount.accountHolderName = "\(firstName) \(lastName)"
            bankAccount.country = "US"
            bankAccount.currency = "USD"
            bankAccount.accountHolderType = STPBankAccountHolderType(rawValue: 0)! //?? should be individual
            bankAccount.accountNumber = accountNumber
            bankAccount.routingNumber = routingNumber
            

            // STPConnectAccountParams() object creation
            var address = STPAddress()
            address.name = "\(firstName) \(lastName)"
            address.line1 = line1Address
            address.line2 = line2Address
            address.city = cityAddress
            address.state = stateAddress
            address.postalCode = zipAddress
            address.country = "US"
            
            let dateOfBirth = DateComponents(calendar: Calendar.current, year: Int(dateOfBirthYear), month: Int(dateOfBirthMonth), day: Int(dateOfBirthDay)) // all DOB int() because datePicker()
            
            // STPLegalEntityParams() object creation
            var legalEntity = STPConnectAccountIndividualParams()
            legalEntity.ssnLast4 = last4Social
//            legalEntity.entityTypeString = "individual"
            legalEntity.firstName = firstName
            legalEntity.lastName = lastName
//            legalEntity.personalAddress = address
            legalEntity.dateOfBirth = dateOfBirth
            var accountInfo = STPConnectAccountParams.init(individual: legalEntity)
            
            // Create STPConnectAccountParams token
            STPAPIClient.shared().createToken(withConnectAccount: accountInfo) { (token, error) in
                if let error = error {
                    print(error)
                    let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    
                    Spinner.stop()
                }
                else {
                    print("We successfully created STPConnectAccountParams token!!!")
                    print(token)
                    print(token?.tokenId)
                    
                    Spinner.stop()
                    
                    // do stuff with token
                    MyAPIClient.sharedClient.addConnectAccountInfoToken(token: token!, address: address)
                
                    
                    // Create bankAccount token on successful account params token
                    STPAPIClient.shared().createToken(withBankAccount: bankAccount) { (token, error) in
                        if let error = error {
                            print(error)
                            let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                        }
                        else {
                            print("We successfully created STPBankAccountParams token!!!")
                            print(token)
                            print(token?.tokenId)
                            
                            // debug
                            print("Stripe Account Number: \(AppState.sharedInstance.user.accounttoken)")
                            // send token to backend
                            MyAPIClient.sharedClient.addAccountToken(token: token!)
                        }
                    }
                    
                }
            }
        }
        else { // failed "first pass" validation
            alertUserRequiredFields()
            return
        }
    }
    
    func alertUserRequiredFields() {
        let alert = UIAlertController(title: "Error", message: "Not all required fields submitted. Please resubmit a complete form.", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    // Display Stripe Terms and Conditions in a browser window
    @IBAction func termsAndConditionsButton(_ sender: Any) {
        print("clicked!")
        UIApplication.shared.open(URL(string: "https://stripe.com/us/connect-account/legal")! as URL, options: [:], completionHandler: nil)
    }
    
}
