//
//  MPMeditatorListViewController.swift
//  MeditationPlus
//
//  Created by Erik Luimes on 08/09/15.
//  Copyright © 2015 Maya Interactive. All rights reserved.
//

import UIKit
class MPMeditatorListViewController: UIViewController {
    private var meditatorView: MPMeditatorView { return view as! MPMeditatorView }

    private let timer = MPMeditationTimer.sharedInstance

    private let meditatorManager    = MPMeditatorManager()
    private let meditatorDataSource = MPMeditatorDataSource()

    private let timerDataSource = MPTimerDataSource()
    
    private var meditationProgressUpdateTimer: NSTimer?


    // Current meditation times
    private var sittingTimeInMinutes: Int?
    
    private var walkingTimeInMinutes: Int?
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        tabBarItem = UITabBarItem(title: "Meditate", image: UIImage(named: "BuddhaIcon"), tag: 0)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        timer.addDelegate(self)
        
        meditatorView.tableView.delegate   = self
        meditatorView.tableView.dataSource = meditatorDataSource
        meditatorView.refreshControl.addTarget(self, action: "refreshMeditators:", forControlEvents: UIControlEvents.ValueChanged)
        
        meditatorView.meditationPickerView.dataSource = timerDataSource
        meditatorView.meditationPickerView.delegate   = self

        meditatorView.setSelectionViewHidden(false, animated: true)
        
        meditationProgressUpdateTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "meditationProgressTimerTick", userInfo: nil, repeats: true)
        NSRunLoop.mainRunLoop().addTimer(meditationProgressUpdateTimer!, forMode:NSRunLoopCommonModes)
        
        meditatorManager.meditatorList { (meditators) -> Void in
            self.meditatorDataSource.updateMeditators(meditators)
            self.meditatorView.tableView.reloadData()
        }
    }
    
    func refreshMeditators(refreshControl: UIRefreshControl) {
        meditatorManager.meditatorList { (meditators) -> Void in
            refreshControl.endRefreshing()
            self.meditatorDataSource.updateMeditators(meditators)
            self.meditatorView.tableView.reloadData()
        }
    }
    
//    override func viewWillAppear(animated: Bool) {
//        super.viewWillAppear(animated)
//        
//        meditationProgressUpdateTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "meditationProgressTimerTick", userInfo: nil, repeats: true)
//
//        meditatorManager.meditatorList { (meditators) -> Void in
//            self.meditatorDataSource.updateMeditators(meditators)
//            self.meditatorView.tableView.reloadData()
//        }
//    }
//    
//    override func viewWillDisappear(animated: Bool) {
//        super.viewWillDisappear(animated)
//        
//        meditationProgressUpdateTimer?.invalidate()
//        meditationProgressUpdateTimer = nil
//    }
    
    func meditationProgressTimerTick()
    {
        NSLog("tick")
        for cell in meditatorView.tableView.visibleCells where cell is MPMeditatorCell
        {
            (cell as! MPMeditatorCell).updateProgressIndicatorIfNeeded()
        }
    }
    
    // MARK: Actions
    
    @IBAction func didPressStartMeditationButton(sender: UIButton) {
        if timer.state == .Stopped {
            let selectedWalkingMeditationTime = meditatorView.meditationPickerView.selectedRowInComponent(0)
            let selectedSittingMeditationTime = meditatorView.meditationPickerView.selectedRowInComponent(2)
            var totalTime                     = 0

            walkingTimeInMinutes = nil
            sittingTimeInMinutes = nil

            if selectedSittingMeditationTime > 0 {
                sittingTimeInMinutes = timerDataSource.times[selectedSittingMeditationTime]
                totalTime += sittingTimeInMinutes!
            }

            if selectedWalkingMeditationTime > 0 {
                walkingTimeInMinutes = timerDataSource.times[selectedWalkingMeditationTime]
                totalTime += walkingTimeInMinutes!
            }

            if totalTime != 0 {
                timer.startTimer(mditationTimeInMinutes: Double(totalTime), preparationTime: 10)
            }
            
        } else {
            timer.cancelTimer()
        }
    }


    func toggleSelectionView() {
        meditatorView.setSelectionViewHidden(!meditatorView.isSelectionViewHidden, animated: true)
    }

}

