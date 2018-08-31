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
    var cars: [Car]
    
    init?(firstName: String, lastName: String, cars: [Car]) {
        self.firstName = firstName
        self.lastName = lastName
        self.cars = cars
    }
    
    init() {
        self.firstName = ""
        self.lastName = ""
        self.cars = []
    }
}

