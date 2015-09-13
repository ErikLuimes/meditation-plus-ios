//
//  MPMeditatorView.swift
//  MeditationPlus
//
//  Created by Erik Luimes on 12/09/15.
//  Copyright (c) 2015 Maya Interactive. All rights reserved.
//

import UIKit

class MPMeditatorView: UIView {
    private var confirmationEffectViewHeight: CGFloat = 32
    
    private var selectionViewHidden = true
    
    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var actionView: UIView!
    
    @IBOutlet weak var selectionView: UIView!
    
    @IBOutlet weak var meditationPickerView: UIPickerView!
    
    @IBOutlet weak var startButton: UIButton!
    
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var confirmationEffectView: UIVisualEffectView!
    
    @IBOutlet weak var meditationTimerLabel: UILabel!
    
    @IBOutlet weak var selectionViewTopConstraint: NSLayoutConstraint! {
        didSet {
            self.originalSelectionViewTopConstant = -self.selectionView.frame.size.height + self.confirmationEffectViewHeight
            self.selectionViewTopConstraint.constant = self.originalSelectionViewTopConstant
        }
    }
    
    var isSelectionViewHidden: Bool {
        return self.selectionViewHidden
    }
    
    var originalSelectionViewTopConstant: CGFloat = 0
    
    var refreshControl: UIRefreshControl!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.tableView.registerNib(UINib(nibName: "MPMeditatorCell", bundle: nil), forCellReuseIdentifier: MPMeditatorDataSource.MPMeditatorCellIdentifier)
        self.tableView.contentInset = UIEdgeInsetsMake(CGRectGetHeight(self.actionView.frame), 0.0, 15.0, 0.0)
        
        self.profileImageView.setImageWithURL(NSURL(string: "http://3.bp.blogspot.com/_HtW_SPtpj0c/TLFVC8kb3yI/AAAAAAAAAGM/AAzGYbO6gP4/s1600/Buddha%5B1%5D.jpg")!)
        self.profileImageView.clipsToBounds       = true
        self.profileImageView.layer.borderColor   = UIColor.whiteColor().colorWithAlphaComponent(0.8).CGColor
        self.profileImageView.layer.borderWidth   = 5
        self.profileImageView.layer.masksToBounds = true

        
        self.refreshControl = UIRefreshControl()
        self.tableView.addSubview(self.refreshControl)
    }

    func setSelectionViewHidden(hidden: Bool, animated: Bool) {
        self.startButton.setTitle(hidden ? "stop" : "start", forState: UIControlState.Normal)
        self.selectionViewHidden = hidden
        
        let duration       = animated ? 0.5 : 0.0
        let curConstant    = self.selectionViewTopConstraint.constant
        let downedConstant = self.confirmationEffectViewHeight - 20 - self.confirmationEffectViewHeight
        
        self.selectionViewTopConstraint.constant = hidden ? self.originalSelectionViewTopConstant : downedConstant
        
        UIView.animateWithDuration(duration, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 9.8, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
            self.layoutIfNeeded()
        }, completion: nil)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.profileImageView.layer.cornerRadius  = self.profileImageView.bounds.size.height / 2.0
    }
    
}
