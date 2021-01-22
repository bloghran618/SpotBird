//
//  MyAPIClient.swift
//  LightPark
//
//  Created by Brian Loughran on 7/4/18.
//  Copyright © 2020 LightPark. All rights reserved.
//


import Foundation
import Stripe
import Alamofire
import Firebase

class MyAPIClient: NSObject, STPEphemeralKeyProvider {
    
    static let sharedClient = MyAPIClient()
    
    // Ruby example backend
    var oldURLString: String? = "https://stripe-example-backend619.herokuapp.com/"
    var oldURL: URL {
        if let urlString = self.oldURLString, let url = URL(string: urlString) {
            return url
        } else {
            fatalError()
        }
    }
    
    // Python my backend
    var baseURLString: String? = "https://spotbird-backend-bloughran618.herokuapp.com/"
    
    var baseURL: URL {
        if let urlString = self.baseURLString, let url = URL(string: urlString) {
            return url
        } else {
            fatalError()
        }
    }
    
    func completeCharge(_ result: STPPaymentResult,
                        amount: Int,
                        shippingAddress: STPAddress?,
                        shippingMethod: PKShippingMethod?,
                        reservationInfo: Reservation,
                        completion: @escaping STPErrorBlock) {
        print("Run completeCharge()")
        let url = self.baseURL.appendingPathComponent("charge")
        print("This is the URL we are using: \(url)")
        var params: [String: Any] = [
            "source": result.paymentMethod?.stripeId,
            "amount": amount,
            "customer_token": AppState.sharedInstance.user.customertoken,
        ]
        
        print("params are created")
//        params["shipping"] = STPAddress.shippingInfoForCharge(with: shippingAddress, shippingMethod: shippingMethod)
        
        var paymentIntent_ID = ""
        
        AF.request(url, method: .post, parameters: params)
            .validate(statusCode: 200..<300)
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    let result = value
                    print(result)
                    let intent = result as! NSDictionary
                    paymentIntent_ID = String(describing: "\(intent["paymentIntent_id"]!)")
                    print("ID: " + String(paymentIntent_ID))
                    AppState.sharedInstance.user.temporary_paymentIntent_id = paymentIntent_ID
                    completion(nil)
                case .failure(let error):
                    completion(error)
                }
        }
    }
    
    func createPaymentIntent(context: STPPaymentContext, completion: @escaping ((AFResult<String>) -> Void)) {
        let url = self.baseURL.appendingPathComponent("create_payment_intent")
        print("Here is a url: \(url)")
        let params: [String: Any] = [
            "amount": context.paymentAmount,
            "customer_token": AppState.sharedInstance.user.customertoken,
        ]
        AF.request(url, method: .post, parameters: params)
            .validate(statusCode: 200..<300)
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    print("recieved a value from create_payment_intent backend: \(response)")
                    let intent = value as! NSDictionary
                    print("Intent looks like: \(intent)")
                    
                    let paymentIntent_ID = String(describing: "\(intent["intentID"]!)")
                    print("This is the payment intent ID: \(paymentIntent_ID)")
                    AppState.sharedInstance.user.temporary_paymentIntent_id = paymentIntent_ID
                    
                    let client_secret = String(describing: "\(intent["clientSecret"]!)")
                    print("The client secret is: \(client_secret)")
                    print("returning the client secret")
                    completion(.success(client_secret))
                case .failure(let error):
                    completion(.failure(error))
                }
        }
    }
    
    // Transfer funds from our account to the spot owner
    // run with MyAPIClient.sharedClient.completeTransfer(destination: String, spotAmount: Int)
    func completeTransfer(destination: String, spotAmount: Int, spotID: String, startDateTime: String, completion: @escaping (_ result: String) -> Void)  {
        print("Run completeTransfer()")
        let url = self.baseURL.appendingPathComponent("schedule_transfer")
        print("Spot Amount: \(spotAmount)")
        let payAmount = spotAmount * 17/20
        print("Pay Amount: \(payAmount)")
        let params: [String: Any] = [
            "destination_id": destination,
            "amount": payAmount,
            "spotID": spotID,
            "startDateTime": startDateTime
        ]
        AF.request(url, method: .post, parameters: params)
            .validate(statusCode: 200..<300)
            .responseJSON { response in
                switch response.result {
                case .success:
                    print("Transfer was a success")
                    completion("Success")
                    
                case .failure(let error):
                    let status = response.response?.statusCode
                    print("Transfer failed, status: \(status)")
                    print("Here is the error: \(error)")
                    completion("Failure")
                }
                
        }
        
    }
    
    // Get an ephemeral key from the python backend for the customer object
    func createCustomerKey(withAPIVersion apiVersion: String, completion: @escaping STPJSONResponseCompletionBlock) {
        print("run createCustomerKey()")        
        print("API Version: \(apiVersion)")
        
        let customerID = AppState.sharedInstance.user.customertoken
        print("customerToken: \(customerID)")
        print("Last Name: \(AppState.sharedInstance.user.lastName)")
        let url = self.baseURL.appendingPathComponent("ephemeral_keys")
        print(url)
        
        AF.request(url, method: .post, parameters: [
            "api_version": apiVersion,
            "customer_id": customerID])
            .validate(statusCode: 200..<300)
            .responseJSON { responseJSON in
                switch responseJSON.result {
                case .success(let json):
                    completion(json as? [String: AnyObject], nil)
                case .failure(let error):
                    completion(nil, error)
                }
        }
        print("end createCustomerKey")
    }
    
    // Create a new customer ID in Stripe
    // run with MyAPIClient.sharedClient.createCustomerID()
    func createCustomerID(completionHandler: @escaping (_ message: String) -> ()) {
        print("Create Customer ID!!!")
        let url = self.baseURL.appendingPathComponent("customer_id")
        //        let url = baseURLString.appendingPathComponent("customer_id")
        AF.request(url, method: .post, parameters: nil, encoding: JSONEncoding.default)
            // validate status code from flask
            .validate(statusCode: 200..<300)
            // determine success or failure
            .responseJSON { responseJSON in
                switch responseJSON.result {
                case .success(let value):
                    print("example customer success")
                    let JSON = value as! NSDictionary
                    print("Response: \(JSON)")
                    let customer_id_from_flask = JSON["customer_id"] ?? ""
                    print("Customer ID: \(JSON["customer_id"] ?? "")")
                    // set Customer Token to flask value
                    print("User name: \(AppState.sharedInstance.user.firstName)")
                    AppState.sharedInstance.user.customertoken = customer_id_from_flask as! String
                    print("Appstate set.")
                    completionHandler("Customer ID Success")
                case .failure:
                    let status = responseJSON.response?.statusCode
                    print("customer error with response status: \(status)")
                }
//                //to get JSON return value
//                if let result = responseJSON.result.value {
//                    let JSON = result as! NSDictionary
//                    print("Response: \(JSON)")
//                    let customer_id_from_flask = JSON["customer_id"] ?? ""
//                    print("Customer ID: \(JSON["customer_id"] ?? "")")
//                    // set Customer Token to flask value
//                    print("User name: \(AppState.sharedInstance.user.firstName)")
//                    AppState.sharedInstance.user.customertoken = customer_id_from_flask as! String
//                    print("Appstate set.")
//                    completionHandler("Customer ID Success")
//                }
        }
//        return AppState.sharedInstance.user.customertoken
    }
    
    // Create a new account ID in Stripe
    // run with MyAPIClient.sharedClient.createAccountID()
    func createAccountID(completionHandler: @escaping (_ message: String) -> ()) {
        print("Create Account ID!!!")
        let url = self.baseURL.appendingPathComponent("account_id")
        //        let url = baseURLString.appendingPathComponent("customer_id")
        AF.request(url, method: .post, parameters: nil, encoding: JSONEncoding.default)
            // validate status code from flask
            .validate(statusCode: 200..<300)
            // determine success or failure
            .responseJSON { responseJSON in
                switch responseJSON.result {
                case .success(let value):
                    print("example account success")
                    let JSON = value as! NSDictionary
                    print("Response: \(JSON)")
                    let account_id_from_flask = JSON["account_id"] ?? ""
                    print("Account ID: \(JSON["account_id"] ?? "")")
                    // set Account Token to flask value
                    AppState.sharedInstance.user.accounttoken = account_id_from_flask as! String
                    completionHandler("Account ID Success")
                case .failure:
                    let status = responseJSON.response?.statusCode
                    print("account error with response status: \(status)")
                }
//                //to get JSON return value
//                if let result = responseJSON.result.value {
//                    let JSON = result as! NSDictionary
//                    print("Response: \(JSON)")
//                    let account_id_from_flask = JSON["account_id"] ?? ""
//                    print("Account ID: \(JSON["account_id"] ?? "")")
//                    // set Account Token to flask value
//                    AppState.sharedInstance.user.accounttoken = account_id_from_flask as! String
//                    completionHandler("Account ID Success")
//                }
        }
//        return AppState.sharedInstance.user.accounttoken
    }
    
    // Add tokenized connect account info to the user Stripe account
    // Run with MyAPIClient.sharedClient.addConnectInfoToken(token)
    func addConnectAccountInfoToken(token: STPToken, address: STPAddress) {
        
        // get accountID from user object
        let accountID = AppState.sharedInstance.user.accounttoken
        
        let url = self.baseURL.appendingPathComponent("add_connect_info")
        
        let ip_address = self.getIPAddresses()
        
        // cannot set address line 2 to empty string
        if(address.line2 == "") {
            address.line2 = "None"
        }
        
        let params: [String: Any] = [
            "account_id": accountID,
            "info_token": token,
            "ip_address": ip_address,
            "name": address.name ?? "",
            "line1": address.line1 ?? "",
            "line2": address.line2 ?? "",
            "city": address.city ?? "",
            "state": address.state ?? "",
            "postalcode": address.postalCode ?? ""
        ]
        
        AF.request(url, method: .post, parameters: params)
            .validate(statusCode: 200..<300)
            .responseJSON { responseJSON in
            switch responseJSON.result {
                case .success(let json):
                    print("Successfully added account params token")
                case .failure(let error):
                    print("Failed due to error: \(error.localizedDescription)")
                }
        }
    }
    
    
    // Add tokenized bank account info to the user Stripe account
    // Run with MyAPIClient.sharedClient.addAccountToken(token)
    func addAccountToken(token: STPToken) {
        
        // get accountID from user object
        let accountID = AppState.sharedInstance.user.accounttoken
        
        let url = self.baseURL.appendingPathComponent("add_bank_info")
        
        AF.request(url, method: .post, parameters: [
            "account_id": accountID,
            "account_token": token])
            .validate(statusCode: 200..<300)
            .responseJSON { responseJSON in
                switch responseJSON.result {
                case .success(let json):
                    print("Successfully added bank account token")
                case .failure(let error):
                    print("Failed due to error: \(error.localizedDescription)")
                }
        }
    }
    
    // checks the stripe account to check account standing
    // Call with MyAPIClient.sharedClient.checkStripeAccount()
    func checkStripeAccount() {
        
        // get accountID from user object
        let accountID = AppState.sharedInstance.user.accounttoken
        
        let url = self.baseURL.appendingPathComponent("check_stripe_account")
        
        AF.request(url, method: .post, parameters: [
            "account_id": accountID])
            .validate(statusCode: 200..<300)
            .responseJSON { responseJSON in
                switch responseJSON.result {
                case .success(let value):
                    print("Got stripe account status")
                    
                    let JSON = value as! NSDictionary
                    // Spinner.stop()
                    // get values from jsonify
                    let enabledNSNumber = JSON["enabled"] as! NSNumber
                    let dueList: NSArray = JSON["due"] as! NSArray
                                        
                    // convert json NSNumber to boolean
                    var enabled = true
                    if(enabledNSNumber == 1) {
                        enabled = true
                    }
                    else if(enabledNSNumber == 0) {
                        enabled = false
                    }
                                        
                    // set stripe attributes in singleton
                    AppState.sharedInstance.stripeStatus = enabled
                    AppState.sharedInstance.stripeNeeds = dueList as! [String]
                                        
                    // display some debug values
                    print("Is the account enabled? : \(AppState.sharedInstance.stripeStatus)")
                    print("What is due? : \(AppState.sharedInstance.stripeNeeds)")
                case .failure(let error):
                    print("ERROR: Issue with getting Stripe account status: \(error)")
                }
                //to get JSON return value
//                if let result = responseJSON.result.value {
//                    let JSON = result as! NSDictionary
////                    Spinner.stop()
//                    // get values from jsonify
//                    let enabledNSNumber = JSON["enabled"] as! NSNumber
//                    let dueList: NSArray = JSON["due"] as! NSArray
//                    
//                    // convert json NSNumber to boolean
//                    var enabled = true
//                    if(enabledNSNumber == 1) {
//                        enabled = true
//                    }
//                    else if(enabledNSNumber == 0) {
//                        enabled = false
//                    }
//                    
//                    // set stripe attributes in singleton
//                    AppState.sharedInstance.stripeStatus = enabled
//                    AppState.sharedInstance.stripeNeeds = dueList as! [String]
//                    
//                    // display some debug values
//                    print("Is the account enabled? : \(AppState.sharedInstance.stripeStatus)")
//                    print("What is due? : \(AppState.sharedInstance.stripeNeeds)")
//                }
        }
    }
    
    // pretty self explanatory here...
    func binaryToBool(bin: String) -> Bool{
        print("This is the string: \(bin)")
        if(bin == "1") {
            return true
        }
        return false
    }
    
    
    // get the ip address of the device
    func getIPAddresses() -> String {
        var addresses = [String]()
        
        // Get list of all interfaces on the local machine:
        var ifaddr : UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0 else { return "69.9.37.39" }
        guard let firstAddr = ifaddr else { return "69.9.37.39" }
        
        // For each interface ...
        for ptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
            let flags = Int32(ptr.pointee.ifa_flags)
            let addr = ptr.pointee.ifa_addr.pointee
            
            // Check for running IPv4, IPv6 interfaces. Skip the loopback interface.
            if (flags & (IFF_UP|IFF_RUNNING|IFF_LOOPBACK)) == (IFF_UP|IFF_RUNNING) {
                if addr.sa_family == UInt8(AF_INET) || addr.sa_family == UInt8(AF_INET6) {
                    
                    // Convert interface address to a human readable string:
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    if (getnameinfo(ptr.pointee.ifa_addr, socklen_t(addr.sa_len), &hostname, socklen_t(hostname.count),
                                    nil, socklen_t(0), NI_NUMERICHOST) == 0) {
                        let address = String(cString: hostname)
                        addresses.append(address)
                    }
                }
            }
        }
        
        freeifaddrs(ifaddr)
        var feAddresses = addresses
        
        // clean up fe80 ip's
        for a in addresses {
            if a.hasPrefix("fe80") {
                let index = addresses.index(of: a)
                addresses.remove(at: index!)
            }
        }
        
        if(addresses.count > 0) {
            return addresses[0]
        }
        else if(feAddresses.count > 0) {
            return feAddresses[0]
        }
        return "69.9.37.39"
    }
}
