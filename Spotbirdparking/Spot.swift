//
//  Spot.swift
//  Spotbirdparking
//
//  Created by user138340 on 8/20/18.
//  Copyright © 2018 Spotbird. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import SDWebImage

class Spot {
    var address: String
    var town: String
    var state: String
    var zipCode: String
    
    var spotImage1: UIImage
    var spotImage: String
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
    
    var index: Int
    var approved: Bool
    
   var spot_id: String
    
    
    init?(address: String, town: String, state: String, zipCode: String,spotImage: String, description: String, monStartTime: String, monEndTime: String, tueStartTime: String, tueEndTime: String, wedStartTime: String, wedEndTime: String, thuStartTime: String, thuEndTime: String, friStartTime: String, friEndTime: String, satStartTime: String, satEndTime: String, sunStartTime: String, sunEndTime: String, monOn: Bool, tueOn: Bool, wedOn: Bool, thuOn: Bool, friOn: Bool, satOn: Bool, sunOn: Bool, hourlyPricing: String, dailyPricing: String, weeklyPricing: String, monthlyPricing: String, weeklyOn: Bool, monthlyOn: Bool, index: Int, approved: Bool,spotImages:UIImage,spots_id:String) {
        
        self.address = address
        self.town = town
        self.state = state
        self.zipCode = zipCode
        
        self.spotImage = spotImage
        spotImage1 = spotImages
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
        
        self.index = index
        self.approved = approved
        spot_id = spots_id
    }
    
   
    
  
  func getSpots() {
     var refArtists: DatabaseReference!
    
    refArtists = Database.database().reference().child("User").child(AppState.sharedInstance.userid).child("MySpots");
    refArtists.observe(DataEventType.value, with: { (snapshot) in
        
        if snapshot.childrenCount > 0 {
            AppState.sharedInstance.spots.removeAll()
            for artists in snapshot.children.allObjects as! [DataSnapshot] {
                let snapshotValue = ((snapshot.value as! NSDictionary).value(forKey: (artists as! DataSnapshot).key)) as! NSDictionary
                
                AppState.sharedInstance.spots.append(Spot(address: snapshotValue.value(forKey: "address") as!
                    String, town: snapshotValue.value(forKey: "city") as! String,
                            state: snapshotValue.value(forKey: "state") as! String,
                            zipCode:(snapshotValue.value(forKey: "zipcode") as? String)!,
                            
                            spotImage: snapshotValue.value(forKey: "image") as! String,
                            description: snapshotValue.value(forKey: "description") as! String,
                            
                            monStartTime: snapshotValue.value(forKey: "monStartTime") as! String,
                            monEndTime: snapshotValue.value(forKey: "monEndTime") as! String,
                            tueStartTime:(snapshotValue.value(forKey: "tueStartTime") as? String)!,
                            tueEndTime: snapshotValue.value(forKey: "tueEndTime") as! String,
                            wedStartTime: snapshotValue.value(forKey: "wedStartTime") as! String,
                            wedEndTime: snapshotValue.value(forKey: "wedEndTime") as! String,
                            thuStartTime: snapshotValue.value(forKey: "thuStartTime") as! String,
                            thuEndTime: snapshotValue.value(forKey: "tueEndTime") as! String,
                            friStartTime: snapshotValue.value(forKey: "friStartTime") as! String,
                            friEndTime: snapshotValue.value(forKey: "friEndTime") as! String,
                            satStartTime: snapshotValue.value(forKey: "satStartTime") as! String,
                            satEndTime: snapshotValue.value(forKey: "satEndTime") as! String,
                            sunStartTime: snapshotValue.value(forKey: "sunStartTime") as! String,
                            sunEndTime: snapshotValue.value(forKey: "sunEndTime") as! String,
                            
                            monOn: snapshotValue.value(forKey: "monswitch") as! Bool,
                            tueOn:snapshotValue.value(forKey: "tueswitch") as! Bool,
                            wedOn: snapshotValue.value(forKey: "wedswitch") as! Bool,
                            thuOn: snapshotValue.value(forKey: "thuswitch") as! Bool,
                            friOn: snapshotValue.value(forKey: "friswitch") as! Bool,
                            satOn: snapshotValue.value(forKey: "satswitch") as! Bool,
                            sunOn: snapshotValue.value(forKey: "sunswitch") as! Bool,
                            
                            hourlyPricing: snapshotValue.value(forKey: "hourlyPricing") as! String,
                            dailyPricing: snapshotValue.value(forKey: "dailyPricing") as! String,
                            weeklyPricing: snapshotValue.value(forKey: "weeklyPricing") as! String,
                            monthlyPricing: snapshotValue.value(forKey: "monthlyPricing") as! String,
                            
                            weeklyOn: snapshotValue.value(forKey: "switch_weekly") as! Bool,
                            monthlyOn: snapshotValue.value(forKey: "switch_monthly") as! Bool,
                            index: -1,
                            approved:false, spotImages: UIImage.init(named: "white")!, spots_id: (artists as! DataSnapshot).key)!)
                
            }
           
        }
        
    })
    
    
    }
  
    
  
 
  
    

   
   
    /*
    
    init() {
        
        self.address = ""
        self.town = ""
        self.state = ""
        self.zipCode = ""

     // self.spotImage = UIImage.init(named: "emptySpot")!
        self.spotImage = ""
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
        
        self.index = -1
        self.approved = false
    }
    */
    
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

