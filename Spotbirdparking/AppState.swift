//
//  appState.swift
//  Spotbirdparking
//
//  Created by user138340 on 8/27/18.
//  Copyright © 2018 Spotbird. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class AppState {
    static let sharedInstance = AppState()
    
   var lat:Double  = Double()
    var long:Double  = Double()
    
    var userid = ""
    var dict_spot: NSMutableDictionary = [:]
    var user: User
    var spots: [Spot]
    var activeSpot: Spot
    
    static let appStateRoot = Database.database().reference() // can change root
    let storageRef = Storage.storage().reference()
    
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
    
    func addActiveSpot() {
        if self.activeSpot.index == -1 { // indicates that we are in add mode
            self.spots.append(activeSpot)
        }
        else { // indicates we are in edit mode
            self.spots[self.activeSpot.index] = self.activeSpot
        }
        self.activeSpot = Spot() // clear active spot
    }

}
