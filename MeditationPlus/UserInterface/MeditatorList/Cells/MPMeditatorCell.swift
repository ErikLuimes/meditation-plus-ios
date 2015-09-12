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

    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var avatarImageView: UIImageView!
    
    @IBOutlet weak var meditationDescription: UILabel!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
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
            self.avatarImageView.setImageWithURL(imageUrl)
            self.avatarImageView.clipsToBounds = true
            self.avatarImageView.layer.borderColor = UIColor.lightGrayColor().CGColor
            self.avatarImageView.layer.borderWidth = 1
            self.avatarImageView.layer.masksToBounds = true
            self.avatarImageView.layer.cornerRadius  = self.avatarImageView.bounds.size.height / 2.0
        }
        
        self.nameLabel?.text = meditator.username
        
        var meditations: [String] = [String]()

        if let sittingMinutes: Int = meditator.sittingMinutes where sittingMinutes > 0 {
            meditations.append("sitting \(sittingMinutes)m")
        }
        
        if let walkingMinutes: Int = meditator.walkingMinutes where walkingMinutes > 0 {
            meditations.append("walking \(walkingMinutes)m")
        }
        
        if let anumodanaMinutes: Int = meditator.anumodanaMinutes where anumodanaMinutes > 0 {
            meditations.append("anumodana \(anumodanaMinutes)m")
        }
        
        self.meditationDescription.text = ", ".join(meditations)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
}
