//
//  CarsTableViewCell.swift
//  Spothawk
//
//  Created by user138340 on 6/3/18.
//  Copyright © 2020 Spothawk. All rights reserved.
//

import UIKit

class CarsTableViewCell: UITableViewCell {
    @IBOutlet weak var ImageName: UIImageView!
    @IBOutlet weak var MakeModel: UILabel!
    @IBOutlet weak var YearLabel: UILabel!
    @IBOutlet weak var Default: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
      
    }
        

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
