


//
//  ReservationsDetailViewController.swift
//  Spotbirdparking
//
//  Created by mac on 29/04/19.
//  Copyright © 2019 Spotbird. All rights reserved.
//

import UIKit

class ReservationsDetailViewController: UIViewController {

    @IBOutlet weak var imgSpot: UIImageView!
    
    @IBOutlet weak var lblAddress: UILabel!
    
    @IBOutlet weak var lblEmail: UILabel!
    
    @IBOutlet weak var lblType: UILabel!
    
    @IBOutlet weak var lblRStartEnd: UILabel!
    
    @IBOutlet weak var lblDesc: UILabel!
    var resOnDay = [Reservation]()
     var index = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let res = resOnDay[index]
        print(res)
        lblAddress.text = "Address: " + res.spot.address
        lblEmail.text = "Email: " + res.spot.Email
        lblType.text = "Type: " + res.spot.spot_type
        lblRStartEnd.text = "Begin: " + res.startDateTime + "Finish: " + res.endDateTime
        lblDesc.text = "Description: " + res.spot.description
        imgSpot.image = UIImage.init(named: res.spot.spotImage)
        imgSpot.sd_setImage(with: URL(string: res.spot.spotImage), placeholderImage: UIImage(named: "emptySpot"))
        // Do any additional setup after loading the view.
    }
    
    @IBAction func backTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
