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
