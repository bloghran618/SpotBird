//
//  Car.swift
//  Spotbirdparking
//
//  Created by user138340 on 4/26/18.
//  Copyright © 2018 Spotbird. All rights reserved.
//

import Foundation
import UIKit

class Car {
    
    //Mark: Properties
    var make: String
    var model: String
    var photo: UIImage?
    var year: Int?
    var defaultSetting: Bool
    
    //MARK: Initialization
    
    init?(make: String, model: String, photo: UIImage?, year: Int?, defaultSetting: Bool) {
        
        //Initialization should fail if no make/model
        if make.isEmpty || model.isEmpty {
            return nil
        }
        
        self.make =  make
        self.model = model
        self.photo = photo
        self.year = year
        self.defaultSetting = defaultSetting
        
    }
}
