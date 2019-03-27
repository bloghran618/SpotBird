//
//  MyAPIClient.swift
//  Spotbirdparking
//
//  Created by user138340 on 7/4/18.
//  Copyright © 2018 Spotbird. All rights reserved.
//

import Foundation
import Stripe
import Alamofire

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
                        completion: @escaping STPErrorBlock) {
        print("Run completeCharge()")
        let url = self.baseURL.appendingPathComponent("charge")
        print("This is the URL we are using: \(url)")
        var params: [String: Any] = [
            "source": result.source.stripeID,
            "amount": amount,
            "customer_token": AppState.sharedInstance.user.customertoken
        ]
        params["shipping"] = STPAddress.shippingInfoForCharge(with: shippingAddress, shippingMethod: shippingMethod)
        Alamofire.request(url, method: .post, parameters: params)
            .validate(statusCode: 200..<300)
            .responseString { response in
                switch response.result {
                case .success:
                    completion(nil)
                case .failure(let error):
                    completion(error)
                }
        }
    }
    
    // Transfer funds from our account to the spot owner
    // run with MyAPIClient.sharedClient.completeTransfer(destination: String, spotAmount: Int)
    func completeTransfer(destination: String, spotAmount: Int) {
        print("Run completeTransfer()")
        let url = self.baseURL.appendingPathComponent("pay_owner")
        print("Spot Amount: \(spotAmount)")
        let payAmount = spotAmount * 17/20
        print("Pay Amount: \(payAmount)")
        var params: [String: Any] = [
            "destination_id": destination,
            "amount": payAmount
        ]
        Alamofire.request(url, method: .post, parameters: params)
            .validate(statusCode: 200..<300)
            .responseJSON { response in
                switch response.result {
                case .success:
                    print("Transfer was a success")
                case .failure(let error):
                    let status = response.response?.statusCode
                    print("Transfer failed, status: \(status)")
                    print("Here is the error: \(error)")
                }
        }
        
    }
    
    // will probably be deleted eventually
    // Purchase a spot with
//    func spotPurchase(sourceID: String, destinationID: String, amount: Int, completion: @escaping STPJSONResponseCompletionBlock) {
//        let url = self.baseURL.appendingPathComponent("spot_purchase")
//
//        Alamofire.request(url, method: .post, parameters: [
//            "source_id": sourceID,
//            "destination_id": destinationID,
//            "amount": amount])
//            .validate(statusCode: 200..<300)
//            .responseJSON { responseJSON in
//                switch responseJSON.result {
//                case .success(let json):
//                    completion(json as? [String: AnyObject], nil)
//                case .failure(let error):
//                    completion(nil, error)
//                }
//        }
//
//    }
    
    // Get an ephemeral key from the python backend for the customer object
    func createCustomerKey(withAPIVersion apiVersion: String, completion: @escaping STPJSONResponseCompletionBlock) {
        print("run createCustomerKey()")        
        print("API Version: \(apiVersion)")
        
//        AppState.sharedInstance.user.setaccountToken(accountToken: "12345678")
//        AppState.sharedInstance.user.setcustomerToken(customerToken: "1234")
//        print("Account Token?")
//        AppState.sharedInstance.user.getaccountToken{ (A_token) in
//            print("Account Token here: \(A_token)")
//        }
//        print("End account token")
//        print("Customer Token?")
//        AppState.sharedInstance.user.getcustomerToken{ (C_token) in
//            print("Customer Token here: \(C_token)")
//        }
//        print("End customer token")
        
        // Change to db customer ID once we get that working
        let customerID = AppState.sharedInstance.user.customertoken
        print("CustomerToken: \(customerID)")
        print("Last Name: \(AppState.sharedInstance.user.lastName)")
//        let customerID = "cus_ELvzL3KA1gpi9U"
        let url = self.baseURL.appendingPathComponent("ephemeral_keys")
        print(url)
        
        Alamofire.request(url, method: .post, parameters: [
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
    func createCustomerID() -> String {
        print("Create Customer ID!!!")
        let url = self.baseURL.appendingPathComponent("customer_id")
        //        let url = baseURLString.appendingPathComponent("customer_id")
        Alamofire.request(url, method: .post, parameters: nil, encoding: JSONEncoding.default)
            // validate status code from flask
            .validate(statusCode: 200..<300)
            // determine success or failure
            .responseJSON { responseJSON in
                switch responseJSON.result {
                case .success:
                    print("example customer success")
                case .failure:
                    let status = responseJSON.response?.statusCode
                    print("customer error with response status: \(status)")
                }
                //to get JSON return value
                if let result = responseJSON.result.value {
                    let JSON = result as! NSDictionary
                    print("Response: \(JSON)")
                    let customer_id_from_flask = JSON["customer_id"] ?? ""
                    print("Customer ID: \(JSON["customer_id"] ?? "")")
                    // set Customer Token to flask value
                    AppState.sharedInstance.user.setcustomerToken(customerToken: customer_id_from_flask as! String)
                }
        }
        return AppState.sharedInstance.user.customertoken
    }
    
    // Create a new account ID in Stripe
    // run with MyAPIClient.sharedClient.createAccountID()
    func createAccountID() -> String {
        print("Create Account ID!!!")
        let url = self.baseURL.appendingPathComponent("account_id")
        //        let url = baseURLString.appendingPathComponent("customer_id")
        Alamofire.request(url, method: .post, parameters: nil, encoding: JSONEncoding.default)
            // validate status code from flask
            .validate(statusCode: 200..<300)
            // determine success or failure
            .responseJSON { responseJSON in
                switch responseJSON.result {
                case .success:
                    print("example account success")
                case .failure:
                    let status = responseJSON.response?.statusCode
                    print("account error with response status: \(status)")
                }
                //to get JSON return value
                if let result = responseJSON.result.value {
                    let JSON = result as! NSDictionary
                    print("Response: \(JSON)")
                    let account_id_from_flask = JSON["account_id"] ?? ""
                    print("Account ID: \(JSON["account_id"] ?? "")")
                    // set Customer Token to flask value
                    AppState.sharedInstance.user.setaccountToken(accountToken: account_id_from_flask as! String)
                }
        }
        return AppState.sharedInstance.user.accounttoken
    }
    
    // Add tokenized connect account info to the user Stripe account
    // Run with MyAPIClient.sharedClient.addConnectInfoToken(token)
    func addConnectAccountInfoToken(token: STPToken) {
        
        // get accountID from user object
        let accountID = "acct_1DvaPmDZCtueSval"
        
        let url = self.baseURL.appendingPathComponent("add_connect_info")
        
        Alamofire.request(url, method: .post, parameters: [
            "account_id": accountID,
            "info_token": token])
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
        let accountID = "acct_1DvaPmDZCtueSval"
        
        let url = self.baseURL.appendingPathComponent("add_bank_info")
        
        Alamofire.request(url, method: .post, parameters: [
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
}
