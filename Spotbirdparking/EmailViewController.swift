//
//  EmailViewController.swift
//  Spotbirdparking
//
//  Created by user138340 on 5/30/19.
//  Copyright © 2019 Spotbird. All rights reserved.
//

import UIKit
import Alamofire

class EmailViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var returnAddressTextField: UITextField!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var emptyMessageErrorLabel: UILabel!
    let emptyText = "Message: "
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.messageTextView.delegate = self
        self.hideKeyboardWhenTappedAround()
        emptyMessageErrorLabel.isHidden = true
        
        // make message text view look like text field
        self.messageTextView.layer.borderColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0).cgColor
        self.messageTextView.layer.borderWidth = 1.0
        self.messageTextView.layer.cornerRadius = 5
        self.messageTextView.text = self.emptyText
//        messageTextView.textColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)
        self.messageTextView.textColor = UIColor.lightGray
        
        // set the placeholder text color to match the messageTextView
        returnAddressTextField.attributedPlaceholder = NSAttributedString(string: "Return Email (Optional)", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        
        // return address field populated if possible from logindata
        let email = (UserDefaults.standard.value(forKey: "logindata") as! NSDictionary).value(forKey: "email") as? String ?? ""
        if (email != "") {
            returnAddressTextField.text = email
        }
    }
    
    // start editing the text view
    func textViewDidBeginEditing(_ textView: UITextView) {
        print("we are editing")
        if messageTextView.textColor == UIColor.lightGray {
            print("we should change the color")
            messageTextView.text = nil
            messageTextView.textColor = UIColor.black
            messageTextView.textAlignment = .left
        }
    }
    
    // end editing the text view
    func textViewDidEndEditing(_ textView: UITextView) {
        print("the text view ended editing")
        if messageTextView.text.isEmpty {
            messageTextView.text = self.emptyText
            messageTextView.textColor = UIColor.lightGray
        }
        else {
            emptyMessageErrorLabel.isHidden = true
        }
        messageTextView.resignFirstResponder()
        self.view.frame.origin.y = 20
    }
    
    // should end editing the text view
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        if messageTextView.text.isEmpty {
            messageTextView.text = self.emptyText
            messageTextView.textColor = UIColor.lightGray
        }
        else{
            emptyMessageErrorLabel.isHidden = true
        }
        messageTextView.resignFirstResponder()
        print("Message Text: \(messageTextView.text)")
        return true
    }
    
    // run when the send email button is pressed
    @IBAction func sendEmail(_ sender: Any) {
        
        // check if the message is empty and display an error if it is
        if(messageTextView.text == self.emptyText) {
            emptyMessageErrorLabel.isHidden = false
            return
        }
        
        // configure the message to send
        var returnEmailString = ""
        if(!(returnAddressTextField.text?.isEmpty)!) {
            returnEmailString = "Return Email: \(returnAddressTextField.text)\n"
        }
        let message = """
            Email from SpotBird\n
            \(String(messageTextView.text))\n\n
            ---------------------------------------------------------------\n
            Metadata:\n
            \(String(returnEmailString))
            User Account: \(AppState.sharedInstance.userid)\n
            End Metadata:\n
            ---------------------------------------------------------------
        """
        
        // Configure alamofire request to send email to stripe
        var url = "https://spotbird-backend-bloughran618.herokuapp.com/send_email"
        var params: [String: Any] = [
            "message": message
        ]
        
        // Send request to the backend
        Alamofire.request(url, method: .post, parameters: params)
            .validate(statusCode: 200..<300)
            .responseJSON { response in
                switch response.result {
                case .success:
                    print("Returned with success")
               
                    // notify email successfully sent
                    let alert = UIAlertController(title: "Email Sent Successfully", message: "Thank you for your feedback", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler:
                    { action in
                        // pop a viewcontroller when the alert is dismissed
                        self.navigationController?.popViewController(animated: true)
                    }))
                    self.present(alert, animated: true, completion: nil)
                    
                    
                case .failure(let error):
                    let status = response.response?.statusCode
                    print("Failed, status: \(status)")
                    print("Here is the error: \(error)")
                    
                    // notify the user there was an error
                    let alert = UIAlertController(title: "Error", message: "There was an issue with the backend, please try again later", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
        }
    }
}
