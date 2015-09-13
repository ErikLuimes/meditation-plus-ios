//
//  MPMeditatorView.swift
//  MeditationPlus
//
//  Created by Erik Luimes on 12/09/15.
//  Copyright (c) 2015 Maya Interactive. All rights reserved.
//

import UIKit

class MPMeditatorView: UIView {
    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var actionView: UIView!
    
    @IBOutlet weak var meditationPickerView: UIPickerView!
    
    @IBOutlet weak var startButton: UIButton!
    
    @IBOutlet weak var profileImageView: UIImageView!
    var refreshControl: UIRefreshControl!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.tableView.registerNib(UINib(nibName: "MPMeditatorCell", bundle: nil), forCellReuseIdentifier: MPMeditatorDataSource.MPMeditatorCellIdentifier)
        self.tableView.contentInset = UIEdgeInsetsMake(CGRectGetHeight(self.actionView.frame), 0.0, 15.0, 0.0)
        
        self.profileImageView.setImageWithURL(NSURL(string: "http://3.bp.blogspot.com/_HtW_SPtpj0c/TLFVC8kb3yI/AAAAAAAAAGM/AAzGYbO6gP4/s1600/Buddha%5B1%5D.jpg")!)
        self.refreshControl = UIRefreshControl()
        self.tableView.addSubview(self.refreshControl)
    }
}
