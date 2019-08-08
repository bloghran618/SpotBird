


//
//  ReservationsDetailViewController.swift
//  Spotbirdparking
//
//  Created by mac on 29/04/19.
//  Copyright © 2019 Spotbird. All rights reserved.
//

import UIKit
import Firebase
import Alamofire
import CryptoSwift

class ReservationsDetailViewController: UIViewController {
    
    @IBOutlet weak var imgSpot: UIImageView!
    
    @IBOutlet weak var lblAddress: UILabel!
    
    @IBOutlet weak var lblType: UILabel!
    
    @IBOutlet weak var imgIcon: UIImageView!
    
    @IBOutlet weak var lblStart: UILabel!
    
    @IBOutlet weak var lblEnd: UILabel!
    
    @IBOutlet weak var lblPrice: UILabel!
    
    @IBOutlet weak var lblEmail: UILabel!
    
    @IBOutlet weak var lblDesc: UILabel!
    
    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var Cancel: UIButton!
    
    var resOnDay = [Reservation]()
     var index = 0
    
     var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let res = resOnDay[index]
        print(res)
        
        lblTitle.text = "Your Reserved Spot"
        let CompileAddress = "Address: " + res.spot.address + " " + res.spot.town + ", " + res.spot.state + " " + res.spot.zipCode
        lblAddress.attributedText = attributedText(withString: CompileAddress, boldString: "Address: ", font: UIFont.systemFont(ofSize: 17.0))
        lblEmail.attributedText = attributedText(withString: "Contact: " + res.spot.Email, boldString: "Contact: ", font: UIFont.systemFont(ofSize: 17.0))
        lblType.attributedText = attributedText(withString: "Type: " + res.spot.spot_type, boldString: "Type: ", font: UIFont.systemFont(ofSize: 17.0))
        
        if res.spot.spot_type == "Street" {
            imgIcon.image = UIImage.init(named: "streetParking")
        }
        if res.spot.spot_type == "Lot" {
            imgIcon.image = UIImage.init(named: "lotParking")
        }
        if res.spot.spot_type == "Garage" {
            imgIcon.image = UIImage.init(named: "garageParking")
        }
        if res.spot.spot_type == "Driveway" {
            imgIcon.image = UIImage.init(named: "drivewayParking")
        }
        
        lblStart.attributedText = attributedText(withString: "Begin: " + convertDateFormatter(date: res.startDateTime), boldString: "Begin: ", font: UIFont.systemFont(ofSize: 17.0))
        lblEnd.attributedText = attributedText(withString: "End: " + convertDateFormatter(date: res.endDateTime), boldString: "End: ", font: UIFont.systemFont(ofSize: 17.0))
        
        lblPrice.attributedText = attributedText(withString: "Paid: $" + res.price, boldString: "Paid: ", font: UIFont.systemFont(ofSize: 17.0))
        
        lblDesc.numberOfLines = 0
        lblDesc.lineBreakMode = .byWordWrapping
        lblDesc.attributedText = attributedText(withString: "Description: " + res.spot.description, boldString: "Description: ", font: UIFont.systemFont(ofSize: 17.0))
        lblDesc.sizeToFit()
        
        imgSpot.image = UIImage.init(named: res.spot.spotImage)
        imgSpot.sd_setImage(with: URL(string: res.spot.spotImage), placeholderImage: UIImage(named: "emptySpot"))
        
