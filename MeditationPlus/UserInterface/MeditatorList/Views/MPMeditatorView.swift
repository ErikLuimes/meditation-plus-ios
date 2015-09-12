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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
//        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: MPMeditatorDataSource.MPMeditatorCellIdentifier)
        self.tableView.registerNib(UINib(nibName: "MPMeditatorCell", bundle: nil), forCellReuseIdentifier: MPMeditatorDataSource.MPMeditatorCellIdentifier)
    }

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
