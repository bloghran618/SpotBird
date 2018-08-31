//
//  appState.swift
//  Spotbirdparking
//
//  Created by user138340 on 8/27/18.
//  Copyright © 2018 Spotbird. All rights reserved.
//

import Foundation
import UIKit

class AppState {
    static let sharedInstance = AppState()
    
    var user: User
    var spots: [Spot]
    var activeSpot: Spot
    
    init?(user: User, spots: [Spot], activeSpot: Spot) {
        self.user = user
        self.spots = spots
        self.activeSpot = activeSpot
    }
    
    init() {
        self.user = User()
        self.spots = []
        self.activeSpot = Spot()
    }
}
