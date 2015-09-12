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
    
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
}
