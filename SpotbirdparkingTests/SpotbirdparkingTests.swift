//
//  SpotbirdparkingTests.swift
//  SpotbirdparkingTests
//
//  Created by user138340 on 4/17/18.
//  Copyright © 2018 Spotbird. All rights reserved.
//

import XCTest
import Firebase
import Alamofire
import GoogleMaps
import GooglePlaces
@testable import Spotbirdparking

class SpotbirdparkingTests: XCTestCase {
    
    var ref: DatabaseReference!
    var numDefault:Int!
    
    override func setUp() {
        super.setUp()
        
        //FirebaseApp.configure()
    }
    
    func testDefaultCars() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results
        
        self.ref = Database.database().reference()
        
        print("hello1")
        
        let expectation = self.expectation(description: "Downloading data from Firebase")
        self.numDefault = 0
        
        self.ref.child("User").child("-LbQoDVfuiRm7NBsWOR9").child("Cars").observeSingleEvent(of: .value, with: { (snapshot) in
            
            let value = snapshot.value as? NSDictionary
            for eachCar in value! {
                let car = eachCar.value as! NSDictionary
                if car["default"] as! Int == 1 {
                    self.numDefault += 1
                }
            }
            print(self.numDefault)
            
            //XCTAssert(self.numDefault == 1)
            
            expectation.fulfill()
            
            XCTAssert(self.numDefault == 1)

        }) { (error) in
            print(error.localizedDescription)
        }
        
        waitForExpectations(timeout: 10, handler: nil)
        print("hello2")
        //XCTAssert(self.numDefault == 1)
        

    }
    
    func test_stripe_backend() {
        let url = "https://spotbird-backend-bloughran618.herokuapp.com/test_stripe_backend"
        
        Alamofire.request(url, method: .post)
            .validate(statusCode: 200..<300)
            .responseJSON { response in
                switch response.result {
                case .success:
                    print("Returned with success")
                    let test = "success"
                    XCTAssert(test == "success")
                case .failure(let error):
                    let status = response.response?.statusCode
                    print("Failed, status: \(status)")
                    print("Here is the error: \(error)")
                    let test = "failure"
                    XCTAssert(test == "success")
                }
        }
    }
    
    func test_google_place() {
        try GMSServices.provideAPIKey("AIzaSyCvFxAOvA246L6Syk7Cl426254C-sMJGxk")
        try GMSPlacesClient.provideAPIKey("AIzaSyCvFxAOvA246L6Syk7Cl426254C-sMJGxk")
    }
    
}
