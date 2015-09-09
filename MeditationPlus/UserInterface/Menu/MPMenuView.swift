//
//  MTMenuView.swift
//  MeditationPlus
//
//  Created by Erik Luimes on 09/09/15.
//  Copyright © 2015 Maya Interactive. All rights reserved.
//

import UIKit

class MPMenuView: UIView {
    @IBOutlet weak var menuTableView: UITableView!

    @IBOutlet weak var blurView: UIVisualEffectView! {
        didSet {
            blurView.layer.cornerRadius  = 10
            blurView.layer.masksToBounds = true
        }
    }
    
    @IBOutlet weak var cutoutImageView: UIImageView! {
        didSet {
            cutoutImageView.image = UIImage(named: "buddha")?.imageWithRenderingMode(.AlwaysTemplate)
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let tableViewHeight        = CGRectGetHeight(self.menuTableView.frame)
        let tableViewContentHeight = self.menuTableView.contentSize.height
        
        if tableViewContentHeight < tableViewHeight {
            self.menuTableView.contentInset = UIEdgeInsetsMake((tableViewHeight - tableViewContentHeight) / 2, 0, 0, 0)
        }
    }

}
