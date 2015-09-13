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

    private let timeInterval: NSTimeInterval = 1
    private var meditationTimer: NSTimer?
    private var remainingMeditationTime: NSTimeInterval = 0
    
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

        self.meditatorView.setSelectionViewHidden(false, animated: true)
//        self.view.backgroundColor = UIColor.orangeColor()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
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
        self.meditationTimer?.invalidate()
        
        if self.meditatorView.isSelectionViewHidden {
            self.remainingMeditationTime = 0
            self.updateRemainingTimeLabel()
            self.meditatorView.setSelectionViewHidden(false, animated: true)
            
        } else {
            // Start
            let selectedWalkingMeditationTime = self.meditatorView.meditationPickerView.selectedRowInComponent(0)
            let selectedSittingMeditationTime = self.meditatorView.meditationPickerView.selectedRowInComponent(1)
            var totalTime = 0
            
            if selectedSittingMeditationTime > 0 {
                totalTime += self.times[selectedSittingMeditationTime]
            }
            
            if selectedWalkingMeditationTime > 0 {
                totalTime += self.times[selectedWalkingMeditationTime]
            }
            
            if totalTime != 0 {
                self.remainingMeditationTime = Double(totalTime * 60)
                
                self.meditationTimer = NSTimer.scheduledTimerWithTimeInterval(self.timeInterval, target: self, selector: "meditationTimerTick", userInfo: nil, repeats: true)
                self.updateRemainingTimeLabel()
                self.meditatorView.setSelectionViewHidden(true, animated: true)
            }
        }
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
    
    func meditationTimerTick() {
        self.remainingMeditationTime -= self.timeInterval
        
        self.updateRemainingTimeLabel()
    }
    
    private func updateRemainingTimeLabel() {
        if self.remainingMeditationTime <= 0 {
            self.meditationTimer?.invalidate()
            self.meditatorView.meditationTimerLabel.text = "00:00:00"
            self.remainingMeditationTime = 0
            self.meditatorView.setSelectionViewHidden(true, animated: true)
        } else {
            var seconds = self.remainingMeditationTime % 60;
            var hours   = self.remainingMeditationTime / 3600
            var minutes = self.remainingMeditationTime / 60 % 60
            self.meditatorView.meditationTimerLabel.text = String(format: "%2.2d:%2.2d:%2.2d" , Int(hours) , Int(minutes), Int(seconds))
        }
    }

}
