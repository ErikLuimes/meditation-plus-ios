//
//  MPMeditatorView.swift
//  MeditationPlus
//
//  Created by Erik Luimes on 12/09/15.
//  Copyright (c) 2015 Maya Interactive.
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

import UIKit

class MPMeditatorView: UIView {
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
    
    var isSelectionViewHidden: Bool {
        return selectionViewHidden
    }
    
    var visibleSelectionViewTopConstant: CGFloat = 0
    var hiddenSelectionViewTopConstant: CGFloat = 0
    
    var refreshControl: UIRefreshControl!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        tableView.registerNib(UINib(nibName: "MPMeditatorCell", bundle: nil), forCellReuseIdentifier: MPMeditatorDataSource.MPMeditatorCellIdentifier)
        tableView.contentInset = UIEdgeInsetsMake(CGRectGetHeight(actionView.frame), 0.0, 50, 0.0)
        tableView.scrollIndicatorInsets = UIEdgeInsetsMake(CGRectGetHeight(actionView.frame), 0.0, 50, 0.0)
        
        if let avatarURL = NSUserDefaults.standardUserDefaults().URLForKey("avatar") {
            profileImageView.sd_setImageWithURL(avatarURL)
        }
        
        profileImageView.clipsToBounds       = true
        profileImageView.layer.borderColor   = UIColor.whiteColor().colorWithAlphaComponent(0.8).CGColor
        profileImageView.layer.borderWidth   = 5
        profileImageView.layer.masksToBounds = true

        startButton.layer.borderColor = UIColor.orangeColor().CGColor
        
        refreshControl = UIRefreshControl()
        tableView.addSubview(refreshControl)
        
        visibleSelectionViewTopConstant = selectionViewTopConstraint.constant
        hiddenSelectionViewTopConstant  = -CGRectGetMinY(confirmationEffectView.frame)
    }

    func setSelectionViewHidden(hidden: Bool, animated: Bool) {
        selectionViewHidden = hidden
        startButton.setTitle(hidden ? "Stop" : "Start", forState: UIControlState.Normal)
        
        if !hidden {
            meditationTimerLabel.text = "00:00:00"
            preparationProgressView.setProgress(1.0, animated: true)
        }
        
        let duration: NSTimeInterval = animated ? 0.5 : 0.0
        
        selectionViewTopConstraint.constant = hidden ? hiddenSelectionViewTopConstant : visibleSelectionViewTopConstant
        
        UIView.animateWithDuration(duration, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 9.8, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
            self.layoutIfNeeded()
        }, completion: nil)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        profileImageView.layer.cornerRadius  = profileImageView.bounds.size.height / 2.0
    }
}