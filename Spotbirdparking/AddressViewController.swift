//
//  AddressViewController.swift
//  Spotbirdparking
//
//  Created by user138340 on 7/10/18.
//  Copyright © 2018 Spotbird. All rights reserved.
//

import UIKit

class AddressViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var addressField: UITextField!
    @IBOutlet weak var townField: UITextField!
    @IBOutlet weak var stateField: UITextField!
    @IBOutlet weak var zipField: UITextField!
    @IBOutlet weak var nextButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       // AppState.sharedInstance.activeSpot.pringSpotCliffNotes()
        
        self.addressField.delegate = self
        self.townField.delegate = self
        self.stateField.delegate = self
        self.zipField.delegate = self
        
        self.hideKeyboardWhenTappedAround()
        print(AppState.sharedInstance.dict_spot.count)
        
        addressField.text = AppState.sharedInstance.dict_spot.value(forKey: "address") as? String
        townField.text = AppState.sharedInstance.dict_spot.value(forKey: "city") as? String
        stateField.text = AppState.sharedInstance.dict_spot.value(forKey: "state") as? String
        zipField.text = AppState.sharedInstance.dict_spot.value(forKey: "zipcode") as? String
        
        if AppState.sharedInstance.dict_spot.count == 0{
           nextButton.isEnabled = false
        }
        else {
            nextButton.isEnabled = true
        }

     }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Behavior when you hit return on keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == addressField {
            self.addressField.resignFirstResponder()
            //  AppState.sharedInstance.activeSpot.address = addressField.text!
            AppState.sharedInstance.dict_spot.setValue(addressField.text!, forKey: "address")
            addressBarButtonCheckEnable()
        }
        else if textField == townField {
            self.townField.resignFirstResponder()
            //  AppState.sharedInstance.activeSpot.town = townField.text!
            AppState.sharedInstance.dict_spot.setValue(townField.text!, forKey: "city")
            addressBarButtonCheckEnable()
        }
        else if textField == stateField {
            self.stateField.resignFirstResponder()
            //       AppState.sharedInstance.activeSpot.state = stateField.text!
            AppState.sharedInstance.dict_spot.setValue(stateField.text!, forKey: "state")
            addressBarButtonCheckEnable()
        }
        else if textField == zipField {
            self.zipField.resignFirstResponder()
            //   AppState.sharedInstance.activeSpot.zipCode = zipField.text!
            AppState.sharedInstance.dict_spot.setValue(zipField.text!, forKey: "zipcode")
            addressBarButtonCheckEnable()
        }
        
       
//        if AppState.sharedInstance.dict_spot.value(forKey: "address") as? String != "" {
//            nextButton.isEnabled = true
//        }
//        else {
//            nextButton.isEnabled = false
//        }
        return true
    }
    
    // Behavior when you click outside of the text box
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == addressField {
            self.addressField.resignFirstResponder()
            print(AppState.sharedInstance.dict_spot)
            // AppState.sharedInstance.activeSpot.address = addressField.text!
            AppState.sharedInstance.dict_spot.setValue(addressField.text!, forKey: "address")
            addressBarButtonCheckEnable()
        }
        else if textField == townField {
            self.townField.resignFirstResponder()
            // AppState.sharedInstance.activeSpot.town = townField.text!
            AppState.sharedInstance.dict_spot.setValue(townField.text!, forKey: "city")
            addressBarButtonCheckEnable()
        }
        else if textField == stateField {
            self.stateField.resignFirstResponder()
            //      AppState.sharedInstance.activeSpot.state = stateField.text!
            AppState.sharedInstance.dict_spot.setValue(stateField.text!, forKey: "state")
              addressBarButtonCheckEnable()
        }
        else if textField == zipField {
            self.zipField.resignFirstResponder()
            //       AppState.sharedInstance.activeSpot.zipCode = zipField.text!
            AppState.sharedInstance.dict_spot.setValue(zipField.text!, forKey: "zipcode")
              addressBarButtonCheckEnable()
        }
        
        // if AppState.sharedInstance.activeSpot.address != "" {
//        if AppState.sharedInstance.dict_spot.value(forKey: "address") as? String != "" {
//            nextButton.isEnabled = true
//        }
//        else {
//            nextButton.isEnabled = false
//        }
    }
    
    
    func addressBarButtonCheckEnable() -> Bool {
      
        if addressField.text == "" || townField.text == "" || stateField.text == "" || zipField.text == ""
        {
   self.nextButton.isEnabled = false
            return true
        }
        else {
            self.nextButton.isEnabled = true
            return false
        }
        
    }
    
}
