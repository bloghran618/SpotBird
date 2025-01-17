//
//  Reservation.swift
//  LightPark
//
//  Created by Brian Loughran on 10/13/18.
//  Copyright © 2020 LightPark. All rights reserved.
//

import Foundation

class Reservation {
    
    var startDateTime: String
    var endDateTime: String
    var parkOrRent: String // will always be "Park" or "Rent"
    var price: String
    var spot: Spot
    var parkerID: String
    var car: Car
    var ownerID: String
    var paymentIntent_id: String
    
    init?(startDateTime: String, endDateTime: String, parkOrRent: String, spot: Spot, parkerID: String, car: Car, ownerID: String, paymentIntent_id: String) {
        self.startDateTime = startDateTime
        self.endDateTime = endDateTime
        
        self.parkOrRent = parkOrRent
        self.spot = spot
        
        let doublePrice = Reservation.calcPrice(startDateTimeString: startDateTime, endDateTimeString: endDateTime, basePrice: spot.basePricing)
        self.price = String(format: "%.2f", doublePrice)
        
        self.parkerID = parkerID
        self.car = car
        self.ownerID = ownerID
        self.paymentIntent_id = paymentIntent_id
    }
    
    // alogrithm to calculate the price of the spot based on the base price and the time duration
    static func calcPrice(startDateTimeString: String, endDateTimeString: String, basePrice: String) -> Double {
        
        let startDateTime = stringToDate(string: startDateTimeString)
        let endDateTime = stringToDate(string: endDateTimeString)
        var price = 0.0
        var basePriceTrimmed = ""
        
        // account the base price
        if basePrice != ""{
            print("Base Price: \(basePrice)")
            print("Base Price: \(Double(basePrice))")
            basePriceTrimmed = basePrice.trimmingCharacters(in: .whitespacesAndNewlines)
            price += Double(basePriceTrimmed)!
        }
        else {
            print("No base price!!!!!!")
        }
        
        // get the number of hours between end and start
        let timeDelta = endDateTime.minutes(from: startDateTime)
        
         if basePrice != ""{
            // add ( # hours * base price * 0.1 ) to the price
            price += Double(timeDelta) * Double(basePriceTrimmed)! * 0.1 / 60
        }
        
        // Price = base + ( base * hours parked * 0.1 )
        return price
    }
    
    // turns a double into a string with two decimals
    static func priceToString(price: Double) -> String {
        let doubleStr = String(format: "%.2f", price)
        return doubleStr
    }
    
    // For use outside of the class
    class func publicCalcPrice(startDateTimeString: String, endDateTimeString: String, basePrice: String) -> Double {
        return Reservation.calcPrice(startDateTimeString: startDateTimeString, endDateTimeString: endDateTimeString, basePrice: basePrice)
    }
    
