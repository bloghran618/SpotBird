//
//  Login_ViewController.swift
//  Spotbirdparking
//
//  Created by mac on 01/10/18.
//  Copyright © 2018 Spotbird. All rights reserved.
//
import UIKit
import Firebase
import FirebaseAuth

class Login_ViewController: UIViewController {
    
    @IBOutlet weak var txt_uname: UITextField!
    @IBOutlet weak var txt_pass: UITextField!
    
    var refArtists: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        txt_uname.autocorrectionType  = .no
        txt_pass.autocorrectionType = .no
        view.endEditing(true)
        
        txt_uname.text = "a@gmail.com"
        txt_pass.text = "12345678"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func btn_newuser(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "Signup_ViewController") as! Signup_ViewController
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func btn_login(_ sender: Any) {
        
        Spinner.start()
        let ref = Database.database().reference().child("User").queryOrdered(byChild: "uname").queryEqual(toValue : txt_uname.text!)
        ref.observe(.value, with:{ (snapshot: DataSnapshot) in
            
            if snapshot.exists()  {
                
                for snap in snapshot.children {
                    
                    let dict = ((snap as! DataSnapshot).value) as! NSDictionary
                   
                   if self.txt_pass.text! == dict.value(forKey: "pass") as! String {
                        let id = ((snap as! DataSnapshot).key)
                        AppState.sharedInstance.userid = dict.value(forKey: "id") as! String
                        
                      print(dict)
                    
                    if let val = dict["MySpots"] {
                        var array =  NSMutableArray()
                        let dictspot =  dict.value(forKey: "MySpots") as! NSDictionary
                        print(dictspot)
                        let keys = dictspot.allKeys
                        print(keys)
                        
                        for i in 0..<keys.count {
                            let indexdict =  dictspot.value(forKey: keys[i] as! String) as!  NSDictionary
                            print(indexdict)
                            array.add(indexdict)
                         }
                          print(array)
                        // make model class data
                         self.Myspots(spotarray: array, key: id)
                    }
                    
                    if let val = dict["Cars"] {
                        var array =  NSMutableArray()
                        let dictspot =  dict.value(forKey: "Cars") as! NSDictionary
                        print(dictspot)
                        let keys = dictspot.allKeys
                        print(keys)
                        
                        for i in 0..<keys.count {
                            let indexdict =  dictspot.value(forKey: keys[i] as! String) as!  NSDictionary
                            print(indexdict)
                            array.add(indexdict)
                        }
                        print(array)
                        // make model class data
                        self.MyCars(carsarray: array, key: id)
                    }
                    
                    var logindata =  NSMutableDictionary()
                    
                    logindata.setValue(dict.value(forKey: "fname") as!String, forKey: "fname")
                    logindata.setValue(dict.value(forKey: "id") as!String, forKey: "id")
                    logindata.setValue(dict.value(forKey: "email") as!String, forKey: "email")
                    logindata.setValue(dict.value(forKey: "lname") as!String, forKey: "lname")
                    
                    if dict.value(forKey: "image") != nil{
                     logindata.setValue(dict.value(forKey: "image") as!String, forKey: "CustomerToken")
                    }
                    if dict.value(forKey: "CustomerToken") != nil{
                        logindata.setValue(dict.value(forKey: "CustomerToken") as!String, forKey: "CustomerToken")
                    }
                    if dict.value(forKey: "accountToken") != nil{
                        logindata.setValue(dict.value(forKey: "accountToken") as!String, forKey: "accountToken")
                    }
                    
                   
                    
                    
//                    let logindata = ["fname":dict.value(forKey: "fname") as!String,"id":dict.value(forKey: "id") as! String,"image":dict.value(forKey: "image") as? String,"lname":dict.value(forKey: "lname") as! String,"uname":dict.value(forKey: "uname") as! String,"email":dict.value(forKey: "email") as! String,"customerToken":dict.value(forKey:"CustomerToken") as? String,"accountToken":dict.value(forKey:"accountToken") as? String]
                    
                    print("Last name 1: \(AppState.sharedInstance.user.lastName)")
                    print("Customer Token 1: \(AppState.sharedInstance.user.customertoken)")
                        
                        UserDefaults.standard.setValue(logindata, forKey: "logindata")
                        UserDefaults.standard.synchronize()
                        let data_login = UserDefaults.standard.value(forKey: "logindata") as! NSDictionary
                        print(data_login)
                        
                        AppState.sharedInstance.user.customertoken = data_login.value(forKey: "customerToken") as? String ?? ""
                        AppState.sharedInstance.user.accounttoken = data_login.value(forKey: "accountToken") as? String ?? ""
                        AppState.sharedInstance.user.firstName = (data_login.value(forKey: "fname") as? String)!
                        AppState.sharedInstance.user.lastName = (data_login.value(forKey: "lname") as? String)!
                        AppState.sharedInstance.user.profileImage = (dict.value(forKey: "image") as? String)!
                    
                    print("Last name 2: \(AppState.sharedInstance.user.lastName)")
                    print("Customer Token 2: \(AppState.sharedInstance.user.customertoken)")
                        
                        if AppState.sharedInstance.user.profileImage != "" {
                            let strurl = AppState.sharedInstance.user.profileImage
                            let startIndex = strurl.index(strurl.startIndex, offsetBy: 81)
                            let endIndex = strurl.index(strurl.startIndex, offsetBy: 85)
                            AppState.sharedInstance.user.imgname =  String(strurl[startIndex...endIndex])
                        }
                        
                        Spinner.stop()
                        let appDelegate = UIApplication.shared.delegate! as! AppDelegate
                        let initialViewController = self.storyboard!.instantiateViewController(withIdentifier: "myTabbarControllerID")
                        appDelegate.window?.rootViewController = initialViewController
                        appDelegate.window?.makeKeyAndVisible()
                        
                    }else {
                        Spinner.stop()
                        let alertController = UIAlertController(title: "Error", message: "Incorrect Password..", preferredStyle: .alert)
                        let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                        alertController.addAction(defaultAction)
                        self.present(alertController, animated: true, completion: nil)
                    }
                }
            }
            else{
                  Spinner.stop()
                let alertController = UIAlertController(title: "Spotbird", message: "Record Not Found..", preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(defaultAction)
                self.present(alertController, animated: true, completion: nil)
            }
        })
    }
    
    func Myspots(spotarray:NSArray,key:String) {
        
        for i in 0..<spotarray.count{
            let snapshotValue = spotarray.object(at: i) as! NSDictionary
            
            let dblat = snapshotValue.value(forKey: "user_lat") as! String
            let dblongitude =  snapshotValue.value(forKey: "user_long") as! String
            
            AppState.sharedInstance.spots.append(Spot(address: snapshotValue.value(forKey: "address") as!
                String, town: snapshotValue.value(forKey: "city") as! String,
                        state: snapshotValue.value(forKey: "state") as! String,
                        zipCode:(snapshotValue.value(forKey: "zipcode") as? String)!,
                        
                        spotImage: snapshotValue.value(forKey: "image") as! String,
                        description: snapshotValue.value(forKey: "description") as! String,
                        
                        monStartTime: snapshotValue.value(forKey: "monStartTime") as! String,
                        monEndTime: snapshotValue.value(forKey: "monEndTime") as! String,
                        tueStartTime:(snapshotValue.value(forKey: "tueStartTime") as? String)!,
                        tueEndTime: snapshotValue.value(forKey: "tueEndTime") as! String,
                        wedStartTime: snapshotValue.value(forKey: "wedStartTime") as! String,
                        wedEndTime: snapshotValue.value(forKey: "wedEndTime") as! String,
                        thuStartTime: snapshotValue.value(forKey: "thuStartTime") as! String,
                        thuEndTime: snapshotValue.value(forKey: "thuEndTime") as! String,
                        friStartTime: snapshotValue.value(forKey: "friStartTime") as! String,
                        friEndTime: snapshotValue.value(forKey: "friEndTime") as! String,
                        satStartTime: snapshotValue.value(forKey: "satStartTime") as! String,
                        satEndTime: snapshotValue.value(forKey: "satEndTime") as! String,
                        sunStartTime: snapshotValue.value(forKey: "sunStartTime") as! String,
                        sunEndTime: snapshotValue.value(forKey: "sunEndTime") as! String,
                        
                        monOn: snapshotValue.value(forKey: "monswitch") as! Bool,
                        tueOn:snapshotValue.value(forKey: "tueswitch") as! Bool,
                        wedOn: snapshotValue.value(forKey: "wedswitch") as! Bool,
                        thuOn: snapshotValue.value(forKey: "thuswitch") as! Bool,
                        friOn: snapshotValue.value(forKey: "friswitch") as! Bool,
                        satOn: snapshotValue.value(forKey: "satswitch") as! Bool,
                        sunOn: snapshotValue.value(forKey: "sunswitch") as! Bool,
                        
                        hourlyPricing: snapshotValue.value(forKey: "hourlyPricing") as! String,
                        dailyPricing: snapshotValue.value(forKey: "dailyPricing") as! String,
                        weeklyPricing: snapshotValue.value(forKey: "weeklyPricing") as! String,
                        monthlyPricing: snapshotValue.value(forKey: "monthlyPricing") as! String,
                        
                        weeklyOn: snapshotValue.value(forKey: "switch_weekly") as! Bool,
                        monthlyOn: snapshotValue.value(forKey: "switch_monthly") as! Bool,
                        index: -1,
                        approved:false, spotImages: UIImage.init(named: "white")!, spots_id: key, latitude: dblat, longitude: dblongitude, spottype: snapshotValue.value(forKey: "spot_type") as! String, owner_id: snapshotValue.value(forKey: "owner_id") as! String, Email: snapshotValue.value(forKey: "Email") as! String, baseprice: snapshotValue.value(forKey: "basePricing") as! String)!)
        }
    }
    
       // MY CARS _
       func MyCars(carsarray:NSArray,key:String) {
        for i in 0..<carsarray.count{
            let snapshotValue = carsarray.object(at: i) as! NSDictionary
        
          AppState.sharedInstance.user.cars.append(Car(make: snapshotValue.value(forKey: "make") as! String, model: snapshotValue.value(forKey: "model") as! String, year: snapshotValue.value(forKey: "year") as! String, carImage: snapshotValue.value(forKey: "image") as! String, isDefault: snapshotValue.value(forKey: "default") as! Bool,car_id:key)!)
        }
    }
}
