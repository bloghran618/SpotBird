//
//  PriceViewController.swift
//  Spothawk
//
//  Created by user138340 on 8/22/18.
//  Copyright © 2020 Spothawk. All rights reserved.
//

import UIKit
import Photos
import Firebase
import CoreLocation

class PriceViewController: UIViewController, UITextFieldDelegate,CLLocationManagerDelegate{
    
    @IBOutlet weak var Slide1: UISlider!
    @IBOutlet weak var lbl1_mini: UILabel!
    @IBOutlet weak var lbl1_max: UILabel!
    @IBOutlet weak var lbl1_price: UILabel!
    
    var refArtists: DatabaseReference!
    var locationManager = CLLocationManager()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboardWhenTappedAround()
        
        // set the price bounds
        let minBasePrice = Float(5)
        let maxBasePrice = Float(8)
        
        // set the min and max slider bounds to price bounds
        Slide1.minimumValue = minBasePrice
        Slide1.maximumValue = maxBasePrice
        
        print("the active spot base pricing is |\(AppState.sharedInstance.activeSpot.basePricing)|")
        
        // set the value of the price label
        lbl1_price.text = "$ 5.00"
        if AppState.sharedInstance.activeSpot.basePricing != ""{
            let basePRice = AppState.sharedInstance.activeSpot.basePricing.replacingOccurrences(of: " ", with: "")
            print("the base price is:\(basePRice)")
            Slide1.value = (basePRice as NSString).floatValue
            
            lbl1_price.text =  "$ \(basePRice)"
        }
        
        // set the values of the min and max bound labels
        lbl1_mini.text = "$\(String(format: "%.0f", minBasePrice))"
        lbl1_max.text = "$\(String(format: "%.0f", maxBasePrice))"
    }
    
    // handle when the slider is interacted with (rounding and settting price values)
    @IBAction func Slide1(_ sender: Any) {
        let index = String(format: "%.2f", ((round(Slide1!.value / 0.05) * 0.05)))
        
        // base price
        AppState.sharedInstance.activeSpot.basePricing = index
        lbl1_price.text = "$ \(AppState.sharedInstance.activeSpot.basePricing)"
        
        print(index)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
    
    // save spot changes within database
    @IBAction func postSpot(_ sender: Any) {
        AppState.sharedInstance.activeSpot.basePricing = lbl1_price.text!
        
        AppState.sharedInstance.activeSpot.basePricing =      (AppState.sharedInstance.activeSpot.basePricing).replacingOccurrences(of: "$", with: "", options: NSString.CompareOptions.literal, range: nil)
        
        let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
        self.navigationController!.popToViewController(viewControllers[viewControllers.count - 5], animated: true)
        AppState.sharedInstance.change = "change"
        
        if AppState.sharedInstance.activeSpot.spot_id == "" {
            AppState.sharedInstance.activeSpot.Save_Spot(SpotID:"")
        }
        else{
            AppState.sharedInstance.activeSpot.Save_Spot(SpotID:AppState.sharedInstance.activeSpot.spot_id)
        }
        
    }
}

