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
    @IBOutlet weak var nextButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        AppState.sharedInstance.activeSpot.pringSpotCliffNotes()
        
        self.addressField.delegate = self
        self.hideKeyboardWhenTappedAround()
        
        addressField.text = AppState.sharedInstance.activeSpot.address
        
        if addressField.text == "" {
            nextButton.isEnabled = false
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Behavior when you hit return on keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.addressField.resignFirstResponder()
        AppState.sharedInstance.activeSpot.address = addressField.text!
        if AppState.sharedInstance.activeSpot.address != "" {
            nextButton.isEnabled = true
        }
        else {
            nextButton.isEnabled = false
        }
        return true
    }

    // Behavior when you click outside of the text box
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.addressField.resignFirstResponder()
        AppState.sharedInstance.activeSpot.address = addressField.text!
        if AppState.sharedInstance.activeSpot.address != "" {
            nextButton.isEnabled = true
        }
        else {
            nextButton.isEnabled = false
        }
    }

}
