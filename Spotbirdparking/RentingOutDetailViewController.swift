//
//  RentingOutDetailViewController.swift
//  Spotbirdparking
//
//  Created by Drew Loughran on 6/4/19.
//  Copyright © 2019 Spotbird. All rights reserved.
//

import UIKit
import themis

class RentingOutDetailViewController: UIViewController {

    @IBOutlet weak var lblAddress: UILabel!
    
    @IBOutlet weak var lblType: UILabel!
    
    @IBOutlet weak var imgIcon: UIImageView!
    
    @IBOutlet weak var lblBegin: UILabel!
    
    @IBOutlet weak var lblFinsih: UILabel!
    
    @IBOutlet weak var lblPrice: UILabel!
    
    @IBOutlet weak var lblCar: UILabel!
    
    @IBOutlet weak var imgCar: UIImageView!
    
    @IBOutlet weak var lblTitle: UILabel!
    
    var resOnDay = [Reservation]()
    var index = 0

    
    override func viewDidLoad() {
        super.viewDidLoad()
        let res = resOnDay[index]
        print(res)
        
        lblTitle.text = "Your Rented Spot"
        let CompileAddress = "Address: " + res.spot.address + " " + res.spot.town + ", " + res.spot.state + " " + res.spot.zipCode
        lblAddress.attributedText = attributedText(withString: CompileAddress, boldString: "Address: ", font: UIFont.systemFont(ofSize: 17.0))
        lblBegin.attributedText = attributedText(withString: "Begin: " + convertDateFormatter(date: res.startDateTime), boldString: "Begin: ", font: UIFont.systemFont(ofSize: 17.0))
        lblFinsih.attributedText = attributedText(withString: "End: " + convertDateFormatter(date: res.endDateTime), boldString: "End: ", font: UIFont.systemFont(ofSize: 17.0))
        lblPrice.attributedText = attributedText(withString: "Price: $" + res.price, boldString: "Price: ", font: UIFont.systemFont(ofSize: 17.0))
        let carString = "Car: " + res.car.make + " " + res.car.model // + " " + res.car.year
        lblCar.attributedText = attributedText(withString: carString + ", " + res.car.year!, boldString: "Car: ", font: UIFont.systemFont(ofSize: 17.0))
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
        
        imgCar.sd_setImage(with: URL(string: res.car.carImage), placeholderImage: UIImage(named: "Placeholder"))
        
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
    
    @IBAction func backTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
}
