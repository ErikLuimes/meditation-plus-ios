//
//  MPMeditatorListViewController.swift
//  MeditationPlus
//
//  Created by Erik Luimes on 08/09/15.
//  Copyright © 2015 Maya Interactive. All rights reserved.
//

import UIKit

class MPMeditatorListViewController: UIViewController, UITableViewDelegate {
    private var meditatorView: MPMeditatorView { return self.view as! MPMeditatorView }

    private let meditatorManager    = MPMeditatorManager()
    private let meditatorDataSource = MPMeditatorDataSource()


    override func viewDidLoad() {
        super.viewDidLoad()

        self.meditatorView.tableView.delegate   = self
        self.meditatorView.tableView.dataSource = self.meditatorDataSource
        self.meditatorView.refreshControl.addTarget(self, action: "refreshMeditators:", forControlEvents: UIControlEvents.ValueChanged)

        self.meditatorManager.meditatorList(failure: { (error) -> Void in
            NSLog("error: \(error)")
        }) { (meditators) -> Void in
            self.meditatorDataSource.updateMeditators(meditators)
            self.meditatorView.tableView.reloadData()
        }
//        self.view.backgroundColor = UIColor.orangeColor()
        // Do any additional setup after loading the view.
    }
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80
    }
    
    // MARK: Actions
    
    func refreshMeditators(refreshControl: UIRefreshControl) {
        self.meditatorManager.meditatorList(failure: { (error) -> Void in
            NSLog("error: \(error)")
            refreshControl.endRefreshing()
        }) { (meditators) -> Void in
            self.meditatorDataSource.updateMeditators(meditators)
            self.meditatorView.tableView.reloadData()
            refreshControl.endRefreshing()
        }
        
    }
    
    
}
