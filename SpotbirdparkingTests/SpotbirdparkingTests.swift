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
import GooglePlaces
import GooglePlacePicker
import GoogleMaps
import CoreLocation
@testable import Spotbirdparking

class SpotbirdparkingTests: XCTestCase {
    
    var ref: DatabaseReference!
    var numDefault:Int!
    
    override func setUp() {
        super.setUp()

    }
    
    func testDefaultCars() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results
        
        self.ref = Database.database().reference()
        
        self.ref.child("test").setValue(["test": "test"])
        
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
    
    func test_heroku_backend() {
        let url = "https://spotbird-backend-bloughran618.herokuapp.com/test_heroku_backend"
        
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
    
    func test_stripe() {
        let url = "https://spotbird-backend-bloughran618.herokuapp.com/test_stripe"
        
        let params: [String: Any] = ["account_id": AppState.sharedInstance.user.accounttoken]
        
        let expectation = self.expectation(description: "Testing stripe returning value")
        
        let totalBalance = ""
        print("right before function")
        let task = Alamofire.request(url, method: .post, parameters: params).validate().responseJSON { response in
            switch response.result {
            case .success:
                print("Returned with success")
            case .failure(let error):
                let status = response.response?.statusCode
                print("Failed, status: \(status)")
                print("Here is the error: \(error)")
            }
                
            if let result = response.result.value {
                let balance = result as! NSDictionary
                let totalBalance = String(describing: "\(balance["Balance"]!)")
            }
            print("hello")
            XCTAssert(totalBalance != "")
            expectation.fulfill()
        }
        
        task.resume()
        
        print("after function")
        waitForExpectations(timeout: 10, handler: nil)
        XCTAssert(totalBalance != "")
    }

    func test_google_place() {
        
        let address = "1 Infinite Loop, CA, USA"
        let geocoder = CLGeocoder()
        let expectation = self.expectation(description: "Testing google returning value")
        
        geocoder.geocodeAddressString(address, completionHandler: {(placemarks, error) -> Void in
            if((error) != nil){
                print("Error", error)
            }
            if let placemark = placemarks?.first {
                let coordinates:CLLocationCoordinate2D = placemark.location!.coordinate
                print(coordinates.longitude)
                print(coordinates.latitude)
            }
            expectation.fulfill()
        })
        
        
        waitForExpectations(timeout: 10, handler: nil)
        
    }
    
    func testDownloadWebData() {
        
        // Create an expectation for a background download task.
        let expectation = XCTestExpectation(description: "Download apple.com home page")
        
        // Create a URL for a web page to be downloaded.
        let url = URL(string: "https://apple.com")!
        
        // Create a background task to download the web page.
        let dataTask = URLSession.shared.dataTask(with: url) { (data, _, _) in
            
            // Make sure we downloaded some data.
            XCTAssertNotNil(data, "No data was downloaded.")
            // Fulfill the expectation to indicate that the background task has finished successfully.
            expectation.fulfill()
            
        }
        
        // Start the download task.
        dataTask.resume()
        
        
        // Wait until the expectation is fulfilled, with a timeout of 10 seconds.
        wait(for: [expectation], timeout: 10.0)
    }
    
    func test_alamofire () {
        let expectation = XCTestExpectation(description: "Download apple.com home page")
        let url = "https://spotbird-backend-bloughran618.herokuapp.com/test_stripe"
        
        Alamofire.request(url).response { response in
            XCTAssertNotNil(response)
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
}
