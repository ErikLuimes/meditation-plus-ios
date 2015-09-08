//
//  MTMenuView.swift
//  MeditationPlus
//
//  Created by Erik Luimes on 09/09/15.
//  Copyright © 2015 Maya Interactive. All rights reserved.
//

import UIKit

class MTMenuView: UIView {

    @IBOutlet weak var blurView: UIVisualEffectView! {
        didSet {
            blurView.layer.cornerRadius  = 10
            blurView.layer.masksToBounds = true
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
