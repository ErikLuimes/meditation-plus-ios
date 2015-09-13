//
//  MPMeditatorListViewController.swift
//  MeditationPlus
//
//  Created by Erik Luimes on 08/09/15.
//  Copyright © 2015 Maya Interactive. All rights reserved.
//

import UIKit

class MPMeditatorListViewController: UIViewController, UITableViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    private var meditatorView: MPMeditatorView { return self.view as! MPMeditatorView }

    private let meditatorManager    = MPMeditatorManager()
    private let meditatorDataSource = MPMeditatorDataSource()

    var times = [Int]()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.meditatorView.tableView.delegate   = self
        self.meditatorView.tableView.dataSource = self.meditatorDataSource
        self.meditatorView.refreshControl.addTarget(self, action: "refreshMeditators:", forControlEvents: UIControlEvents.ValueChanged)
        
        self.meditatorView.meditationPickerView.dataSource = self
        self.meditatorView.meditationPickerView.delegate   = self

        self.meditatorManager.meditatorList(failure: { (error) -> Void in
            NSLog("error: \(error)")
        }) { (meditators) -> Void in
            self.meditatorDataSource.updateMeditators(meditators)
            self.meditatorView.tableView.reloadData()
        }

        for i in 0...1440 {
            if i < 120 && i % 5 == 0 {
                times.append(i)
            } else if i >= 120 && i < 240 && i % 15 == 0{
                times.append(i)
            } else if i >= 240 && i < 480 && i % 30 == 0{
                times.append(i)
            } else if i >= 480 && i % 60 == 0{
                times.append(i)
            }
        }
//        self.view.backgroundColor = UIColor.orangeColor()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.meditatorView.setSelectionViewHidden(false, animated: true)
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

    @IBAction func didPressStartMeditationButton(sender: UIButton) {
    }

    // returns the number of 'columns' to display.
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 2
    }
    
    // returns the # of rows in each component..
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.times.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        var title = ""
        
        if row == 0 {
            title = component == 0 ? "Sitting" : "Walking"
        } else {
            var hours   = times[row] / 60
            var minutes = times[row] % 60
            title = String(format: "%d:%2.2d" , hours ,minutes)
        }
        
        return title
    }

    func toggleSelectionView() {
        self.meditatorView.setSelectionViewHidden(!self.meditatorView.isSelectionViewHidden, animated: true)
    }


}
