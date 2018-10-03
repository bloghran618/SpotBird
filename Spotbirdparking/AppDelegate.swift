//
//  AppDelegate.swift
//  Spotbirdparking
//
//  Created by user138340 on 4/17/18.
//  Copyright © 2018 Spotbird. All rights reserved.
//

import UIKit
import Stripe
import Alamofire
import Firebase


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
    
        
        
        
        FirebaseApp.configure()
    
        // Set up Stripe keys
        STPPaymentConfiguration.shared().publishableKey = "pk_test_TV3DNqRM8DCQJEcvMGpayRRj"
        // See https://stripe.com/docs/mobile/ios for instructions on how to set up Apple Pay
        
//        MyAPIClient.sharedClient.baseURLString = "https://stripe-example-backend619.herokuapp.com/"
        
        let config = STPPaymentConfiguration.shared()
        config.companyName = "Spotbird Parking"
        
        // Assign color values to tab bar.
//        UITabBar.
//        UITabBar.appearance().tintColor = UIColor.white
        
        print(UserDefaults.standard.value(forKey: "logindata"))
        
        if UserDefaults.standard.value(forKey: "logindata") as? NSDictionary != nil{
        let dict = UserDefaults.standard.value(forKey: "logindata") as? NSDictionary
            AppState.sharedInstance.userid = dict?.value(forKey: "id") as! String
       print( AppState.sharedInstance.userid)
            let appDelegate = UIApplication.shared.delegate! as! AppDelegate
              let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let initialViewController = storyboard.instantiateViewController(withIdentifier: "myTabbarControllerID")
            appDelegate.window?.rootViewController = initialViewController
            appDelegate.window?.makeKeyAndVisible()
        }
        else
        {
            self.window = UIWindow(frame: UIScreen.main.bounds)
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let initialViewController = storyboard.instantiateViewController(withIdentifier: "Login_ViewController")
            self.window?.rootViewController = initialViewController
            self.window?.makeKeyAndVisible()
        }
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

