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
        
       self.addressField.delegate = self
        self.townField.delegate = self
        self.stateField.delegate = self
        self.zipField.delegate = self
        
        self.hideKeyboardWhenTappedAround()
        
        addressField.text = AppState.sharedInstance.activeSpot.address
        townField.text = AppState.sharedInstance.activeSpot.town
        stateField.text = AppState.sharedInstance.activeSpot.state
        zipField.text = AppState.sharedInstance.activeSpot.zipCode
        
        if addressField.text == "" {
            nextButton.isEnabled = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
      
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // Behavior when you hit return on keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == addressField {
            self.addressField.resignFirstResponder()
            AppState.sharedInstance.activeSpot.address = addressField.text!
        }
        else if textField == townField {
            self.townField.resignFirstResponder()
            AppState.sharedInstance.activeSpot.town = townField.text!
        }
        else if textField == stateField {
            self.stateField.resignFirstResponder()
            AppState.sharedInstance.activeSpot.state = stateField.text!
        }
        else if textField == zipField {
            self.zipField.resignFirstResponder()
            AppState.sharedInstance.activeSpot.zipCode = zipField.text!
        }
        
        if ((AppState.sharedInstance.activeSpot.address != "") && (AppState.sharedInstance.activeSpot.town != "")) && ((AppState.sharedInstance.activeSpot.zipCode != "") && (AppState.sharedInstance.activeSpot.state != "")) {
            nextButton.isEnabled = true
        }
        else {
            nextButton.isEnabled = false
        }
        return true
    }
    
    // Behavior when you click outside of the text box
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == addressField {
            self.addressField.resignFirstResponder()
            AppState.sharedInstance.activeSpot.address = addressField.text!
        }
        else if textField == townField {
            self.townField.resignFirstResponder()
            AppState.sharedInstance.activeSpot.town = townField.text!
        }
        else if textField == stateField {
            self.stateField.resignFirstResponder()
            AppState.sharedInstance.activeSpot.state = stateField.text!
        }
        else if textField == zipField {
            self.zipField.resignFirstResponder()
            AppState.sharedInstance.activeSpot.zipCode = zipField.text!
        }
        
        if ((AppState.sharedInstance.activeSpot.address != "") && (AppState.sharedInstance.activeSpot.town != "")) && ((AppState.sharedInstance.activeSpot.zipCode != "") && (AppState.sharedInstance.activeSpot.state != "")) {
            nextButton.isEnabled = true
        }
        else {
            nextButton.isEnabled = false
        }
    }
}

