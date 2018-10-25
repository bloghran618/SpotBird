//
//  User.swift
//
//
//  Created by user138340 on 8/27/18.
//

import Foundation
import UIKit
import Firebase


class User {
    
    var firstName: String
    var lastName: String
    var profileImage: String
    var cars: [Car]
    
    
    init?(firstName: String, lastName: String, profileImage: String, cars: [Car]) {
        self.firstName = firstName
        self.lastName = lastName
        self.profileImage = profileImage
        self.cars = cars
        }
    
    init() {
        self.firstName = ""
        self.lastName = ""
        self.profileImage = ""
        self.cars = []
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
    
    // Get database to car
    public func Get_UserProfile() {
    var refArtists: DatabaseReference!
        let ref = Database.database().reference().child("User").queryOrdered(byChild: "id").queryEqual(toValue : AppState.sharedInstance.userid)
        ref.observe(.value, with:{ (snapshot: DataSnapshot) in
            if snapshot.exists() {
                
                for snap in snapshot.children {
                    let dict = ((snap as! DataSnapshot).value) as! NSDictionary
                   
                    
                    AppState.sharedInstance.user.firstName = (dict.value(forKey: "fname") as? String)!
                    AppState.sharedInstance.user.lastName = (dict.value(forKey: "lname") as? String)!
                    AppState.sharedInstance.user.profileImage = (dict.value(forKey: "image") as? String)!
                    
                    
                
                  
                }
            }
        })
        
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
            }
        })
    }
    
    // Set database to car
    func SetCar() {
        
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
