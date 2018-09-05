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
}

