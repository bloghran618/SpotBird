//
//  PriceViewController.swift
//  Spotbirdparking
//
//  Created by user138340 on 8/22/18.
//  Copyright © 2018 Spotbird. All rights reserved.
//

import UIKit
import Photos
import Firebase
import CoreLocation

class PriceViewController: UIViewController, UITextFieldDelegate,CLLocationManagerDelegate {
    
    @IBOutlet weak var hourlyPricing: UITextField!
    @IBOutlet weak var dailyPricing: UITextField!
    @IBOutlet weak var weeklyPricing: UITextField!
    @IBOutlet weak var monthlyPricing: UITextField!
    
    @IBOutlet weak var weeklyPricingOn: UISwitch!
    @IBOutlet weak var monthlyPricingOn: UISwitch!
    
    let hourlyPricingString = "1.00"
    let dailyPricingString = "7.00"
    let weeklyPricingString = "35.00"
    let monthlyPricingString = "105.00"
    
    var refArtists: DatabaseReference!
    var locationManager = CLLocationManager()
  
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
       // let currentLocation: CLLocation!
        
        if( CLLocationManager.authorizationStatus() == .authorizedWhenInUse ||
            CLLocationManager.authorizationStatus() ==  .authorizedAlways){
          // currentLocation = locManager.location
      
            
            let lat = (locationManager.location?.coordinate.latitude) as! NSNumber
            print(lat)
            
            let long = (locationManager.location?.coordinate.longitude) as! NSNumber
            print(long)
            
            AppState.sharedInstance.dict_spot.setValue(lat, forKey: "user_lat")
            AppState.sharedInstance.dict_spot.setValue(long, forKey: "user_long")
            
        }
     
        
        self.hideKeyboardWhenTappedAround()
        hourlyPricing.keyboardType = UIKeyboardType.decimalPad
        dailyPricing.keyboardType = UIKeyboardType.decimalPad
        weeklyPricing.keyboardType = UIKeyboardType.decimalPad
        monthlyPricing.keyboardType = UIKeyboardType.decimalPad
        
        //        AppState.sharedInstance.activeSpot.applyCalculatedPricing()
        //        hourlyPricing.text = AppState.sharedInstance.activeSpot.hourlyPricing
        //        dailyPricing.text = AppState.sharedInstance.activeSpot.dailyPricing
        //        weeklyPricing.text = AppState.sharedInstance.activeSpot.weeklyPricing
        //        monthlyPricing.text = AppState.sharedInstance.activeSpot.monthlyPricing
        
