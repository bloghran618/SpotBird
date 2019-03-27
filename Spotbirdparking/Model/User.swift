//
//  User.swift
//
//
//  Created by user138340 on 8/27/18.
//

import Foundation
import UIKit
import Firebase
import Alamofire

class User {
    
    var firstName: String
    var lastName: String
    var profileImage: String
    var cars: [Car]
    var New_img = UIImageView()
    var imgname = ""
    var accounttoken = String()
    var customertoken = String()
    var reservations: [Reservation]
    
    var avg1 = Int()
    var avg2 = Int()
    var avg3 = Int()
    var avg4 = Int()
   
    var refArtists: DatabaseReference!
   
    init?(firstName: String, lastName: String, profileImage: String, cars: [Car], reservations: [Reservation]) {
        self.firstName = firstName
        self.lastName = lastName
        self.profileImage = profileImage
        self.cars = cars
        self.reservations = reservations
    }
    
    init() {
        self.firstName = ""
        self.lastName = ""
        self.profileImage = ""
        self.cars = []
        self.reservations = []
    }
    
    public func manageOneDefaultCar(carIndex: Int) {
        // Manage min one default
        var isOneDefault = false
        for eachCar in self.cars {
            if eachCar.isDefault == true {
                isOneDefault = true
            }
        }
        
        // Manage max one default
        if cars[carIndex].isDefault == true {
            for eachCar in self.cars {
                eachCar.isDefault = false
            }
            cars[carIndex].isDefault = true
        }
        
        print("one default? : \(isOneDefault)")
        print("cars.count: \(cars.count)")
        if isOneDefault == false && cars.count > 0 {
            cars[0].isDefault = true
        }
        return
     }
    
    // get the Car object of the default car
    public func getDefaultCar() -> Car {
        for car in self.cars {
            if(car.isDefault!) {
                return car
            }
        }
        // if algorithm cannot find default, return first car
        return self.cars[0]
    }
    
    // Set a reservation with the owner of a spot
    public func setReservation(reservation: [Reservation]) {
        
    }
  
//    public func getReservations() -> [Reservation] {
//
//    }
    
    // Get database to car
    public func Get_UserProfile() {
        var refArtists: DatabaseReference!
        let ref = Database.database().reference().child("User").queryOrdered(byChild: "id").queryEqual(toValue : AppState.sharedInstance.userid)
        ref.observe(.value, with:{ (snapshot: DataSnapshot) in
            if snapshot.exists() {
                
                for snap in snapshot.children {
                    let dict = ((snap as! DataSnapshot).value) as! NSDictionary
                    
                    
                    let logindata = ["fname":dict.value(forKey: "fname") as! String,"id":dict.value(forKey: "id") as! String,"image":dict.value(forKey: "image") as! String,"lname":dict.value(forKey: "lname") as! String,"uname":dict.value(forKey: "uname") as! String,"email":dict.value(forKey: "email") as! String]
                    
                    
                    UserDefaults.standard.setValue(logindata, forKey: "logindata")
                    UserDefaults.standard.synchronize()
                    let data_login = UserDefaults.standard.value(forKey: "logindata") as! NSDictionary
                    print(data_login)
                    
                    AppState.sharedInstance.user.firstName = (data_login.value(forKey: "fname") as? String)!
                    AppState.sharedInstance.user.lastName = (data_login.value(forKey: "lname") as? String)!
                    AppState.sharedInstance.user.profileImage = (dict.value(forKey: "image") as? String)!
                    
                    if AppState.sharedInstance.user.profileImage != "" {
                        let strurl = AppState.sharedInstance.user.profileImage
                        let startIndex = strurl.index(strurl.startIndex, offsetBy: 81)
                        let endIndex = strurl.index(strurl.startIndex, offsetBy: 85)
                        AppState.sharedInstance.user.imgname =  String(strurl[startIndex...endIndex])
                    }
                    
                }
            }
        })
    }
    