    // leftover algorithm for calculating the price based on monthly, weekly, daily and hourly prices, in case we decide to go back to this algorithm
    func calcPriceMonthWeekDayHour(startDateTimeString: String, endDateTimeString: String, spot: Spot) -> Double {
            let startDateTime = Reservation.stringToDate(string: startDateTimeString)
            let endDateTime = Reservation.stringToDate(string: endDateTimeString)
        
        var price = 0.0 // price starts at 0
        
//        let dateComponentsFormatter = DateComponentsFormatter()
//        dateComponentsFormatter.allowedUnits = [.year,.month,.weekOfMonth,.day,.hour,.minute]
//        dateComponentsFormatter.maximumUnitCount = 1
//        dateComponentsFormatter.unitsStyle = .full
//
//        let calendar = Calendar.current
//        let startYear = calendar.component(.year, from: startDateTime)
//        let startMonth = calendar.component(.month, from: startDateTime)
//        let startDay = calendar.component(.day, from: startDateTime)
//        let startHour = calendar.component(.hour, from: startDateTime)
//        let startMinute = calendar.component(.minute, from: startDateTime)
//        let endYear = calendar.component(.year, from: endDateTime)
//        let endMonth = calendar.component(.month, from: endDateTime)
//        let endDay = calendar.component(.day, from: endDateTime)
//        let endHour = calendar.component(.hour, from: endDateTime)
//        let endMinute = calendar.component(.minute, from: endDateTime)
//
//        let start = DateComponents(calendar: .current, year: startYear, month: startMonth, day: startDay, hour: startHour, minute: startMinute)
//        let end = DateComponents(calendar: .current, year: endYear, month: endMonth, day: endDay, hour: endHour, minute: endMinute)
        
        //let timeDelta = end.minutes(from: start) // calculate the number of minutes the user is parking
        var timeDelta = endDateTime.minutes(from: startDateTime)
        
        let monthRatio = Double(spot.weeklyPricing)!/Double(spot.monthlyPricing)!
        let weekRatio = Double(spot.dailyPricing)!/Double(spot.weeklyPricing)!
        let dayRatio = Double(spot.hourlyPricing)!/Double(spot.dailyPricing)!
        
        while(timeDelta > 0) {
            if(timeDelta >= Int(43800.0 * monthRatio)) { // number of minutes in a month
                price += Double(spot.monthlyPricing)!
                timeDelta -= 43800
            }
            else if(timeDelta >= Int(10080 * weekRatio)) {  // number of minutes in a week
                price += Double(spot.weeklyPricing)!
                timeDelta -= 10080
            }
            else if(timeDelta >= Int(1440 * dayRatio)) { // number of minutes in a day
                price += Double(spot.dailyPricing)!
                timeDelta -= 1440
            }
            else if(timeDelta >= 60) { // number of minutes in an hour
                price += Double(spot.hourlyPricing)!
                timeDelta -= 60
            }
            else {
                if(price == 0) { // only pro-rate to minutes if the reservation is on the order of minutes
                    if(timeDelta <= 15) { // lowest cost if for 15 minutes of parking
                        price += Double(spot.hourlyPricing)! / 4
                        timeDelta -= 15
                    }
                    else {
                        let fractionHour = Double(timeDelta) / 60.0
                        price += Double(spot.hourlyPricing)! * fractionHour
                        timeDelta = 0
                    }
                }
                timeDelta = 0
            }
        }
        return price
    }
    
    static func dateToString(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"  // this is the format for the date
        let myString = formatter.string(from: date)
        return myString
    }
    
    static func stringToDate(string: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"  // this is the format for the date
        let myDate = formatter.date(from: string)
        return myDate!
    }
    
}

extension Date {
    /// Returns the amount of years from another date
    func years(from date: Date) -> Int {
        return Calendar.current.dateComponents([.year], from: date, to: self).year ?? 0
    }
    /// Returns the amount of months from another date
    func months(from date: Date) -> Int {
        return Calendar.current.dateComponents([.month], from: date, to: self).month ?? 0
    }
    /// Returns the amount of weeks from another date
    func weeks(from date: Date) -> Int {
        return Calendar.current.dateComponents([.weekOfMonth], from: date, to: self).weekOfMonth ?? 0
    }
    /// Returns the amount of days from another date
    func days(from date: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: date, to: self).day ?? 0
    }
    /// Returns the amount of hours from another date
    func hours(from date: Date) -> Int {
        return Calendar.current.dateComponents([.hour], from: date, to: self).hour ?? 0
    }
    /// Returns the amount of minutes from another date
    func minutes(from date: Date) -> Int {
        return Calendar.current.dateComponents([.minute], from: date, to: self).minute ?? 0
    }
    /// Returns the amount of seconds from another date
    func seconds(from date: Date) -> Int {
        return Calendar.current.dateComponents([.second], from: date, to: self).second ?? 0
    }
    /// Returns the amount of nanoseconds from another date
    func nanoseconds(from date: Date) -> Int {
        return Calendar.current.dateComponents([.nanosecond], from: date, to: self).nanosecond ?? 0
    }
    /// Returns the a custom time interval description from another date
    func offset(from date: Date) -> Int {
        if years(from: date)   > 0 { return years(from: date)   }
        if months(from: date)  > 0 { return months(from: date)  }
        if weeks(from: date)   > 0 { return weeks(from: date)   }
        if days(from: date)    > 0 { return days(from: date)    }
        if hours(from: date)   > 0 { return hours(from: date)   }
        if minutes(from: date) > 0 { return minutes(from: date) }
        if seconds(from: date) > 0 { return seconds(from: date) }
        if nanoseconds(from: date) > 0 { return nanoseconds(from: date) }
        return 0
    }
}
