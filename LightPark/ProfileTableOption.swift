//
//  ProfileTableOption.swift
//  LightPark
//
//  Created by Brian Loughran on 5/23/18.
//  Copyright © 2020 LightPark. All rights reserved.
//

import Foundation

class ProfileTableOption {
    var option: String?
    var description: String?
    var logoImageName: String?
    
    init(option: String, description: String, logoImageName: String) {
        self.option = option
        self.description = description
        self.logoImageName = logoImageName
    }
}