        if hasReservationPassed() {
            self.Cancel.isHidden = true
        }
    }
    
    @IBAction func backTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func Cancel(_ sender: Any) {
        let alert = UIAlertController(title: "Cancel", message: "Warning: This is a beta function and does not completely delete reservations and refund money", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { action in
            print("Canceling")
            self.refundCharge()
            self.removeScheduledJob()
            self.deleteParkingReservation()
            self.deleteSpotReservation()
            
            self.dismiss(animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        
        self.present(alert, animated: true)
        
    }
    /*
    @IBAction func start_scheduler(_ sender: Any) {
        
        
        let url = "https://spotbird-backend-bloughran618.herokuapp.com/APScheduler_testing"
        print("before starting scheduler")
        let res = resOnDay[index]
        
        let params: [String: Any] = ["spot_id": res.spot.spot_id, "start_date": res.startDateTime]
        
        Alamofire.request(url, method: .post, parameters: params)
            .validate(statusCode: 200..<300)
            .responseJSON { response in
                switch response.result {
                case .success:
                    print("Returned with success")
                case .failure:
                    print("Failure")
                }
                
        }
        print("after starting scheduler")
        
    }
 */
    
    func hasReservationPassed() -> Bool {
        let res = resOnDay[index]
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        let date = formatter.string(from: Date())
        return date > res.startDateTime
    }
        
    func removeScheduledJob() {
        
        let res = resOnDay[index]
        let url = "https://spotbird-backend-bloughran618.herokuapp.com/remove_specified_job"
        let params: [String: Any] = ["spot_id": res.spot.spot_id, "start_date": res.startDateTime]
        
        Alamofire.request(url, method: .post, parameters: params)
            .validate(statusCode: 200..<300)
            .responseJSON { response in
                switch response.result {
                case .success:
                    print("Returned with success")
                case .failure:
                    print("Failure")
                }
                
        }
        print("Job being removed")
        
    }
    
    func deleteSpotReservation() {
        self.ref = Database.database().reference()
        let res = resOnDay[index]
        
        self.ref.child("User").child(res.ownerID).child("Reservations").observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as! NSDictionary
            
            for eachRes in value {
                //print(eachRes.key)
                let resInfo = value[eachRes.key] as! NSDictionary
                if (resInfo["carID"] as! String) == res.car.car_uid && (resInfo["endDateTime"] as! String) == res.endDateTime && (resInfo["ownerID"] as! String) == res.ownerID && (resInfo["parkOrRent"] as! String) != res.parkOrRent && (resInfo["parkerID"] as! String) == res.parkerID && (resInfo["price"] as! String) == res.price && (resInfo["spotID"] as! String) == res.spot.spot_id && (resInfo["startDateTime"] as! String) == res.startDateTime {
                    print(eachRes.key)
                    print(resInfo)
                    self.ref.child("User").child(res.ownerID).child("Reservations").child(eachRes.key as! String).setValue(nil)
                }
            }
            
        }) { (error) in
            print(error.localizedDescription)
        }
        
    }
    
    func deleteParkingReservation() {
        self.ref = Database.database().reference()
        let res = resOnDay[index]
        
        //Deleting reservation from database
        self.ref.child("User").child(res.parkerID).child("Reservations").observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as! NSDictionary
            //print(value)
            
            for eachRes in value {
                //print(eachRes.key)
                let resInfo = value[eachRes.key] as! NSDictionary
                if (resInfo["carID"] as! String) == res.car.car_uid && (resInfo["endDateTime"] as! String) == res.endDateTime && (resInfo["ownerID"] as! String) == res.ownerID && (resInfo["parkOrRent"] as! String) == res.parkOrRent && (resInfo["parkerID"] as! String) == res.parkerID && (resInfo["price"] as! String) == res.price && (resInfo["spotID"] as! String) == res.spot.spot_id && (resInfo["startDateTime"] as! String) == res.startDateTime {
                    print(eachRes.key)
                    print(resInfo)
                    self.ref.child("User").child(res.parkerID).child("Reservations").child(eachRes.key as! String).setValue(nil)
                }
                
            }
            
        }) { (error) in
            print(error.localizedDescription)
        }
        
        //Deleting reservation from reservation list for view controller
        /*var resIndex = 0
        
        for eachRes in AppState.sharedInstance.user.reservations {
            if res.car.car_uid == eachRes.car.car_uid && res.endDateTime == eachRes.endDateTime && res.ownerID == eachRes.ownerID && res.parkerID == eachRes.parkerID && res.price == eachRes.price && res.spot.spot_id == eachRes.spot.spot_id && res.startDateTime == eachRes.startDateTime {
                AppState.sharedInstance.user.reservations.remove(at: resIndex)
                print("Reservation deleted from reservation list: ")
                print(eachRes)
            }
            resIndex += 1
        } */
        
    }
    
    func refundCharge() {
        
        let res = resOnDay[index]
        let url = "https://spotbird-backend-bloughran618.herokuapp.com/refund_charge"
        let params: [String: Any] = ["paymentIntent_id": res.paymentIntent_id]
        
        print(res.paymentIntent_id)
        
        Alamofire.request(url, method: .post, parameters: params)
            .validate(statusCode: 200..<300)
            .responseJSON { response in
                switch response.result {
                case .success:
                    print("Returned with success")
                case .failure:
                    print("Failure")
                }
                
        }
        print("Charge being refunded")
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func attributedText(withString string: String, boldString: String, font: UIFont) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: string,
                                                         attributes: [NSAttributedStringKey.font: font])
        let boldFontAttribute: [NSAttributedStringKey: Any] = [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: font.pointSize)]
        let range = (string as NSString).range(of: boldString)
        attributedString.addAttributes(boldFontAttribute, range: range)
        return attributedString
    }
    
    func convertDateFormatter(date: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"//this your string date format
        dateFormatter.timeZone = NSTimeZone(name: "EST") as TimeZone!
        dateFormatter.locale = Locale(identifier: "your_loc_id")
        let convertedDate = dateFormatter.date(from: date)
        
        guard dateFormatter.date(from: date) != nil else {
            assert(false, "no date from string")
            return ""
        }
        
        dateFormatter.dateFormat = "MMMM d, yyyy h:mm a"///this is what you want to convert format
        dateFormatter.timeZone = NSTimeZone(name: "EST") as TimeZone!
        let timeStamp = dateFormatter.string(from: convertedDate!)
        
        return timeStamp
    }
    
}

