//
//  ScheduleViewController.swift
//  Spotbirdparking
//
//  Created by user138340 on 8/7/18.
//  Copyright © 2018 Spotbird. All rights reserved.
//

import UIKit

class ScheduleViewController: UIViewController, UITextFieldDelegate{

    @IBOutlet weak var monStartTime: UITextField!
    @IBOutlet weak var monEndTime: UITextField!
    
    
    private var datePicker: UIDatePicker?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboardWhenTappedAround()
        
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = UIDatePickerMode.time
        datePicker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        
//        monStartTime.delegate = self
        monStartTime.inputView = datePicker
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    @IBAction func monStartValueChanged(_ sender: Any) {
//        let DatePickerView: UIDatePicker = UIDatePicker()
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "hh:mm"
//        monStartTime.text = dateFormatter.string(from: DatePickerView.date)
//    }
    
    @objc func datePickerValueChanged(_ sender: UIDatePicker) {
//        let DatePickerView: UIDatePicker = UIDatePicker()
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "hh:mm a"
        monStartTime.text = dateFormatter.string(from: sender.date)
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
