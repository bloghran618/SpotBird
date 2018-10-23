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
    var controller = " "
    
    var refArtists: DatabaseReference!
    var locationManager = CLLocationManager()
 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboardWhenTappedAround()
        
        hourlyPricing.keyboardType = UIKeyboardType.decimalPad
        dailyPricing.keyboardType = UIKeyboardType.decimalPad
        weeklyPricing.keyboardType = UIKeyboardType.decimalPad
        monthlyPricing.keyboardType = UIKeyboardType.decimalPad
        
        AppState.sharedInstance.activeSpot.applyCalculatedPricing()
        hourlyPricing.text = AppState.sharedInstance.activeSpot.hourlyPricing
        dailyPricing.text = AppState.sharedInstance.activeSpot.dailyPricing
        weeklyPricing.text = AppState.sharedInstance.activeSpot.weeklyPricing
        monthlyPricing.text = AppState.sharedInstance.activeSpot.monthlyPricing
        
        weeklyPricingOn.addTarget(self, action: #selector(weeklyPricingSwitchChanged), for: UIControlEvents.valueChanged)
        monthlyPricingOn.addTarget(self, action: #selector(monthlyPricingSwitchChanged), for: UIControlEvents.valueChanged)
        
        AppState.sharedInstance.activeSpot.pringSpotCliffNotes()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if (textField == hourlyPricing) {
            AppState.sharedInstance.activeSpot.hourlyPricing = hourlyPricing.text!
        }
        else if (textField == dailyPricing) {
            AppState.sharedInstance.activeSpot.dailyPricing = dailyPricing.text!
        }
        else if (textField == weeklyPricing) {
            AppState.sharedInstance.activeSpot.weeklyPricing = weeklyPricing.text!
        }
        else if (textField == monthlyPricing) {
            AppState.sharedInstance.activeSpot.monthlyPricing = monthlyPricing.text!
        }
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if (textField == hourlyPricing) {
            AppState.sharedInstance.activeSpot.hourlyPricing = hourlyPricing.text!
        }
        else if (textField == dailyPricing) {
            AppState.sharedInstance.activeSpot.dailyPricing = dailyPricing.text!
        }
        else if (textField == weeklyPricing) {
            AppState.sharedInstance.activeSpot.weeklyPricing = weeklyPricing.text!
        }
        else if (textField == monthlyPricing) {
            AppState.sharedInstance.activeSpot.monthlyPricing = monthlyPricing.text!
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
        AppState.sharedInstance.activeSpot.weeklyOn = switchState.isOn
        
        if switchState.isOn {
            AppState.sharedInstance.activeSpot.weeklyPricing = AppState.sharedInstance.activeSpot.calculateReccomendedPricing()[2]
            weeklyPricing.text = AppState.sharedInstance.activeSpot.weeklyPricing
        }
        else {
            AppState.sharedInstance.activeSpot.weeklyPricing = ""
            weeklyPricing.text = ""
        }
        
        weeklyPricing.isEnabled = switchState.isOn
    }
    
    @objc func monthlyPricingSwitchChanged(switchState: UISwitch) {
        AppState.sharedInstance.activeSpot.monthlyOn = switchState.isOn
        
        if switchState.isOn {
            AppState.sharedInstance.activeSpot.monthlyPricing = AppState.sharedInstance.activeSpot.calculateReccomendedPricing()[3]
            monthlyPricing.text = AppState.sharedInstance.activeSpot.monthlyPricing
        }
        else {
            AppState.sharedInstance.activeSpot.monthlyPricing = ""
            monthlyPricing.text = ""
        }
        
        monthlyPricing.isEnabled = switchState.isOn
    }
    
    @IBAction func postSpot(_ sender: Any) {
        
        if AppState.sharedInstance.activeSpot.spot_id == ""
        {
            // ADD NEW SPOTS
            Add_newSpotS()
        }
        else {
            self.refArtists = Database.database().reference().child("User").child(AppState.sharedInstance.userid)
            
            refArtists.child("MySpots").observeSingleEvent(of: .value, with: { (snapshot) in
                print(AppState.sharedInstance.activeSpot.spot_id)
                print(snapshot)
                
                if snapshot.hasChild(AppState.sharedInstance.activeSpot.spot_id){
                    // Update SPOTS
                    self.Update_SpotS()
                }else{
                    // ADD NEW SPOTS
                    self.Add_newSpotS()
                }
            })
        }
    }
    
    // Update SPOTS
    func Update_SpotS()
    {
        showHud(message: "Update")
        let img_url = (AppState.sharedInstance.activeSpot.spotImage)
        print(img_url)
        let startIndex = img_url.index((img_url.startIndex), offsetBy: 80)
        let endIndex = img_url.index((img_url.startIndex), offsetBy: 84)
        let imgname =  String(img_url[startIndex...endIndex])
        print(imgname)
        
        var Image = UIImageView()
        Image.image = AppState.sharedInstance.activeSpot.spotImage1
        
        
        var imageReference: StorageReference {
            return Storage.storage().reference().child("spot")
        }
        
        guard let imageData = UIImageJPEGRepresentation(Image.image!, 0.5) else { return }
        let uploadImageRef = imageReference.child(String(imgname))
        
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
                    // Public
                    self.refArtists = Database.database().reference().child("All_Spots").child(AppState.sharedInstance.userid).child(AppState.sharedInstance.activeSpot.spot_id)
                    self.updatequery(data:  self.refArtists,url: fullURL)
                    
                    // Private
                    self.refArtists = Database.database().reference().child("User").child(AppState.sharedInstance.userid).child("MySpots").child(AppState.sharedInstance.activeSpot.spot_id);
                    self.updatequery(data:  self.refArtists,url: fullURL)
                    
                }
            })
        }
  }
    
    func updatequery(data:DatabaseReference,url:String) {
        
        self.refArtists.updateChildValues([
            "image":url,
            "description":AppState.sharedInstance.activeSpot.description,
            "address":AppState.sharedInstance.activeSpot.address,
            "city":AppState.sharedInstance.activeSpot.town,
            "state":AppState.sharedInstance.activeSpot.state,
            "zipcode":AppState.sharedInstance.activeSpot.zipCode,
            
            "monStartTime":AppState.sharedInstance.activeSpot.monStartTime,
            "monEndTime":AppState.sharedInstance.activeSpot.monEndTime,
            "tueStartTime":AppState.sharedInstance.activeSpot.tueStartTime,
            "tueEndTime":AppState.sharedInstance.activeSpot.tueEndTime,
            "wedStartTime":AppState.sharedInstance.activeSpot.wedStartTime,
            "wedEndTime":AppState.sharedInstance.activeSpot.wedEndTime,
            "thuStartTime":AppState.sharedInstance.activeSpot.thuStartTime,
            "thuEndTime":AppState.sharedInstance.activeSpot.thuEndTime,
            "friStartTime":AppState.sharedInstance.activeSpot.friStartTime,
            "friEndTime":AppState.sharedInstance.activeSpot.friEndTime,
            "satStartTime":AppState.sharedInstance.activeSpot.satStartTime,
            "satEndTime":AppState.sharedInstance.activeSpot.satEndTime,
            "sunStartTime":AppState.sharedInstance.activeSpot.sunStartTime,
            "sunEndTime":AppState.sharedInstance.activeSpot.sunEndTime,
            "dailyPricing":AppState.sharedInstance.activeSpot.dailyPricing,
            "hourlyPricing":AppState.sharedInstance.activeSpot.hourlyPricing,
            "weeklyPricing":AppState.sharedInstance.activeSpot.hourlyPricing,
            "monthlyPricing":AppState.sharedInstance.activeSpot.hourlyPricing,
            "switch_weekly":AppState.sharedInstance.activeSpot.weeklyOn,
            "switch_monthly":AppState.sharedInstance.activeSpot.monthlyOn,
            "user_lat":AppState.sharedInstance.lat,
            "user_long":AppState.sharedInstance.long,
            "monswitch":AppState.sharedInstance.activeSpot.monOn,
            "tueswitch":AppState.sharedInstance.activeSpot.tueOn,
            "wedswitch":AppState.sharedInstance.activeSpot.wedOn,
            "thuswitch":AppState.sharedInstance.activeSpot.thuOn,
            "friswitch":AppState.sharedInstance.activeSpot.friOn,
            "satswitch":AppState.sharedInstance.activeSpot.satOn,
            "sunswitch":AppState.sharedInstance.activeSpot.sunOn,
            ]){
                (error:Error?, ref:DatabaseReference) in
                if let error = error {
                    print("Data could not be Update: \(error).")
                     self.hideHUD()
                } else {
                    print("Data Update successfully!")
                self.hideHUD()
                }
        }
     }
    
    // ADD NEW SPOTS
    func Add_newSpotS()
    {
        showHud(message: "Save")
        var Image = UIImageView()
        Image.image = AppState.sharedInstance.activeSpot.spotImage1
        
        var imageReference: StorageReference {
            return Storage.storage().reference().child("spot")
        }
        
        guard let image = Image.image else { return }
        guard let imageData = UIImageJPEGRepresentation(image, 0.5) else { return }
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
                      self.refArtists = Database.database().reference().child("All_Spots")
                    let key = self.refArtists.childByAutoId().key
                    
                    let spots = ["id":key,
                                 "image":fullURL,
                                 "description":AppState.sharedInstance.activeSpot.description,
                                 "address":AppState.sharedInstance.activeSpot.address,
                                 "city":AppState.sharedInstance.activeSpot.town,
                                 "state":AppState.sharedInstance.activeSpot.state,
                                 "zipcode":AppState.sharedInstance.activeSpot.zipCode,
                                 
                                 "monStartTime":AppState.sharedInstance.activeSpot.monStartTime,
                                 "monEndTime":AppState.sharedInstance.activeSpot.monEndTime,
                                 "tueStartTime":AppState.sharedInstance.activeSpot.tueStartTime,
                                 "tueEndTime":AppState.sharedInstance.activeSpot.tueEndTime,
                                 "wedStartTime":AppState.sharedInstance.activeSpot.wedStartTime,
                                 "wedEndTime":AppState.sharedInstance.activeSpot.wedEndTime,
                                 "thuStartTime":AppState.sharedInstance.activeSpot.thuStartTime,
                                 "thuEndTime":AppState.sharedInstance.activeSpot.thuEndTime,
                                 "friStartTime":AppState.sharedInstance.activeSpot.friStartTime,
                                 "friEndTime":AppState.sharedInstance.activeSpot.friEndTime,
                                 "satStartTime":AppState.sharedInstance.activeSpot.satStartTime,
                                 "satEndTime":AppState.sharedInstance.activeSpot.satEndTime,
                                 "sunStartTime":AppState.sharedInstance.activeSpot.sunStartTime,
                                 "sunEndTime":AppState.sharedInstance.activeSpot.sunEndTime,
                                 "dailyPricing":AppState.sharedInstance.activeSpot.dailyPricing,
                                 "hourlyPricing":AppState.sharedInstance.activeSpot.hourlyPricing,
                                 "weeklyPricing":AppState.sharedInstance.activeSpot.hourlyPricing,
                                 "monthlyPricing":AppState.sharedInstance.activeSpot.hourlyPricing,
                                 "switch_weekly":AppState.sharedInstance.activeSpot.weeklyOn,
                                 "switch_monthly":AppState.sharedInstance.activeSpot.monthlyOn,
                                 "user_lat":AppState.sharedInstance.lat,
                                 "user_long":AppState.sharedInstance.long,
                                 "monswitch":AppState.sharedInstance.activeSpot.monOn,
                                 "tueswitch":AppState.sharedInstance.activeSpot.tueOn,
                                 "wedswitch":AppState.sharedInstance.activeSpot.wedOn,
                                 "thuswitch":AppState.sharedInstance.activeSpot.thuOn,
                                 "friswitch":AppState.sharedInstance.activeSpot.friOn,
                                 "satswitch":AppState.sharedInstance.activeSpot.satOn,
                                 "sunswitch":AppState.sharedInstance.activeSpot.sunOn,
                                 ] as [String : Any]
                    
                    print(spots)
                    
                    self.refArtists = Database.database().reference().child("All_Spots")
                    self.refArtists.child(key!).setValue(spots)
                    
                    self.refArtists = Database.database().reference().child("User").child(AppState.sharedInstance.userid).child("MySpots");
                    self.refArtists.child(key!).setValue(spots){
                        (error:Error?, ref:DatabaseReference) in
                        if let error = error {
                            print("Data could not be saved: \(error).")
                             self.hideHUD()
                        } else {
                            print("Data saved successfully!")
                         self.hideHUD()
                           
                        }
                    }
                    
                }
             })
        }
        
        uploadTask.observe(.progress) { (snapshot) in
            print(snapshot.progress ?? "NO MORE PROGRESS")
        }
        
        uploadTask.resume()
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

