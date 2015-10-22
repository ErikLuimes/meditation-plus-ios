//
//  MPMeditatorView.swift
//  MeditationPlus
//
//  Created by Erik Luimes on 12/09/15.
//  Copyright (c) 2015 Maya Interactive. All rights reserved.
//

import UIKit

class MPMeditatorView: UIView {
//    private var confirmationEffectViewHeight: CGFloat = 32
    
    private var selectionViewHidden = true
    
    private let selectionViewMargin: CGFloat = 20
    
    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var actionView: UIView!
    
    @IBOutlet weak var selectionView: UIView!
    
    @IBOutlet weak var meditationPickerView: UIPickerView!
    
    @IBOutlet weak var startButton: UIButton!
    
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var confirmationEffectView: UIVisualEffectView!
    
    @IBOutlet weak var meditationTimerLabel: UILabel!
    
    @IBOutlet weak var preparationProgressView: UIProgressView!
    
    @IBOutlet weak var selectionViewTopConstraint: NSLayoutConstraint! {
        didSet {
            originalSelectionViewTopConstant    = -selectionView.frame.size.height + confirmationEffectView.frame.size.height - selectionViewMargin
            selectionViewTopConstraint.constant = originalSelectionViewTopConstant
        }
    }
    
    var isSelectionViewHidden: Bool {
        return selectionViewHidden
    }
    
    var originalSelectionViewTopConstant: CGFloat = 0
    
    var refreshControl: UIRefreshControl!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        tableView.registerNib(UINib(nibName: "MPMeditatorCell", bundle: nil), forCellReuseIdentifier: MPMeditatorDataSource.MPMeditatorCellIdentifier)
        tableView.contentInset = UIEdgeInsetsMake(CGRectGetMaxY(actionView.frame) + 20, 0.0, 15.0, 0.0)
        
//        profileImageView.setImageWithURL(NSURL(string: "http://3.bp.blogspot.com/_HtW_SPtpj0c/TLFVC8kb3yI/AAAAAAAAAGM/AAzGYbO6gP4/s1600/Buddha%5B1%5D.jpg")!)
        profileImageView.sd_setImageWithURL(NSURL(string: "http://www.crystalinks.com/BuddhaSitting.jpg")!)
        profileImageView.clipsToBounds       = true
        profileImageView.layer.borderColor   = UIColor.whiteColor().colorWithAlphaComponent(0.8).CGColor
        profileImageView.layer.borderWidth   = 5
        profileImageView.layer.masksToBounds = true

        
        refreshControl = UIRefreshControl()
        tableView.addSubview(refreshControl)
    }

    func setSelectionViewHidden(hidden: Bool, animated: Bool) {
        selectionViewHidden = hidden
        
        startButton.setTitle(hidden ? "Stop meditation" : "Start meditation", forState: UIControlState.Normal)
        
        if hidden {
            meditationTimerLabel.text = "00:00:00"
            preparationProgressView.setProgress(1.0, animated: true)
        }
        
        let duration: NSTimeInterval = animated ? 0.5 : 0.0
        let downedConstant: CGFloat  = -selectionViewMargin
        
        selectionViewTopConstraint.constant = hidden ? originalSelectionViewTopConstant : downedConstant
        
        UIView.animateWithDuration(duration, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 9.8, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
            self.layoutIfNeeded()
        }, completion: nil)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        profileImageView.layer.cornerRadius  = profileImageView.bounds.size.height / 2.0
    }
    
}
