//
//  AppDelegate.swift
//  Spothawk
//
//  Created by user138340 on 4/17/18.
//  Copyright © 2020 Spothawk. All rights reserved.
//

import UIKit
//import GoogleSignIn
import Stripe
import Alamofire
import Firebase
import GoogleMaps
import GooglePlaces
import IQKeyboardManagerSwift

@UIApplicationMain
 class AppDelegate: UIResponder, UIApplicationDelegate
{
    
    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        var keys = NSDictionary()
        if let path = Bundle.main.path(forResource: "config", ofType: "plist") {
            keys = NSDictionary(contentsOfFile: path) ?? NSDictionary()
        }
        
        //keybord manager
        IQKeyboardManager.sharedManager().enable = true
        IQKeyboardManager.sharedManager().enableAutoToolbar = true
        IQKeyboardManager.sharedManager().shouldShowToolbarPlaceholder = true

        GMSServices.provideAPIKey(keys["GMSServices"] as! String)
        GMSPlacesClient.provideAPIKey(keys["GMSPlacesClient"] as! String)
        
        FirebaseApp.configure()
        Auth.auth().signInAnonymously() { (authResult, error) in
            guard let user = authResult?.user else { return }
            let isAnonymous = user.isAnonymous  // true
            let uid = user.uid
        }
        
        // Set up Stripe keys
        STPPaymentConfiguration.shared().publishableKey = keys["StripeKey"] as! String
        // See https://stripe.com/docs/mobile/ios for instructions on how to set up Apple Pay
        
        //   MyAPIClient.sharedClient.baseURLString = "https://stripe-example-backend619.herokuapp.com/"
        
        let config = STPPaymentConfiguration.shared()
        config.companyName = "Spothawk"
        
        // Assign color values to tab bar.
        //  UITabBar.
        //  UITabBar.appearance().tintColor = UIColor.white
        
        print("User Defaults = \(UserDefaults.standard.value(forKey: "logindata") as? NSDictionary)")
        
        if UserDefaults.standard.value(forKey: "logindata") as? NSDictionary != nil {
            let dict = UserDefaults.standard.value(forKey: "logindata") as? NSDictionary
            
            print("User data on login: \(dict)")
          
            AppState.sharedInstance.userid = dict?.value(forKey: "id") as! String
            print( AppState.sharedInstance.userid)
            AppState.sharedInstance.user.firstName = (dict?.value(forKey: "fname") as? String)!
            AppState.sharedInstance.user.lastName = (dict?.value(forKey: "lname") as? String)!
            if  dict?.value(forKey: "image") != nil{
                AppState.sharedInstance.user.profileImage = (dict?.value(forKey: "image") as? String)!
            }
            
            if  dict?.value(forKey: "customerToken") != nil{
            AppState.sharedInstance.user.customertoken = (dict?.value(forKey: "customerToken") as? String)!
            }
            
            if  dict?.value(forKey: "accountToken") != nil{
             AppState.sharedInstance.user.accounttoken = (dict?.value(forKey: "accountToken") as? String)!
            }
            
            if AppState.sharedInstance.user.profileImage != "" {
                let strurl = AppState.sharedInstance.user.profileImage
                let startIndex = strurl.index(strurl.startIndex, offsetBy: 81)
                let endIndex = strurl.index(strurl.startIndex, offsetBy: 85)
                AppState.sharedInstance.user.imgname =  String(strurl[startIndex...endIndex])
            }
            
            let appDelegate = UIApplication.shared.delegate! as! AppDelegate
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let initialViewController = storyboard.instantiateViewController(withIdentifier: "myTabbarControllerID")
            initialViewController.modalPresentationStyle = .fullScreen
            appDelegate.window?.rootViewController = initialViewController
            appDelegate.window?.makeKeyAndVisible()
            
            MyAPIClient.sharedClient.checkStripeAccount()
        }
        else
        {
            let appDelegate = UIApplication.shared.delegate! as! AppDelegate
            self.window = UIWindow(frame: UIScreen.main.bounds)
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let initialViewController = storyboard.instantiateViewController(withIdentifier: "Login_ViewController")
            initialViewController.modalPresentationStyle = .fullScreen
            self.window?.rootViewController = initialViewController
            self.window?.makeKeyAndVisible()
        }
        
        print("There is no account status, we are just logging in...")
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
       
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
 
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
       
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
      
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        
    }
}

