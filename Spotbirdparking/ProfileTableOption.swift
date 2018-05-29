//
//  File.swift
//  Spotbirdparking
//
//  Created by user138340 on 5/23/18.
//  Copyright © 2018 Spotbird. All rights reserved.
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
