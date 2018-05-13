//
//  Car.swift
//  Spotbirdparking
//
//  Created by user138340 on 4/25/18.
//  Copyright © 2018 Spotbird. All rights reserved.
//

import UIKit

class CarCell: UITableViewCell {

    //MARK: Properties
    @IBOutlet weak var CarMakeModelLabel: UILabel!
    @IBOutlet weak var CarYearLabel: UILabel!
    @IBOutlet weak var CarImageView: UIImageView!
    @IBOutlet weak var CarDefaultImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