    // Set database to car
    public func Set_UserProfile(change:String) {
        Spinner.start()
        var imageReference: StorageReference {
            return Storage.storage().reference().child("User")
        }
        
        if change == "nil"{
            let str = "User/" + AppState.sharedInstance.userid
            let ref = Database.database().reference().child(str)
            print(AppState.sharedInstance.user.firstName)
            print(AppState.sharedInstance.user.lastName)
            
            ref.updateChildValues([
                "fname":AppState.sharedInstance.user.firstName,
                "lname":AppState.sharedInstance.user.lastName,
                ]){
                    (error:Error?, ref:DatabaseReference) in
                    if let error = error {
                        print("Data could not be saved: \(error).")
                        Spinner.stop()
                        
                    } else {
                        print("Data saved successfully!")
                        self.Get_UserProfile()  //
                        Spinner.stop()
                    }
            }
        }
        else if change == "same"
        {
            let pictureRef = Storage.storage().reference().child("User").child(AppState.sharedInstance.userid).child(imgname)
            pictureRef.delete { error in
                if let error = error {
                } else {
                    guard let imageData = UIImageJPEGRepresentation(self.New_img.image!, 0.5) else { return }
                    let uploadImageRef = imageReference.child(self.randomStringWithLength(length: 5) as String)
                    
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
                                
                                let str = "User/" + AppState.sharedInstance.userid
                                print(str)
                                let ref = Database.database().reference().child(str)
                                
                                ref.updateChildValues([
                                    "fname":AppState.sharedInstance.user.firstName,
                                    "lname":AppState.sharedInstance.user.lastName,
                                    "image":fullURL
                                ]){
                                    (error:Error?, ref:DatabaseReference) in
                                    if let error = error {
                                        print("Data could not be saved: \(error).")
                                        Spinner.stop()
                                        
                                    } else {
                                        print("Data saved successfully!")
                                         self.Get_UserProfile()  //
                                        Spinner.stop()
                                    }
                                }
                            }
                        })
                    }
                    uploadTask.observe(.progress) { (snapshot) in
                        print(snapshot.progress ?? "NO MORE PROGRESS")
                    }
                }
            }
            
        }
        else
        {
            //   let pictureRef = Storage.storage().reference().child("User/\(imgname)")
            
            guard let imageData = UIImageJPEGRepresentation(New_img.image!, 0.5) else { return }
            let uploadImageRef = imageReference.child(String(imgname))
            
            let uploadTask = uploadImageRef.putData(imageData, metadata: nil) { (metadata, error) in
                uploadImageRef.downloadURL(completion: { (url, error) in
                    if let error = error {
                        print(error.localizedDescription)
                        return
                    }
                    if let url = url?.absoluteString {
                        let fullURL = url
                        print(fullURL)
                        
                        let str = "User/" + AppState.sharedInstance.userid
                        print(str)
                        let ref = Database.database().reference().child(str)
                        
                        ref.updateChildValues([
                            "fname":AppState.sharedInstance.user.firstName,
                            "lname":AppState.sharedInstance.user.lastName,
                            "image":fullURL
                        ]){
                            (error:Error?, ref:DatabaseReference) in
                            if let error = error {
                                print("Data could not be saved: \(error).")
                                Spinner.stop()
                                
                            } else {
                                print("Data saved successfully!")
                                 self.Get_UserProfile()  //
                                Spinner.stop()
                            }
                        }
                    }
                })
            }
            uploadTask.observe(.progress) { (snapshot) in
                print(snapshot.progress ?? "NO MORE PROGRESS")
            }
            
            
        }
    }
    
    // Get database to car
    public func GetCar() {
        
     var refArtists: DatabaseReference!
        refArtists = Database.database().reference().child("User").child(AppState.sharedInstance.userid).child("Cars")
        refArtists.observe(DataEventType.value, with: { (snapshot) in
            
            if snapshot.childrenCount > 0 {
                AppState.sharedInstance.user.cars.removeAll()
                for artists in snapshot.children.allObjects as! [DataSnapshot] {
                    let snapshotValue = ((snapshot.value as! NSDictionary).value(forKey: (artists as! DataSnapshot).key)) as! NSDictionary
                    AppState.sharedInstance.user.cars.append(Car(make: snapshotValue.value(forKey: "make") as! String, model: snapshotValue.value(forKey: "model") as! String, year: snapshotValue.value(forKey: "year") as! String, carImage: snapshotValue.value(forKey: "image") as! String, isDefault: snapshotValue.value(forKey: "default") as! Bool,car_id:(artists as! DataSnapshot).key)!)
                    
                }
                Spinner.stop()
                NotificationCenter.default.post(name: Notification.Name("cars"), object: nil)
            }
        })
    }
    
    
    // Set database to car
  func SetCar(car_uid :String,make:String,Model:String,year:String,setbool:Bool,image:UIImage,strurl:String) {
   
       Spinner.start()
    
        if car_uid == "" {
            self.addnewcar(car_uid :car_uid,make:make,Model:Model,year:year,setbool:setbool,carimage:image)
        }else {
            var refArtists: DatabaseReference!
            
            refArtists = Database.database().reference().child("User").child(AppState.sharedInstance.userid)
            
            refArtists.child("Cars").observeSingleEvent(of: .value, with: { (snapshot) in
                print(car_uid)
                print(snapshot)
                
                if snapshot.hasChild(car_uid){
                    //Update CAr
                    self.Update_car(car_uid: car_uid, make: make, Model: Model, year: year, setbool: setbool, carimage: image, url: strurl)
                }else{
                    // Add New CAr
        self.addnewcar(car_uid :car_uid,make:make,Model:Model,year:year,setbool:setbool,carimage:image)
                }
            })
        }
     }
    
    //Update CAr
    func Update_car(car_uid :String,make:String,Model:String,year:String,setbool:Bool,carimage:UIImage,url:String)
    {
        var refArtists: DatabaseReference!
        print(url)
        let startIndex = url.index((url.startIndex), offsetBy: 80)
        let endIndex = url.index((url.startIndex), offsetBy: 84)
        let imgname =  String(url[startIndex...endIndex])
        print(imgname)
        
        
        var imageReference: StorageReference {
            return Storage.storage().reference().child("car")
        }
        
        guard let imageData = UIImageJPEGRepresentation(carimage, 0.5) else { return }
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
                    
    let ref = Database.database().reference().child("User").child(AppState.sharedInstance.userid).child("Cars").child(car_uid)
                    
                    ref.updateChildValues([
                        "make":make,
                        "model":Model,
                        "year": year,
                        "image": fullURL,
                        "default": setbool]){
                            (error:Error?, ref:DatabaseReference) in
                            if let error = error {
                                print("Data could not be Update: \(error).")
                          
                             } else {
                                print("Data Update successfully!")
                                self.GetCar()
                          
                              }
                    }
                }
            })
        }
    }
    
    // Add New CAr
    func addnewcar(car_uid :String,make:String,Model:String,year:String,setbool:Bool,carimage:UIImage)
    {
        
        var refArtists: DatabaseReference!
        
        var imageReference: StorageReference {
            return Storage.storage().reference().child("car")
        }
        
        // guard let image = carimage else { return }
        guard let imageData = UIImageJPEGRepresentation(carimage, 0.5) else { return }
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
                    
                    refArtists = Database.database().reference().child("User").child(AppState.sharedInstance.userid).child("Cars");
                    
                    let key = refArtists.childByAutoId().key
                    
                    let cars = [  "make":make,
                                  "model":Model,
                                  "year": year,
                                  "image": fullURL,
                                  "default": setbool
                        ] as [String : Any]
                    
                    refArtists.child(key!).setValue(cars){
                        (error:Error?, ref:DatabaseReference) in
                        if let error = error {
                            print("Data could not be saved: \(error).")
                            Spinner.stop()
                        
                        } else {
                            print("Data saved successfully!")
                            self.GetCar()
                                    //  Spinner.stop()
                         }
                    }
                  }
              })
         }
        uploadTask.observe(.progress) { (snapshot) in
            print(snapshot.progress ?? "NO MORE PROGRESS")
        }
        uploadTask.resume()
    }
    
    // Add New CAr
    func Delete_car(car_dict :Car,index:Int)
    {
        var refArtists: DatabaseReference!
        print(car_dict)
        
        let url = car_dict.carImage
        let start = url.index(url.startIndex, offsetBy: 80)
        let end = url.index(url.endIndex, offsetBy: -53)
        let range = start..<end
        let imgname = url[range]
        print(imgname)
        
        let pictureRef = Storage.storage().reference().child("car/\(imgname)")
        pictureRef.delete { error in
            if let error = error {
                // Uh-oh, an error occurred!
            } else {
                // File deleted successfully
            }
        }
        
        refArtists = Database.database().reference().child("User").child(AppState.sharedInstance.userid)
        
        refArtists.child("Cars").observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.hasChild((car_dict.car_uid)!){
                refArtists = Database.database().reference().child("User").child(AppState.sharedInstance.userid).child("Cars")
               refArtists.child(car_dict.car_uid!).setValue(nil)
            }else{
                print("jewsasassasass")
            }
        })
        
        AppState.sharedInstance.user.cars.remove(at: index)
        
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
    
    
    // Set accountToken token
    func setaccountToken(accountToken:String)  {
        self.accounttoken = accountToken
       refArtists = Database.database().reference().child("User").child(AppState.sharedInstance.userid)
        refArtists.updateChildValues([
            "accountToken":accountToken
            ])
    
    }
    
    // Set customerToken token
    func setcustomerToken(customerToken:String)  {
        self.customertoken = customerToken
        refArtists = Database.database().reference().child("User").child(AppState.sharedInstance.userid)
        refArtists.updateChildValues([
            "customerToken":customerToken
            ])
        
    }
    
    // getaccountToken
    func getaccountToken(completion: @escaping (_ keys: String) -> Void) {
        let ref = Database.database().reference().child("User").queryOrdered(byChild: "id").queryEqual(toValue : AppState.sharedInstance.userid)
        ref.observe(.value, with:{ (snapshot: DataSnapshot) in
            if snapshot.exists() {
                for snap in snapshot.children {
                    let dict = ((snap as! DataSnapshot).value) as! NSDictionary
                    print(dict)
                    if let val = dict["accountToken"] {
                     completion(dict.value(forKey: "accountToken") as! String)
                    }
                }
            }
        })
    }
    
    // getcustomerToken
    func getcustomerToken(completion: @escaping (_ keys: String) -> Void) {
        let ref = Database.database().reference().child("User").queryOrdered(byChild: "id").queryEqual(toValue : AppState.sharedInstance.userid)
        ref.observe(.value, with:{ (snapshot: DataSnapshot) in
            if snapshot.exists() {
                for snap in snapshot.children {
                    let dict = ((snap as! DataSnapshot).value) as! NSDictionary
                    print(dict)
                    if let val = dict["customerToken"] {
                        completion(dict.value(forKey: "customerToken") as! String)
                    }
                }
            }
        })
    } 
    
    
    /*
     public func setFirstName(name: String) {
     self.firstName = name
     let firstNameRef = AppState.appStateRoot.child("User/").child(AppState.sharedInstance.userid)
     firstNameRef.setValue(name)
     }
     
     public func setLastName(name: String) {
     self.lastName = name
     let lastNameRef = AppState.appStateRoot.child("User/").child(AppState.sharedInstance.userid)
     lastNameRef.setValue(name)
     }
     
     
     public func setProfileImage(profile: str) {
     var data = Data()
     data = UIImagePNGRepresentation(profile)!
     let filePath = "profilePicture"
     //        let profileImageRef = AppState.sharedInstance.storageRef.child("user").child("profilePicture")
     let metaData = StorageMetadata()
     metaData.contentType = "image/png"
     
     AppState.sharedInstance.storageRef.child(filePath).putData(data, metadata: metaData) {(metaData,error) in
     if let error = error {
     print(error.localizedDescription)
     return
     }
     //            else {
     //                //store downloadURL
     //                let downloadURL = metaData!.downloadURL()!.absoluteString
     //                //store downloadURL at database
     //                self.databaseRef.child("users").child(FIRAuth.auth()!.currentUser!.uid).updateChildValues(["userPhoto": downloadURL])
     //            }
     
     }
     
     self.profileImage = profile
     }
     
     */
    
    
}
