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
import SystemConfiguration
import SystemConfiguration


class AppState {
    static let sharedInstance = AppState()
    
    
    var dict_spot: NSMutableDictionary = [:]
    var user: User
    var spots: [Spot]
    var activeSpot: Spot
    var reservations: [Reservation]
    var userid = ""
   
    static let appStateRoot = Database.database().reference() // can change root
    let storageRef = Storage.storage().reference()
    
    init?(user: User, spots: [Spot], activeSpot: Spot, reservations: [Reservation]) {
        self.user = user
        self.spots = spots
        self.activeSpot = activeSpot
        self.reservations = reservations
    }
    
    init() {
        self.user = User()
        self.spots = []
        self.activeSpot = Spot(address: " ", town: "", state: "", zipCode: " ", spotImage: " ", description: " ", monStartTime: "12:00 AM", monEndTime: "12:00 PM", tueStartTime: "12:00 AM", tueEndTime: "12:00 PM", wedStartTime: "12:00 AM", wedEndTime: "12:00 PM", thuStartTime: "12:00 AM", thuEndTime: "12:00 PM", friStartTime: "12:00 AM", friEndTime: "12:00 PM", satStartTime: "12:00 AM", satEndTime: "12:00 PM", sunStartTime: "12:00 AM", sunEndTime: "12:00 PM", monOn: true, tueOn: true, wedOn: true, thuOn: true, friOn: true, satOn: true, sunOn: true, hourlyPricing: " ", dailyPricing: " ", weeklyPricing: " ", monthlyPricing: "", weeklyOn: true, monthlyOn: true, index: -1, approved: false, spotImages: UIImage.init(named: "emptySpot")!, spots_id: "", latitude:10.0, longitude: 20.0)!
        self.reservations = []
    }
    
    func addActiveSpot() {
        if self.activeSpot.index == -1 { // indicates that we are in add mode
            self.spots.append(activeSpot)
        }
        else { // indicates we are in edit mode
            self.spots[self.activeSpot.index] = self.activeSpot
        }
        self.activeSpot = Spot(address: " ", town: "", state: "", zipCode: " ", spotImage: " ", description: " ", monStartTime: "12:00 AM", monEndTime: "12:00 PM", tueStartTime: "12:00 AM", tueEndTime: "12:00 PM", wedStartTime: "12:00 AM", wedEndTime: "12:00 PM", thuStartTime: "12:00 AM", thuEndTime: "12:00 PM", friStartTime: "12:00 AM", friEndTime: "12:00 PM", satStartTime: "12:00 AM", satEndTime: "12:00 PM", sunStartTime: "12:00 AM", sunEndTime: "12:00 PM", monOn: true, tueOn: true, wedOn: true, thuOn: true, friOn: true, satOn: true, sunOn: true, hourlyPricing: " ", dailyPricing: " ", weeklyPricing: " ", monthlyPricing: "", weeklyOn: true, monthlyOn: true, index: -1, approved: false, spotImages: UIImage.init(named: "emptySpot")!, spots_id: "",latitude:22.7533, longitude:75.8937)!
        
        
    }
}

public class Loader:UIViewController {
    
    
    func showHud(message: String) {
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud?.labelText = message
        hud?.isUserInteractionEnabled = false
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
    open static var baseColor = UIColor.red
    
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



