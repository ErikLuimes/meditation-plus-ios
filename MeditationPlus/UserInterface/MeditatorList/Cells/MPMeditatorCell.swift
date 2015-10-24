//
//  MPMeditatorCell.swift
//  MeditationPlus
//
//  Created by Erik Luimes on 12/09/15.
//  Copyright (c) 2015 Maya Interactive. All rights reserved.
//

import UIKit
import QuartzCore
import SDWebImage

class MPMeditatorCell: UITableViewCell {
    private var meditator: MPMeditator?
    
    private var displayProgress: Bool = false
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var avatarImageView: UIImageView!
    
    @IBOutlet weak var meditationDescription: UILabel!

    private let circlePathLayer = CAShapeLayer()
    private let circlePathTrackLayer = CAShapeLayer()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()

        circlePathTrackLayer.hidden      = true
        circlePathTrackLayer.frame       = avatarImageView.bounds
        circlePathTrackLayer.lineWidth   = 12
        circlePathTrackLayer.strokeColor = UIColor.darkGrayColor().colorWithAlphaComponent(0.6).CGColor
        circlePathTrackLayer.fillColor   = UIColor.clearColor().CGColor
        circlePathTrackLayer.path        = UIBezierPath(ovalInRect: avatarImageView.bounds).CGPath
        circlePathTrackLayer.strokeEnd   = 1
        avatarImageView.layer.addSublayer(circlePathTrackLayer)

        circlePathLayer.hidden      = true
        circlePathLayer.frame       = avatarImageView.bounds
        circlePathLayer.lineWidth   = 10
        circlePathLayer.strokeColor = UIColor.whiteColor().colorWithAlphaComponent(0.8).CGColor
        circlePathLayer.fillColor   = UIColor.clearColor().CGColor
        circlePathLayer.path        = UIBezierPath(ovalInRect: avatarImageView.bounds).CGPath
        circlePathLayer.transform   = CATransform3DMakeRotation(CGFloat(-M_PI_2), 0, 0, 1)
        circlePathLayer.strokeEnd   = 0
        avatarImageView.layer.addSublayer(circlePathLayer)
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        meditator       = nil
        displayProgress = false
        
        circlePathTrackLayer.hidden = true
        circlePathLayer.hidden      = true
        
        imageView?.image = nil
    }
    
    func configureWithMeditator(meditator: MPMeditator, displayProgress: Bool){
        self.displayProgress = displayProgress
        self.meditator       = meditator
        
        circlePathTrackLayer.hidden = !displayProgress
        circlePathLayer.hidden      = !displayProgress
        
        if let imageUrl = meditator.avatar {
            avatarImageView.sd_setImageWithURL(imageUrl)
            avatarImageView.clipsToBounds = true
            avatarImageView.layer.borderColor = UIColor.darkGrayColor().colorWithAlphaComponent(0.6).CGColor
            avatarImageView.layer.borderWidth = 1
            avatarImageView.layer.masksToBounds = true
            avatarImageView.layer.cornerRadius  = avatarImageView.bounds.size.height / 2.0
        }

        if displayProgress {
            let strokeAnim            = CABasicAnimation(keyPath:"strokeEnd")
            strokeAnim.duration       = 0.75
            strokeAnim.fromValue      = circlePathLayer.strokeEnd
            strokeAnim.toValue        = meditator.normalizedProgress
            strokeAnim.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            
            circlePathLayer.addAnimation(strokeAnim, forKey: "strokeEnd")
            circlePathLayer.strokeEnd = CGFloat(meditator.normalizedProgress)
        }

        nameLabel?.text = meditator.username
        
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
        
        meditationDescription.text = meditations.joinWithSeparator(", ")
    }
    
    func updateProgressIndicatorIfNeeded()
    {
        if displayProgress {
            circlePathLayer.strokeEnd = CGFloat(meditator?.normalizedProgress ?? 0.0)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
}
