//
//  ByDayResTableViewCell.swift
//  LightPark
//
//  Created by Brian Loughran on 11/1/18.
//  Copyright © 2020 LightPark. All rights reserved.
//

import UIKit
import MapKit

@objc protocol User_navDelegates{
    func navigateLocation(cell:ByDayResTableViewCell)
}

class ByDayResTableViewCell: UITableViewCell {
    
    @IBOutlet weak var spotImageView: UIImageView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var cityStateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!
    @IBOutlet weak var navButton: UIButton!
    
     var delegate:User_navDelegates?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func navButtonClicked(_ sender: Any)
    {
        print("Nav button clicked")
           delegate?.navigateLocation(cell: self)
        
    }

}
