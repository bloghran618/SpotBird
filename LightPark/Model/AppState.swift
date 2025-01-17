//
//  appState.swift
//  LightPark
//
//  Created by Brian Loughran on 8/27/18.
//  Copyright © 2020 LightPark. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import SystemConfiguration
import SystemConfiguration


class AppState {
    static let sharedInstance = AppState()
    
    
    var dict_spot: NSMutableDictionary = [:]
    var user: User
    var spots: [Spot]
    var activeSpot: Spot
    //var reservations: [Reservation]
    var userid = ""
    var change = ""
    var stripeStatus = true
    var stripeNeeds = [String]()
       
    let appStateRoot = Database.database().reference() // can change root
    let storageRef = Storage.storage().reference()
    
    init?(user: User, spots: [Spot], activeSpot: Spot, reservations: [Reservation]) {
        self.user = user
        self.spots = spots
        self.activeSpot = activeSpot
//        self.reservations = reservations
    }
    
    init() {
        self.user = User()
        self.spots = []
        //self.reservations = []

        self.activeSpot = Spot(address: " ", town: "", state: "", zipCode: " ", spotImage: " ", description: " ", monStartTime: "12:00 AM", monEndTime: "11:59 PM", tueStartTime: "12:00 AM", tueEndTime: "11:59 PM", wedStartTime: "12:00 AM", wedEndTime: "11:59 PM", thuStartTime: "12:00 AM", thuEndTime: "11:59 PM", friStartTime: "12:00 AM", friEndTime: "11:59 PM", satStartTime: "12:00 AM", satEndTime: "11:59 PM", sunStartTime: "12:00 AM", sunEndTime: "11:59 PM", monOn: true, tueOn: true, wedOn: true, thuOn: true, friOn: true, satOn: true, sunOn: true, hourlyPricing: "1.00", dailyPricing: " ", weeklyPricing: " ", monthlyPricing: "", weeklyOn: true, monthlyOn: true, index: -1, approved: false, spotImages: UIImage.init(named: "emptySpot")!, spots_id: "",latitude:"0", longitude:"0", spottype: "", owner_id: "", Email: "", baseprice: "")!
    }
    
    func addActiveSpot() {
        if self.activeSpot.index == -1 { // indicates that we are in add mode
            self.spots.append(activeSpot)
        }
        else { // indicates we are in edit mode
            self.spots[self.activeSpot.index] = self.activeSpot
        }
        self.activeSpot = Spot(address: " ", town: "", state: "", zipCode: " ", spotImage: " ", description: " ", monStartTime: "12:00 AM", monEndTime: "11:59 PM", tueStartTime: "12:00 AM", tueEndTime: "11:59 PM", wedStartTime: "12:00 AM", wedEndTime: "11:59 PM", thuStartTime: "12:00 AM", thuEndTime: "11:59 PM", friStartTime: "12:00 AM", friEndTime: "11:59 PM", satStartTime: "12:00 AM", satEndTime: "11:59 PM", sunStartTime: "12:00 AM", sunEndTime: "11:59 PM", monOn: true, tueOn: true, wedOn: true, thuOn: true, friOn: true, satOn: true, sunOn: true, hourlyPricing: " ", dailyPricing: " ", weeklyPricing: " ", monthlyPricing: "", weeklyOn: true, monthlyOn: true, index: -1, approved: false, spotImages: UIImage.init(named: "emptySpot")!, spots_id: "",latitude:"0", longitude:"0", spottype: "", owner_id: "",Email: activeSpot.Email, baseprice: "")!
    }
}

public class Loader:UIViewController {
    
    
    func showHud(message: String) {
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.label.text = message
        hud.isUserInteractionEnabled = false
    }
    
    func hideHUD() {
        MBProgressHUD.hide(for: self.view, animated: true)
    }
  
}

// LOADING CLASS
open class Spinner {
    
    internal static var spinner: UIActivityIndicatorView?
    open static var style: UIActivityIndicatorViewStyle = .whiteLarge
    //open static var baseBackColor = UIColor.black.withAlphaComponent(0.5)
    open static var baseBackColor = UIColor.black.withAlphaComponent(0.2)
    open static var baseColor = UIColor.black
    
    open static func start(style: UIActivityIndicatorViewStyle = style, backColor: UIColor = baseBackColor, baseColor: UIColor = baseColor) {
        NotificationCenter.default.addObserver(self, selector: #selector(update), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        if spinner == nil, let window = UIApplication.shared.keyWindow {
            let frame = UIScreen.main.bounds
            spinner = UIActivityIndicatorView(frame: frame)
            spinner!.backgroundColor = backColor
            spinner!.activityIndicatorViewStyle = style
            spinner?.color = baseColor
            window.addSubview(spinner!)
            spinner!.startAnimating()
        }
    }
    
    open static func stop() {
        if spinner != nil {
            spinner!.stopAnimating()
            spinner!.removeFromSuperview()
            spinner = nil
        }
    }
    
    @objc open static func update() {
        if spinner != nil {
            stop()
            start()
        }
    }
    
}



