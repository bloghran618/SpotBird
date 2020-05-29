//
//  SpotTableViewCell.swift
//  Spothawk
//
//  Created by user138340 on 7/12/18.
//  Copyright © 2020 Spothawk. All rights reserved.
//

import UIKit

class SpotTableViewCell: UITableViewCell {
    
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var townCityZipLabel: UILabel!
    @IBOutlet weak var spotImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
