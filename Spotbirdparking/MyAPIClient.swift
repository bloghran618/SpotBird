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
//    var baseURLString: String? = "https://stripe-example-backend619.herokuapp.com/"
    
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
        var params: [String: Any] = [
            "source": result.source.stripeID,
            "amount": amount,
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
//        let customerID = AppState.sharedInstance.user.customertoken
        let customerID = "cus_ELvzL3KA1gpi9U"
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
    func createCustomerID() {
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
    }
    
    // Create a new account ID in Stripe
    // run with createAccountID()
    func createAccountID() {
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
    }
}