        AppState.sharedInstance.dict_spot.setValue(weeklyPricingOn.isOn, forKey: "switch_weekly")
        AppState.sharedInstance.dict_spot.setValue(monthlyPricingOn.isOn, forKey: "switch_monthly")
        weeklyPricingOn.addTarget(self, action: #selector(weeklyPricingSwitchChanged), for: UIControlEvents.valueChanged)
        monthlyPricingOn.addTarget(self, action: #selector(monthlyPricingSwitchChanged), for: UIControlEvents.valueChanged)
        
        AppState.sharedInstance.activeSpot.pringSpotCliffNotes()
        // Do any additional setup after loading the view.
        
        hourlyPricing.text = hourlyPricingString
        dailyPricing.text = dailyPricingString
        weeklyPricing.text = weeklyPricingString
        monthlyPricing.text = monthlyPricingString
        
        AppState.sharedInstance.dict_spot.setValue(hourlyPricingString, forKey: "hourlyPricing")
        AppState.sharedInstance.dict_spot.setValue(dailyPricingString, forKey: "dailyPricing")
        AppState.sharedInstance.dict_spot.setValue(weeklyPricingString, forKey: "weeklyPricing")
        AppState.sharedInstance.dict_spot.setValue(monthlyPricingString, forKey: "monthlyPricing")
    }
    
   
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if (textField == hourlyPricing) {
            //     AppState.sharedInstance.activeSpot.hourlyPricing = hourlyPricing.text!
            AppState.sharedInstance.dict_spot.setValue(hourlyPricing.text!, forKey: "hourlyPricing")
        }
        else if (textField == dailyPricing) {
            //   AppState.sharedInstance.activeSpot.dailyPricing = dailyPricing.text!
            AppState.sharedInstance.dict_spot.setValue(dailyPricing.text!, forKey: "dailyPricing")
        }
        else if (textField == weeklyPricing) {
            //    AppState.sharedInstance.activeSpot.weeklyPricing = weeklyPricing.text!
            AppState.sharedInstance.dict_spot.setValue(weeklyPricing.text!, forKey: "weeklyPricing")
        }
        else if (textField == monthlyPricing) {
            //   AppState.sharedInstance.activeSpot.monthlyPricing = monthlyPricing.text!
            AppState.sharedInstance.dict_spot.setValue(monthlyPricing.text!, forKey: "monthlyPricing")
        }
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if (textField == hourlyPricing) {
            //       AppState.sharedInstance.activeSpot.hourlyPricing = hourlyPricing.text!
            AppState.sharedInstance.dict_spot.setValue(hourlyPricing.text!, forKey: "hourlyPricing")
        }
        else if (textField == dailyPricing) {
            //      AppState.sharedInstance.activeSpot.dailyPricing = dailyPricing.text!
            AppState.sharedInstance.dict_spot.setValue(dailyPricing.text!, forKey: "dailyPricing")
        }
        else if (textField == weeklyPricing) {
            //     AppState.sharedInstance.activeSpot.weeklyPricing = weeklyPricing.text!
            AppState.sharedInstance.dict_spot.setValue(weeklyPricing.text!, forKey: "weeklyPricing")
        }
        else if (textField == monthlyPricing) {
            //       AppState.sharedInstance.activeSpot.monthlyPricing = monthlyPricing.text!
            AppState.sharedInstance.dict_spot.setValue(monthlyPricing.text!, forKey: "monthlyPricing")
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        hourlyPricing.resignFirstResponder()
        dailyPricing.resignFirstResponder()
        weeklyPricing.resignFirstResponder()
        monthlyPricing.resignFirstResponder()
        return true
    }
    
    @objc func weeklyPricingSwitchChanged(switchState: UISwitch) {
        //  AppState.sharedInstance.activeSpot.weeklyOn = switchState.isOn
        AppState.sharedInstance.dict_spot.setValue(switchState.isOn, forKey: "switch_weekly")
        
        if switchState.isOn {
            //  AppState.sharedInstance.activeSpot.weeklyPricing = AppState.sharedInstance.activeSpot.calculateReccomendedPricing()[2]
            //   weeklyPricing.text = AppState.sharedInstance.activeSpot.weeklyPricing
            AppState.sharedInstance.dict_spot.setValue(weeklyPricingString, forKey: "weeklyPricing")
            weeklyPricing.text = weeklyPricingString
        }
        else {
            // AppState.sharedInstance.activeSpot.weeklyPricing = ""
            weeklyPricing.text = ""
        }
        
        weeklyPricing.isEnabled = switchState.isOn
    }
    
    @objc func monthlyPricingSwitchChanged(switchState: UISwitch) {
        // AppState.sharedInstance.activeSpot.monthlyOn = switchState.isOn
        AppState.sharedInstance.dict_spot.setValue(switchState.isOn, forKey: "switch_monthly")
        
        if switchState.isOn {
            //            AppState.sharedInstance.activeSpot.monthlyPricing = AppState.sharedInstance.activeSpot.calculateReccomendedPricing()[3]
            //            monthlyPricing.text = AppState.sharedInstance.activeSpot.monthlyPricing
            AppState.sharedInstance.dict_spot.setValue(monthlyPricingString, forKey: "monthlyPricing")
            monthlyPricing.text = monthlyPricingString
            
        }
        else {
            //   AppState.sharedInstance.activeSpot.monthlyPricing = ""
            AppState.sharedInstance.dict_spot.setValue("", forKey: "monthlyPricing")
            monthlyPricing.text = ""
        }
        
        monthlyPricing.isEnabled = switchState.isOn
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    @IBAction func postSpot(_ sender: Any) {
        print(AppState.sharedInstance.dict_spot)
        
        var Image = UIImageView()
        Image.image = AppState.sharedInstance.dict_spot.value(forKey: "image") as! UIImage
        
        var imageReference: StorageReference {
            return Storage.storage().reference().child("spot")
        }
        
        guard let image = Image.image else { return }
        //        var imageData1 =  Data(UIImagePNGRepresentation(image)! )
        //         print("***** Uncompressed Size \(imageData1.description) **** ")
        
        guard let imageData = UIImageJPEGRepresentation(image, 0.5) else { return }
        
        //imageData = UIImageJPEGRepresentation(image!, 0.025)!
        print("***** Compressed Size \(imageData.description) **** ")
        
        let uploadImageRef = imageReference.child(randomStringWithLength(length: 5) as String)
        
        let uploadTask = uploadImageRef.putData(imageData, metadata: nil) { (metadata, error) in
            print("UPLOAD TASK FINISHED")
            print(metadata ?? "NO METADATA")
            print(error ?? "NO ERROR")
            
            
            
            uploadImageRef.downloadURL(completion: { (url, error) in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                if let url = url?.absoluteString {
                    let fullURL = url
                    print(fullURL)
                    
                    self.refArtists = Database.database().reference().child("Spots");
                    //
                  let key = self.refArtists.childByAutoId().key
                    
                    
                    print( AppState.sharedInstance.dict_spot.value(forKey: "switch_monthly"))
                    
                    
                    let spots = ["id":AppState.sharedInstance.userid,
                                "image":fullURL,
                                "description":AppState.sharedInstance.dict_spot.value(forKey: "address") as! String,
                                "address":AppState.sharedInstance.dict_spot.value(forKey: "address") as! String,
                                "city":AppState.sharedInstance.dict_spot.value(forKey: "city") as! String,
                                "state":AppState.sharedInstance.dict_spot.value(forKey: "state") as! String,
                                "zipcode":AppState.sharedInstance.dict_spot.value(forKey: "zipcode") as! String,
                                
                                "monStartTime":AppState.sharedInstance.dict_spot.value(forKey: "monStartTime") as! String,
                                "monEndTime":AppState.sharedInstance.dict_spot.value(forKey: "monEndTime") as! String,
                                
                                "tueStartTime":AppState.sharedInstance.dict_spot.value(forKey: "tueStartTime") as! String,
                                "tueEndTime":AppState.sharedInstance.dict_spot.value(forKey: "tueEndTime") as! String,
                                
                                "wedStartTime":AppState.sharedInstance.dict_spot.value(forKey: "wedStartTime") as! String,
                                "wedEndTime":AppState.sharedInstance.dict_spot.value(forKey: "wedEndTime") as! String,
                                
                                "thuStartTime":AppState.sharedInstance.dict_spot.value(forKey: "thuStartTime") as! String,
                                "thuEndTime":AppState.sharedInstance.dict_spot.value(forKey: "thuEndTime") as! String,
                                
                                "friStartTime":AppState.sharedInstance.dict_spot.value(forKey: "friStartTime") as! String,
                                "friEndTime":AppState.sharedInstance.dict_spot.value(forKey: "friEndTime") as! String,
                                
                                "satStartTime":AppState.sharedInstance.dict_spot.value(forKey: "satStartTime") as! String,
                                "satEndTime":AppState.sharedInstance.dict_spot.value(forKey: "satEndTime") as! String,
                                
                                "sunStartTime":AppState.sharedInstance.dict_spot.value(forKey: "sunStartTime") as! String,
                                "sunEndTime":AppState.sharedInstance.dict_spot.value(forKey: "sunEndTime") as! String,
                                
                                "dailyPricing":AppState.sharedInstance.dict_spot.value(forKey: "dailyPricing") as! String,
                                "hourlyPricing":AppState.sharedInstance.dict_spot.value(forKey: "hourlyPricing") as! String,
                                "weeklyPricing":AppState.sharedInstance.dict_spot.value(forKey: "weeklyPricing") as! String,
                                "monthlyPricing":AppState.sharedInstance.dict_spot.value(forKey: "monthlyPricing") as! String,
                                "switch_weekly":AppState.sharedInstance.dict_spot.value(forKey: "switch_weekly") as! Bool,
                                "switch_monthly":AppState.sharedInstance.dict_spot.value(forKey: "switch_monthly") as! Bool,
                                "user_lat":AppState.sharedInstance.dict_spot.value(forKey: "user_lat") as!  NSNumber,
                                "user_long":AppState.sharedInstance.dict_spot.value(forKey: "user_long") as!  NSNumber
                                ] as [String : Any]
                    
                   
                    self.refArtists.child(key!).setValue(spots)
                    
                }
                
            })
            
        }
        
        uploadTask.observe(.progress) { (snapshot) in
            print(snapshot.progress ?? "NO MORE PROGRESS")
        }
        
        uploadTask.resume()
        
        
        //        AppState.sharedInstance.addActiveSpot()
                let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController];
                self.navigationController!.popToViewController(viewControllers[viewControllers.count - 5], animated: true);
}
   
    func randomStringWithLength(length: Int) -> NSString {
        let characters: NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let randomString: NSMutableString = NSMutableString(capacity: length)
        
        for i in 0..<length {
            let len = UInt32(characters.length)
            let rand = arc4random_uniform(len)
            randomString.appendFormat("%C", characters.character(at: Int(rand)))
        }
        return randomString
    }
    
    
}
