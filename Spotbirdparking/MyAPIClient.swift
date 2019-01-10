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
    
    func createCustomerKey(withAPIVersion apiVersion: String, completion: @escaping STPJSONResponseCompletionBlock) {
        print("run createCustomerKey()")        
        print("API Version: \(apiVersion)")
        
        AppState.sharedInstance.user.setaccountToken(accountToken: "12345678")
        AppState.sharedInstance.user.setcustomerToken(customerToken: "1234")
        print("Account Token?")
        AppState.sharedInstance.user.getaccountToken{ (A_token) in
            print("Account Token: \(A_token)")
        }
        print("End account token")
        print("Customer Token?")
        AppState.sharedInstance.user.getcustomerToken{ (C_token) in
            print("Customer Token: \(C_token)")
        }
        print("End customer token")
        
        //get customer ID

        let customerID = "cus_EJ7d4agT0aeHwi"
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
}
