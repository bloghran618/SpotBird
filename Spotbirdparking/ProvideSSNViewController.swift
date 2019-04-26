//
//  ProvideSSNViewController.swift
//  Spotbirdparking
//
//  Created by user138340 on 4/24/19.
//  Copyright © 2019 Spotbird. All rights reserved.
//

import UIKit

class ProvideSSNViewController: UIViewController {

    @IBOutlet weak var ssnTextField: SSNTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ssnTextField.setFormatting("###-##-####", replacementChar: "#")
        self.ssnTextField.keyboardType = UIKeyboardType.numberPad
        
    }
    
    @IBAction func WhySSNButton(_ sender: Any) {
        UIApplication.shared.open(URL(string: "https://stripe.com/docs/connect/required-verification-information")! as URL, options: [:], completionHandler: nil)
    }
    
    
}
