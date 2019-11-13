//
//  ProfileOptionsViewController.swift
//  Spotbirdparking
//
//  Created by user138340 on 11/11/19.
//  Copyright © 2019 Spotbird. All rights reserved.
//

import UIKit
import Stripe
import MBProgressHUD
import Firebase

class ProfileOptionsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, STPPaymentContextDelegate {
    
    
    @IBOutlet weak var profileTableView: UITableView!
    
    var profileOptions: [ProfileTableOption]?
    let cellIdentifier = "profileTableCell"
    
    let config = STPPaymentConfiguration.shared()
    let customerContext = STPCustomerContext(keyProvider: MyAPIClient.sharedClient)
    
    let paymentContext = STPPaymentContext(customerContext: STPCustomerContext(keyProvider: MyAPIClient.sharedClient))
    
    let stripePublishableKey = "pk_test_TV3DNqRM8DCQJEcvMGpayRRj"
    
    required init?(coder aDecoder: NSCoder) {
        print("Entered required init")
        super.init(coder: aDecoder)
        setPaymentContext(price: 5000)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("loading...")
        
        self.profileTableView.delegate = self
        self.profileTableView.dataSource = self
        
        MyAPIClient.sharedClient.checkStripeAccount()
        
        // populate the options with data
        profileOptions = [
            ProfileTableOption(option: "You", description: "Tell us about yourself", logoImageName: "youImage"),
            ProfileTableOption(option: "Cars", description: "Create and set default cars", logoImageName: "EmptyCar"),
            ProfileTableOption(option: "Payment", description: "Manage your payment options", logoImageName: "dollarSign"),
            ProfileTableOption(option: "List", description: "Share your spot", logoImageName: "Share"),
            ProfileTableOption(option: "Enable Payouts", description: "Authorize payment for your listed spots", logoImageName: "EnablePayouts"),
            ProfileTableOption(option: "Contact Us", description: "Send us an Email", logoImageName: "contactUs"),
            //            ProfileTableOption(option: "Log Out", description: "Log out of your account", logoImageName: "white")
            //            ProfileTableOption(option: "Test Functionality", description: "Just for testing", logoImageName: "white")
        ]
        
        // check if the user has listed spots AND a restricted stripe account
        print("Stripe Status: \(AppState.sharedInstance.stripeStatus)")
        if(AppState.sharedInstance.spots.count > 0 && AppState.sharedInstance.stripeStatus == false) {
            
            // set the alert message to appropriate message
            var message = ""
            if(AppState.sharedInstance.stripeNeeds.contains("business_type")) {
                message = "You must enable payouts to recieve funds for listed spots. Please visit the Enable Payouts tab."
            }
            else {
                message = "We are having trouble verifying your identity. Please visit Enable Payouts to provide additional verification"
            }
            
            // alert the user to Enable Payouts
            let alert = UIAlertController(title: "Payouts Disabled",
                                          message: message,
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (UIAlertAction) in
                self.hideHUD()
            }))
            self.present(alert, animated: true)
        }else{
            self.hideHUD()
        }

    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return profileOptions?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        guard let profileOptions = profileOptions else { return cell }

        cell.textLabel?.text = profileOptions[(indexPath as NSIndexPath).row].option
        cell.detailTextLabel?.text = profileOptions[(indexPath as NSIndexPath).row].description

        if let imageName = profileOptions[(indexPath as NSIndexPath).row].logoImageName {
                    cell.imageView?.image = UIImage(named: imageName)
        }
        
        return cell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("index path: \(indexPath)")
        
        // perform segue based on what cell is clicked
        if profileOptions![(indexPath as NSIndexPath).row].option == "You" {
            self.performSegue(withIdentifier: "You", sender: self)
        }
        else if profileOptions![(indexPath as NSIndexPath).row].option == "Cars" {
            self.performSegue(withIdentifier: "Cars", sender: self)
        }
        else if profileOptions![(indexPath as NSIndexPath).row].option == "Payment" {
            print(self.paymentContext.hostViewController)
            self.paymentContext.pushPaymentOptionsViewController()
        }
        else if profileOptions![(indexPath as NSIndexPath).row].option == "List" {
            self.performSegue(withIdentifier: "Share", sender: self)
        }
        else if profileOptions![(indexPath as NSIndexPath).row].option == "Enable Payouts" {
            // present stripe viewController based on what Stripe needs
            print("Stripe Needs: \(AppState.sharedInstance.stripeNeeds)")
            if (AppState.sharedInstance.stripeNeeds.contains("id_number")) {
                self.performSegue(withIdentifier: "SSN", sender: self)
            }
            else if(AppState.sharedInstance.stripeNeeds.contains("individual.verification.document")) {
                self.performSegue(withIdentifier: "IDDocs", sender: self)
            }
            else {
                self.performSegue(withIdentifier: "Payouts", sender: self)
            }
            
        }
        else if profileOptions![(indexPath as NSIndexPath).row].option == "Contact Us" {
            print("Go to email")
            self.performSegue(withIdentifier: "Email", sender: self)
        }
        else if profileOptions![(indexPath as NSIndexPath).row].option == "Log Out" {
            self.logOut()
        }
        else if profileOptions![(indexPath as NSIndexPath).row].option == "Test Functionality" {
            print("Just doing some debugging...")
            
            //            self.setPaymentContext(price: 1000)
            //            print("requesting the payment...")
            //            self.paymentContext.requestPayment()
            
        }
        else {
            print("Not a table option")
        }
    }
    
    func hideHUD() {
        MBProgressHUD.hide(for: self.view, animated: true)
    }
    
    // log out the user
    func logOut() {
        
        let alertController = UIAlertController(title: "Spotbirdparking", message: "Are you sure you want to logout?", preferredStyle: UIAlertControllerStyle.alert)
        let DestructiveAction = UIAlertAction(title: "Yes", style: UIAlertActionStyle.destructive) { (result : UIAlertAction) -> Void in
            UserDefaults.standard.removeObject(forKey: "logindata")
            let appDomain = Bundle.main.bundleIdentifier!
            UserDefaults.standard.removePersistentDomain(forName: appDomain)
            UserDefaults.standard.synchronize()
            AppState.sharedInstance.user.cars.removeAll()
            AppState.sharedInstance.spots.removeAll()
            
            AppState.sharedInstance.userid = ""
            AppState.sharedInstance.user.customertoken = ""
            AppState.sharedInstance.user.accounttoken =  ""
            AppState.sharedInstance.user.firstName = ""
            AppState.sharedInstance.user.lastName = ""
            AppState.sharedInstance.user.profileImage = ""
            let vc = self.storyboard!.instantiateViewController(withIdentifier: "Login_ViewController") as! Login_ViewController
            self.present(vc, animated: true, completion: nil)
        }
        let okAction = UIAlertAction(title: "No", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
        }
        alertController.addAction(DestructiveAction)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    // MARK: STPPaymentContextDelegate
    func paymentContext(_ paymentContext: STPPaymentContext, didCreatePaymentResult paymentResult: STPPaymentResult, completion: @escaping STPPaymentStatusBlock) {
        print("run didcreatepaymentresult")
    }
    
    //    func paymentContext(_ paymentContext: STPPaymentContext, didCreatePaymentResult paymentResult: STPPaymentResult, completion: @escaping STPErrorBlock) {
    //        print("run didCreatePaymentResult paymentContext()")
    //        //MyAPIClient.sharedClient.completeCharge(paymentResult,
    //                                                //amount: self.paymentContext.paymentAmount,
    //                                                //shippingAddress: self.paymentContext.shippingAddress,
    //                                                //shippingMethod: self.paymentContext.selectedShippingMethod
    //                                                //completion: completion)
    //    }
    
    func paymentContext(_ paymentContext: STPPaymentContext, didFinishWith status: STPPaymentStatus, error: Error?) {
        print("run didFinishWith paymentContext()")
        let title: String
        let message: String
        switch status {
        case .error:
            title = "Error"
            message = error?.localizedDescription ?? ""
        case .success:
            title = "Success"
            message = "You bought a SPOT!"
        case .userCancellation:
            return
        }
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(action)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func paymentContextDidChange(_ paymentContext: STPPaymentContext) {
        print("run paymentContextDidChange()")
        
    }
    
    func paymentContext(_ paymentContext: STPPaymentContext, didFailToLoadWithError error: Error) {
        print("run didFailToLoadWithError paymentContext()")
        print("Error: \(error)")
        let alertController = UIAlertController(
            title: "Error",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
            // Need to assign to _ because optional binding loses @discardableResult value
            // https://bugs.swift.org/browse/SR-1681
            _ = self.navigationController?.popViewController(animated: true)
        })
        let retry = UIAlertAction(title: "Retry", style: .default, handler: { action in
            self.paymentContext.retryLoading()
        })
        alertController.addAction(cancel)
        alertController.addAction(retry)
        self.present(alertController, animated: true, completion: nil)
        print("Customer String: \(AppState.sharedInstance.user.customertoken)")
        print("Account String: \(AppState.sharedInstance.user.accounttoken)")
    }
    
    func setPaymentContext(price: Int) {
        let a = self as! UIViewController
        print("a is: \(a)")
        print("Setting the payment context")
        self.paymentContext.delegate = self
        print("no issue with the delegate")
        self.paymentContext.hostViewController = self as! UIViewController
        print("No issue setting the host view controller")
        self.paymentContext.paymentAmount = price
        print(self.paymentContext.paymentAmount)
        print(self.paymentContext.hostViewController)
        print("Finished setting the payment context")
    }
    
}
