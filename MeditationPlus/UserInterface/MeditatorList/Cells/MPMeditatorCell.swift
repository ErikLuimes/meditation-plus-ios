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

    private let circlePathLayer = CAShapeLayer()
    private let circlePathTrackLayer = CAShapeLayer()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()

        self.circlePathTrackLayer.frame       = self.avatarImageView.bounds
        self.circlePathTrackLayer.lineWidth   = 12
        self.circlePathTrackLayer.strokeColor = UIColor.darkGrayColor().colorWithAlphaComponent(0.6).CGColor
        self.circlePathTrackLayer.fillColor   = UIColor.clearColor().CGColor
        self.circlePathTrackLayer.path        = UIBezierPath(ovalInRect: self.avatarImageView.bounds).CGPath
        self.circlePathTrackLayer.strokeEnd   = 1
        self.avatarImageView.layer.addSublayer(circlePathTrackLayer)

        var pathRect = CGRectInset(self.avatarImageView.bounds, 4, 4)
        self.circlePathLayer.frame       = self.avatarImageView.bounds
        self.circlePathLayer.lineWidth   = 10
        self.circlePathLayer.strokeColor = UIColor.whiteColor().colorWithAlphaComponent(0.8).CGColor
        self.circlePathLayer.fillColor   = UIColor.clearColor().CGColor
        self.circlePathLayer.path        = UIBezierPath(ovalInRect: self.avatarImageView.bounds).CGPath
        self.circlePathLayer.transform   = CATransform3DMakeRotation(CGFloat(-M_PI_2), 0, 0, 1)
        self.circlePathLayer.strokeEnd   = 0
        self.avatarImageView.layer.addSublayer(circlePathLayer)
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureWithMeditator(meditator: MPMeditator){
        if let imageUrl = meditator.avatar {
            self.avatarImageView.setImageWithURL(imageUrl)
            self.avatarImageView.clipsToBounds = true
            self.avatarImageView.layer.borderColor = UIColor.darkGrayColor().colorWithAlphaComponent(0.6).CGColor
            self.avatarImageView.layer.borderWidth = 1
            self.avatarImageView.layer.masksToBounds = true
            self.avatarImageView.layer.cornerRadius  = self.avatarImageView.bounds.size.height / 2.0
        }

        var strokeAnim            = CABasicAnimation(keyPath:"strokeEnd")
        strokeAnim.duration       = 0.75
        strokeAnim.fromValue      = self.circlePathLayer.strokeEnd
        strokeAnim.toValue        = meditator.normalizedProgress
        strokeAnim.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        
        self.circlePathLayer.addAnimation(strokeAnim, forKey: "strokeEnd")
        self.circlePathLayer.strokeEnd = CGFloat(meditator.normalizedProgress)

        self.nameLabel?.text = meditator.username
        
        var meditations: [String] = [String]()
        
        if let walkingMinutes: Int = meditator.walkingMinutes where walkingMinutes > 0 {
            meditations.append("walking \(walkingMinutes)m")
        }

        if let sittingMinutes: Int = meditator.sittingMinutes where sittingMinutes > 0 {
            meditations.append("sitting \(sittingMinutes)m")
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
