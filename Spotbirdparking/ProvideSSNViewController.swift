//
//  ProvideSSNViewController.swift
//  Spotbirdparking
//
//  Created by user138340 on 4/24/19.
//  Copyright © 2019 Spotbird. All rights reserved.
//

import UIKit
import RNCryptor

class ProvideSSNViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var ssnTextField: SSNTextField!
    @IBOutlet weak var invalidSSNLabel: UILabel!
    let encryptionPW = "vFxAOvA246L6Syk7Cl426254C-sMJGxk"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set the format of the text field
        ssnTextField.setFormatting("###-##-####", replacementChar: "#")
        
        // set the mode of the keyboard to numberpad for SSN field and set delegate
        self.ssnTextField.keyboardType = UIKeyboardType.numberPad
        self.ssnTextField.delegate = self
        
        // hide invalid SSN label
        invalidSSNLabel.isHidden = true
        
        self.hideKeyboardWhenTappedAround()
    }
    
    // Link to Stripe webpage to explain why we need SSN
    @IBAction func WhySSNButton(_ sender: Any) {
        UIApplication.shared.open(URL(string: "https://stripe.com/docs/connect/required-verification-information")! as URL, options: [:], completionHandler: nil)
    }
    
    // submit ssn to stripe
    @IBAction func submitButton(_ sender: Any) {
        let ssn = ssnTextField.text as! String
        print("This is what is in the field: \(ssn)")

        
        // Check that the field is int and length is 9
        if (Int(ssn) == nil || ssn.count != 9) {
            // show the invalid SSN label
            self.invalidSSNLabel.isHidden = false
        }
        else {
            // hide the invalid SSN label
            self.invalidSSNLabel.isHidden = true
            
            // encrypt the social security number for pass to backend
            let encryptedSSN = encryptSSN(SSN: ssn, key: self.encryptionPW)
            print("Here is your encrypted data: \(encryptedSSN)")
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        print("The text field ended editing")
        // Check that the field is int and length is 9
        if (Int(ssnTextField.text) == nil || ssnTextField.text.count != 9) {
            // show the invalid SSN label
            self.invalidSSNLabel.isHidden = false
        }
        else {
            // hide the invalid SSN label
            self.invalidSSNLabel.isHidden = true
            }
    }
    
    func encryptSSN(SSN: String, key: String) -> String {
        let SSNData = SSN.data(using: .utf8)!
        let cipher = RNCryptor.encrypt(data: SSNData, withPassword: key)
        return cipher.base64EncodedString()
    }
}
