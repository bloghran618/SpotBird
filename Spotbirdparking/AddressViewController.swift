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
        
        self.addressField.delegate = self
        self.hideKeyboardWhenTappedAround()
        
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
        if addressField.text != "" {
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
        if addressField.text != "" {
            nextButton.isEnabled = true
        }
        else {
            nextButton.isEnabled = false
        }
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
