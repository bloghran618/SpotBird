//
//  ProvideSSNViewController.swift
//  Spotbirdparking
//
//  Created by user138340 on 4/24/19.
//  Copyright © 2019 Spotbird. All rights reserved.
//

import UIKit
//import Sodium
//import libsodium
import RNCryptor
import Alamofire

class ProvideSSNViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var ssnTextField: SSNTextField!
    @IBOutlet weak var invalidSSNLabel: UILabel!
    let encryptionPW = "vFxAOvA246L6Syk7Cl426254C-sMJGxk"
//    let sodium = Sodium()
    
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
            
            // encrypt the ssn before we send to backend
            let encrypted = encryptSSN(SSN: Int(ssn)!)
            print("This is the encrypted value: \(encrypted)")
            
            // send to stripe
            self.saveSSNToStripe(encryptedSSN: encrypted)
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
    
    //        let SSNData = SSN.bytes
    //        let encrypted: Bytes = sodium.secretBox.seal(message: SSNData, secretKey: key)
    //        return encrypted
    
    // VERY hacky, should update to real encryption someday
    func encryptSSN(SSN: Int) -> Int {
        
//        let messageData = SSN.data(using: .utf8)!
//        let cipherData = RNCryptor.encrypt(data: messageData, withPassword: self.encryptionPW)
//        return cipherData.base64EncodedString()
        
        let a = 179424691
        let b = 373587911
        let encrypted = a * SSN + b
        return encrypted
    }
    
    // Send the social security number to Stripe
    func saveSSNToStripe(encryptedSSN: Int) {
        var url = "https://spotbird-backend-bloughran618.herokuapp.com/save_ssn"
        
        var params: [String: Any] = [
            "account_id": AppState.sharedInstance.user.accounttoken,
            "encrypted_ssn": encryptedSSN
        ]
        
        Alamofire.request(url, method: .post, parameters: params)
            .validate(statusCode: 200..<300)
            .responseJSON { response in
                switch response.result {
                case .success:
                    print("Returned with success")
                    self.navigationController?.popViewController(animated: true)
                case .failure(let error):
                    let status = response.response?.statusCode
                    print("Failed, status: \(status)")
                    print("Here is the error: \(error)")
                }
        }
    }
}
