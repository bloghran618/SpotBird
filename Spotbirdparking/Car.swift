//
//  Car.swift
//  Spotbirdparking
//
//  Created by user138340 on 5/31/18.
//  Copyright © 2018 Spotbird. All rights reserved.
//

import Foundation
import UIKit

class Car {
    var make: String
    var model: String
    var year: String?
  //  var carImage: UIImage?
    var carImage: String?
    var isDefault: Bool?
    var userid: String?

    
    init?(make: String, model: String, year: String, carImage: String,userid: String, isDefault: Bool) {
        // Make sure make and model are defined
        if make.isEmpty || model.isEmpty {
            return nil
        }
        
        self.make = make
        self.model = model
        self.year = year
        self.carImage = carImage
        self.isDefault = isDefault
        self.userid = userid
    }
}
