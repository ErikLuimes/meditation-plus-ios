//
//  MPMeditatorCell.swift
//  MeditationPlus
//
//  Created by Erik Luimes on 12/09/15.
//  Copyright (c) 2015 Maya Interactive. All rights reserved.
//

import UIKit
import QuartzCore

class MPMeditatorCell: UITableViewCell {

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.imageView?.autoresizingMask = UIViewAutoresizing.None
        self.imageView?.contentMode      = UIViewContentMode.ScaleAspectFit
        self.imageView?.clipsToBounds    = true
        
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureWithMeditator(meditator: MPMeditator){
        if let imageUrl = meditator.avatar {
            self.imageView?.setImageWithURL(imageUrl)
        }
        
        
        self.textLabel?.text       = meditator.username
        // self.detailTextLabel?.text = meditator.username
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if self.imageView != nil {
            let height: CGFloat = CGRectGetHeight(self.bounds)
            let margin: CGFloat = height / 6.0
            let length: CGFloat = height - 2 * margin
            
            self.imageView!.frame = CGRectMake(margin, margin, length, length)
            self.imageView!.layer.borderColor = UIColor.lightGrayColor().CGColor
            self.imageView!.layer.borderWidth = 1
            self.imageView!.layer.cornerRadius  = length / 2.0
            self.imageView!.layer.masksToBounds = true
            
            self.imageView?.autoresizingMask = UIViewAutoresizing.None
            self.imageView?.contentMode      = UIViewContentMode.ScaleAspectFit
            self.imageView?.clipsToBounds    = true
            
            self.contentView.setNeedsLayout()
        }
        
        self.contentView.backgroundColor = UIColor.magentaColor()
    }
    
}
