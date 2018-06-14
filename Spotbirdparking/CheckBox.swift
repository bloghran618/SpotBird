//
//  CheckBox.swift
//  Spotbirdparking
//
//  Created by user138340 on 6/12/18.
//  Copyright © 2018 Spotbird. All rights reserved.
//

import UIKit

class CheckBox: UIButton {
    let checkedImage = UIImage(named: "checked")
    let unCheckedImage = UIImage(named: "unchecked")

    // Bool property
    var isChecked: Bool = false {
        didSet{
            if isChecked == true {
                self.setImage(checkedImage, for: UIControlState.normal)
            } else {
                self.setImage(unCheckedImage, for: UIControlState.normal)
            }
        }
    }
    
    override func awakeFromNib() {
        self.addTarget(self, action:#selector(buttonClicked(sender:)), for: UIControlEvents.touchUpInside)
        self.isChecked = false
    }
    
    @objc func buttonClicked(sender: UIButton) {
        if sender == self {
            isChecked = !isChecked
        }
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
