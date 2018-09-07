//
//  User.swift
//  
//
//  Created by user138340 on 8/27/18.
//

import Foundation
import UIKit


class User {
    
    var firstName: String
    var lastName: String
    var profileImage: UIImage?
    var cars: [Car]
    
    init?(firstName: String, lastName: String, profileImage: UIImage, cars: [Car]) {
        self.firstName = firstName
        self.lastName = lastName
        self.profileImage = profileImage
        self.cars = cars
    }
    
    init() {
        self.firstName = ""
        self.lastName = ""
        self.profileImage = UIImage.init(named: "empytProfile")
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
}

