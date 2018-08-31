//
//  Spot.swift
//  Spotbirdparking
//
//  Created by user138340 on 8/20/18.
//  Copyright © 2018 Spotbird. All rights reserved.
//

import Foundation
import UIKit

class Spot {
    var address: String
    
    var spotImage: UIImage?
    var description: String
    
    var monStartTime: String
    var monEndTime: String
    var tueStartTime: String
    var tueEndTime: String
    var wedStartTime: String
    var wedEndTime: String
    var thuStartTime: String
    var thuEndTime: String
    var friStartTime: String
    var friEndTime: String
    var satStartTime: String
    var satEndTime: String
    var sunStartTime: String
    var sunEndTime: String
    
    var monOn: Bool
    var tueOn: Bool
    var wedOn: Bool
    var thuOn: Bool
    var friOn: Bool
    var satOn: Bool
    var sunOn: Bool
    
    var hourlyPricing: String
    var dailyPricing: String
    var weeklyPricing: String
    var monthlyPricing: String
    
    var weeklyOn: Bool
    var monthlyOn: Bool
    
    
    init?(address: String, spotImage: UIImage, description: String, monStartTime: String, monEndTime: String, tueStartTime: String, tueEndTime: String, wedStartTime: String, wedEndTime: String, thuStartTime: String, thuEndTime: String, friStartTime: String, friEndTime: String, satStartTime: String, satEndTime: String, sunStartTime: String, sunEndTime: String, monOn: Bool, tueOn: Bool, wedOn: Bool, thuOn: Bool, friOn: Bool, satOn: Bool, sunOn: Bool, hourlyPricing: String, dailyPricing: String, weeklyPricing: String, monthlyPricing: String, weeklyOn: Bool, monthlyOn: Bool) {
        
        self.address = address
        
        self.spotImage = spotImage
        self.description = description
        
        self.monStartTime = monStartTime
        self.monEndTime = monEndTime
        self.tueStartTime = tueStartTime
        self.tueEndTime = tueEndTime
        self.wedStartTime = wedStartTime
        self.wedEndTime = wedEndTime
        self.thuStartTime = thuStartTime
        self.thuEndTime = thuEndTime
        self.friStartTime = friStartTime
        self.friEndTime = friEndTime
        self.satStartTime = satStartTime
        self.satEndTime = satEndTime
        self.sunStartTime = sunStartTime
        self.sunEndTime = sunEndTime
        
        self.monOn = monOn
        self.tueOn = tueOn
        self.wedOn = wedOn
        self.thuOn = thuOn
        self.friOn = friOn
        self.satOn = satOn
        self.sunOn = sunOn
        
        self.hourlyPricing = hourlyPricing
        self.dailyPricing = dailyPricing
        self.weeklyPricing = weeklyPricing
        self.monthlyPricing = monthlyPricing
        
        self.weeklyOn = weeklyOn
        self.monthlyOn = monthlyOn
    }
    
    init() {
        self.address = ""
        
        self.spotImage = UIImage.init(named: "addButton")
        self.description = ""
        
        self.monStartTime = "12:00 AM"
        self.monEndTime = "12:00 PM"
        self.tueStartTime = "12:00 AM"
        self.tueEndTime = "12:00 PM"
        self.wedStartTime = "12:00 AM"
        self.wedEndTime = "12:00 PM"
        self.thuStartTime = "12:00 AM"
        self.thuEndTime = "12:00 PM"
        self.friStartTime = "12:00 AM"
        self.friEndTime = "12:00 PM"
        self.satStartTime = "12:00 AM"
        self.satEndTime = "12:00 PM"
        self.sunStartTime = "12:00 AM"
        self.sunEndTime = "12:00 PM"
        
        self.monOn = true
        self.tueOn = true
        self.wedOn = true
        self.thuOn = true
        self.friOn = true
        self.satOn = true
        self.sunOn = true
        
        self.hourlyPricing = ""
        self.dailyPricing = ""
        self.weeklyPricing = ""
        self.monthlyPricing = ""
        
        self.weeklyOn = true
        self.monthlyOn = true
    }
    
    func calculateReccomendedPricing() -> Array<String> {
        let hourlyPricingString = "1.00"
        let dailyPricingString = "7.00"
        let weeklyPricingString = "35.00"
        let monthlyPricingString = "105.00"
        
        return [hourlyPricingString, dailyPricingString, weeklyPricingString, monthlyPricingString]
    }
    
    func applyCalculatedPricing() {
        var pricing = calculateReccomendedPricing()
        self.hourlyPricing = pricing[0]
        self.dailyPricing = pricing[1]
        self.weeklyPricing = pricing[2]
        self.monthlyPricing = pricing[3]
    }
    
    // check in on the state of Spot
    func pringSpotCliffNotes() {
        print(self.address)
        print(self.description)
        print(self.monStartTime)
        print(self.monEndTime)
        print(self.hourlyPricing)
    }
}