extension MPMeditatorListViewController: UITableViewDelegate
{
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let headerView = view as! UITableViewHeaderFooterView
        headerView.textLabel?.text          = meditatorDataSource.meditatorSections[section].title
        headerView.textLabel?.textColor     = UIColor.darkGrayColor()
        headerView.tintColor                = UIColor.whiteColor()
    }
}

extension MPMeditatorListViewController: UIPickerViewDelegate
{
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView?) -> UIView {
        var label: UILabel!
        var title = ""
        
        if view is UILabel {
            label = view as! UILabel
        } else {
            label               = UILabel()
            label.textAlignment = .Left
        }
        
        if component == 0 || component == 2 {
            let hours   = timerDataSource.times[row] / 60
            let minutes = timerDataSource.times[row] % 60
            title       = String(format: "%d:%2.2d" , hours ,minutes)
        } else if component == 1 {
            title = "Walking"
        } else if component == 3 {
            title = "Sitting"
        }
        
        
        label.text = title
        
        return label
    }
    
    func pickerView(pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        var width: CGFloat = 0
        
        if component == 0 || component == 2 {
            width = 40
        } else {
            width = 70
        }
        
        return width
    }
    
}

extension MPMeditatorListViewController: MPMeditationTimerDelegate
{
    // MARK: MPMeditationTimerDelegate


    func meditationTimer(meditationTimer: MPMeditationTimer, didStartWithState state: MPMeditationState)
    {
        NSLog("start state: \(state.title)")
        if state == MPMeditationState.Preparation {
            meditatorView.setSelectionViewHidden(true, animated: true)
        } else if state == .Meditation {
//                meditatorManager.startMeditation(sittingTimeInMinutes, walkingTimeInMinutes: walkingTimeInMinutes, completion: { () -> Void in
//                    //
//                    NSLog("Did start")
//                }, failure: { (error) -> Void in
//                    NSLog("Start meditation failed")
//                    //
//                })
            
        }
    }

    func meditationTimer(meditationTimer: MPMeditationTimer, didProgress progress: Double, withState state: MPMeditationState, timeLeft: NSTimeInterval)
    {
        NSLog("progress state: \(state.title), progress: \(progress), timeLeft: \(timeLeft)")
        
        if state == MPMeditationState.Preparation {
            meditatorView.preparationProgressView.setProgress(Float(1.0 - progress), animated: true)
        } else if state == MPMeditationState.Meditation {
            let seconds = timeLeft % 60;
            let hours   = timeLeft / 3600
            let minutes = timeLeft / 60 % 60
            meditatorView.meditationTimerLabel.text = String(format: "%2.2d:%2.2d:%2.2d" , Int(hours) , Int(minutes), Int(seconds))
        }
    }

    func meditationTimer(meditationTimer: MPMeditationTimer, didStopWithState state: MPMeditationState)
    {
        NSLog("stop state: \(state.title)")
        
        if state == MPMeditationState.Meditation {
            meditatorView.setSelectionViewHidden(false, animated: true)
        }
    }
    
    func meditationTimerWasCancelled(meditationTimer: MPMeditationTimer)
    {
        sittingTimeInMinutes = nil
        walkingTimeInMinutes = nil
        
        meditatorView.setSelectionViewHidden(false, animated: true)
        
//            meditatorManager.cancelMeditation(sittingTimeInMinutes, walkingTimeInMinutes: walkingTimeInMinutes, completion: { () -> Void in
//                //
//                NSLog("Did cancel")
//            }, failure: { (error) -> Void in
//                NSLog("Cancel meditation failed")
//                //
//            })
    }
    
}
