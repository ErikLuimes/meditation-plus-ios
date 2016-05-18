//
//  MeditatorCell.swift
//  MeditationPlus
//
//  Created by Erik Luimes on 12/09/15.
//
//  The MIT License
//  Copyright (c) 2015 Maya Interactive. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//
// Except as contained in this notice, the name of Maya Interactive and Meditation+
// shall not be used in advertising or otherwise to promote the sale, use or other
// dealings in this Software without prior written authorization from Maya Interactive.
//

import UIKit
import QuartzCore
import SDWebImage

public protocol MeditatorCellDelegate
{
    func cell(cell: MeditatorCell, didTapInfoButton button: UIButton)
}

public class MeditatorCell: UITableViewCell
{
    public var delegate: MeditatorCellDelegate?
    
    private var meditator: Meditator?

    private var displayProgress: Bool = false

    @IBOutlet weak var nameLabel: UILabel!

    @IBOutlet weak var avatarImageView: UIImageView!

    @IBOutlet weak var meditationDescription: UILabel!

    private let circlePathLayer = CAShapeLayer()
    
    private let circlePathTrackLayer = CAShapeLayer()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?)
    {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required public init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }

    override public func awakeFromNib()
    {
        super.awakeFromNib()
        
        let pathFrame = CGRect(x: 0, y: 0, width: 70, height: 70)

        circlePathTrackLayer.hidden      = true
        circlePathTrackLayer.frame       = pathFrame
        circlePathTrackLayer.lineWidth   = 9
        circlePathTrackLayer.strokeColor = UIColor.darkGrayColor().colorWithAlphaComponent(0.6).CGColor
        circlePathTrackLayer.fillColor   = UIColor.clearColor().CGColor
        circlePathTrackLayer.path        = UIBezierPath(ovalInRect: CGRectInset(pathFrame, 1, 1)).CGPath
        circlePathTrackLayer.strokeEnd   = 1
        avatarImageView.layer.addSublayer(circlePathTrackLayer)

        circlePathLayer.hidden      = true
        circlePathLayer.frame       = pathFrame
        circlePathLayer.lineWidth   = 8
        circlePathLayer.strokeColor = UIColor.whiteColor().colorWithAlphaComponent(0.8).CGColor
        circlePathLayer.fillColor   = UIColor.clearColor().CGColor
        circlePathLayer.path        = UIBezierPath(ovalInRect: CGRectInset(pathFrame, 1, 1)).CGPath
        circlePathLayer.transform   = CATransform3DMakeRotation(CGFloat(-M_PI_2), 0, 0, 1)
        circlePathLayer.strokeEnd   = 0
        avatarImageView.layer.addSublayer(circlePathLayer)

        selectionStyle = .Default
        
        let button: UIButton = UIButton(type: UIButtonType.InfoLight)
        button.tintColor     = UIColor.orangeColor()
        button.addTarget(self, action: #selector(MeditatorCell.didTapInfoButton(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        accessoryView = button

        avatarImageView.layer.borderColor        = UIColor.darkGrayColor().colorWithAlphaComponent(0.6).CGColor
        avatarImageView.layer.borderWidth        = 1
        avatarImageView.layer.masksToBounds      = true
        avatarImageView.layer.cornerRadius       = 35
        avatarImageView.layer.shouldRasterize    = true
        avatarImageView.layer.rasterizationScale = UIScreen.mainScreen().scale
    }

    override public func prepareForReuse()
    {
        meditator       = nil
        displayProgress = false

        circlePathTrackLayer.hidden = true
        circlePathLayer.hidden      = true

        imageView?.image = nil
    }

    func configureWithMeditator(meditator: Meditator, displayProgress: Bool)
    {
        guard !meditator.invalidated else {
            return
        }
        
        self.displayProgress = displayProgress
        self.meditator = meditator

        circlePathTrackLayer.hidden = !displayProgress
        circlePathLayer.hidden = !displayProgress

        if let imageUrl = NSURL(meditator: meditator) {
            self.avatarImageView.sd_setImageWithURL(imageUrl, completed: { (image, error, cacheType, url) in
                if cacheType == SDImageCacheType.None {
                    UIView.transitionWithView(self.avatarImageView, duration: 0.3, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: {
                        self.avatarImageView.image = image
                    }, completion: nil)
                } else {
                    self.avatarImageView.image = image
                }
            })
        } else {
            avatarImageView.image = nil
        }

        if displayProgress {
            let strokeAnim            = CABasicAnimation(keyPath: "strokeEnd")
            strokeAnim.duration       = 0.75
            strokeAnim.fromValue      = circlePathLayer.strokeEnd
            strokeAnim.toValue        = meditator.normalizedProgress
            strokeAnim.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)

            circlePathLayer.addAnimation(strokeAnim, forKey: "strokeEnd")
            circlePathLayer.strokeEnd = CGFloat(meditator.normalizedProgress)
        }

        nameLabel?.text = meditator.username

        var meditations: [String] = [String]()

        if let walkingMinutes: Int = meditator.walkingMinutes.value where walkingMinutes > 0 {
            meditations.append("walking \(walkingMinutes)m")
        }

        if let sittingMinutes: Int = meditator.sittingMinutes.value where sittingMinutes > 0 {
            meditations.append("sitting \(sittingMinutes)m")
        }

        meditationDescription.text = meditations.joinWithSeparator(", ")
    }

    func updateProgressIndicatorIfNeeded()
    {
        if displayProgress {
            circlePathLayer.strokeEnd = CGFloat(meditator?.normalizedProgress ?? 0.0)
        }
    }
    
    func didTapInfoButton(button: UIButton)
    {
        delegate?.cell(self, didTapInfoButton: button)
    }

    override public func layoutSubviews()
    {
        super.layoutSubviews()
    }
}
