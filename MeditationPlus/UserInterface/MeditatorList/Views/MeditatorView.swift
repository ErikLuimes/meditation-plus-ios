//
//  MeditatorView.swift
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
import SDWebImage
import Rswift

class MeditatorView: UIView
{
    private var selectionViewHidden = true

    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var actionView: UIView!

    @IBOutlet weak var selectionView: UIView!

    @IBOutlet weak var meditationPickerView: UIPickerView!

    @IBOutlet weak var startButton: UIButton!

    @IBOutlet weak var profileImageView: UIImageView!

    @IBOutlet weak var confirmationEffectView: UIVisualEffectView!

    @IBOutlet weak var meditationTimerLabel: UILabel!

    @IBOutlet weak var preparationProgressView: UIProgressView!

    @IBOutlet weak var selectionViewTopConstraint: NSLayoutConstraint!

    var isSelectionViewHidden: Bool
    {
        return selectionViewHidden
    }

    var visibleSelectionViewTopConstant: CGFloat = 0
    var hiddenSelectionViewTopConstant: CGFloat = 0

    var refreshControl: UIRefreshControl!

    override func awakeFromNib()
    {
        super.awakeFromNib()

        tableView.contentInset          = UIEdgeInsetsMake(CGRectGetHeight(actionView.frame), 0.0, 49, 0.0)
        tableView.scrollIndicatorInsets = UIEdgeInsetsMake(CGRectGetHeight(actionView.frame), 0.0, 49, 0.0)
        tableView.rowHeight             = UITableViewAutomaticDimension
        tableView.estimatedRowHeight    = 90
        tableView.tableFooterView       = UIView()
        tableView.registerNib(R.nib.meditatorCell(), forCellReuseIdentifier: R.nib.meditatorCell.name)

        profileImageView.layer.borderColor   = UIColor.whiteColor().colorWithAlphaComponent(0.8).CGColor
        profileImageView.layer.borderWidth   = 5
        profileImageView.layer.masksToBounds = true

        startButton.layer.borderColor = startButton.titleColorForState(.Normal)?.CGColor

        refreshControl           = UIRefreshControl()
        refreshControl.tintColor = UIColor.orangeColor()
        tableView.addSubview(refreshControl)

        visibleSelectionViewTopConstant = selectionViewTopConstraint.constant
        hiddenSelectionViewTopConstant  = -CGRectGetMinY(confirmationEffectView.frame)
    }

    func setSelectionViewHidden(hidden: Bool, animated: Bool)
    {
        selectionViewHidden = hidden
        startButton.setTitle(hidden ? NSLocalizedString("stop", comment: "") : NSLocalizedString("start", comment: ""), forState: UIControlState.Normal)

        if !hidden {
            meditationTimerLabel.text = "00:00:00"
            preparationProgressView.setProgress(1.0, animated: true)
        }

        let duration: NSTimeInterval = animated ? 0.5 : 0.0

        selectionViewTopConstraint.constant = hidden ? hiddenSelectionViewTopConstant : visibleSelectionViewTopConstant

        UIView.animateWithDuration(duration, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 9.8, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            () -> Void in
            self.layoutIfNeeded()
        }, completion: nil)
    }
    
    func configureWithProfile(profile: Profile)
    {
        if let imageUrl = profile.avatar {
            self.profileImageView.sd_setImageWithURL(imageUrl, completed: { (image, error, cacheType, url) in
                if cacheType == SDImageCacheType.None {
                    UIView.transitionWithView(self.profileImageView, duration: 0.3, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: {
                        self.profileImageView.image = image
                    }, completion: nil)
                } else {
                    self.profileImageView.image = image
                }
            })
        }
    }

    override func layoutSubviews()
    {
        super.layoutSubviews()

        profileImageView.layer.cornerRadius       = profileImageView.bounds.size.height / 2.0
        profileImageView.layer.shouldRasterize    = true
        profileImageView.layer.rasterizationScale = UIScreen.mainScreen().scale
    }
}