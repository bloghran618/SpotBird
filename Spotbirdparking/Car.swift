//
//  Car.swift
//  Spotbirdparking
//
//  Created by user138340 on 5/31/18.
//  Copyright © 2018 Spotbird. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import SDWebImage

class Car {
    var make: String
    var model: String
    var year: String?
    //  var carImage: UIImage?
    var carImage: String
    var isDefault: Bool?
    var car_uid: String?
    
    
    init?(make: String, model: String, year: String, carImage: String, isDefault: Bool,car_id:String) {
        // Make sure make and model are defined
        if make.isEmpty || model.isEmpty {
            return nil
        }
        
        self.make = make
        self.model = model
        self.year = year
        self.carImage = carImage
        self.isDefault = isDefault
        car_uid = car_id
        
    }
}


