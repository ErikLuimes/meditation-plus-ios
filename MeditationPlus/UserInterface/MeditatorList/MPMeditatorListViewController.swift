//
//  MPMeditatorListViewController.swift
//  MeditationPlus
//
//  Created by Erik Luimes on 08/09/15.
//  Copyright © 2015 Maya Interactive.
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
import DZNEmptyDataSet
import RealmSwift
import CocoaLumberjack

extension RealmCollectionChange
{
    public func isSuccess() -> Bool
    {
        switch self {
        case .Initial, .Update:
            return true
        default:
            return false
        }
    }
    
    public func isFailure() -> Bool
    {
        return !isSuccess()
    }
    
    public var error: NSError? {
        if case .Error(let error) = self {
            return error
        } else {
            return nil
        }
    }
}

class MPMeditatorListViewController: UIViewController
{
    private var meditatorView: MPMeditatorView
    {
        return view as! MPMeditatorView
    }
    
    private let meditatorService: MeditatorService = MeditatorService()
    
    private var meditatorNotificationToken: NotificationToken!


    private let timer = MPMeditationTimer.sharedInstance

//    private let meditatorManager = MPMeditatorManager()
    private var meditatorDataSource: MeditatorDataSource?

    private let timerDataSource = MPTimerDataSource()

    private var meditationProgressUpdateTimer: NSTimer?


    // Current meditation times
    private var sittingTimeInMinutes: Int?

    private var walkingTimeInMinutes: Int?

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?)
    {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

        tabBarItem = UITabBarItem(title: "Meditate", image: UIImage(named: "BuddhaIcon"), tag: 0)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MPMeditatorListViewController.willEnterForeground(_:)), name: UIApplicationWillEnterForegroundNotification, object: nil)
    }

    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }

    deinit
    {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    override func viewDidLoad()
    {
        super.viewDidLoad()


        meditatorView.tableView.delegate = self
        meditatorView.tableView.emptyDataSetSource = self
        meditatorView.tableView.emptyDataSetDelegate = self
        meditatorView.refreshControl.addTarget(self, action: #selector(MPMeditatorListViewController.refreshMeditators(_:)), forControlEvents: UIControlEvents.ValueChanged)

        meditatorView.meditationPickerView.dataSource = timerDataSource
        meditatorView.meditationPickerView.delegate = self

        if timer.state != .Stopped {
            timer.cancelTimer()
        }

        meditatorView.setSelectionViewHidden(false, animated: true)

        meditatorView.meditationPickerView.selectRow(NSUserDefaults.standardUserDefaults().integerForKey("walkingMeditationTimeId"), inComponent: 0, animated: true)
        meditatorView.meditationPickerView.selectRow(NSUserDefaults.standardUserDefaults().integerForKey("sittingMeditationTimeId"), inComponent: 2, animated: true)
    }

    func refreshMeditators(refreshControl: UIRefreshControl)
    {
        meditatorService.reloadMeditatorsIfNeeded(true)
//        meditatorManager.meditatorList
//        {
//            (meditators) -> Void in
//            refreshControl.endRefreshing()
//            self.meditatorDataSource.updateMeditators(meditators)
//            self.meditatorView.tableView.reloadData()
//        }
    }

    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)

        UIApplication.sharedApplication().registerUserNotificationSettings(UIUserNotificationSettings(forTypes: [UIUserNotificationType.Alert, UIUserNotificationType.Badge, UIUserNotificationType.Sound], categories: nil))

        timer.addDelegate(self)

        if timer.state == .Meditation {
            meditatorView.setSelectionViewHidden(true, animated: true)
        } else if timer.state == .Preparation {
            meditatorView.setSelectionViewHidden(true, animated: true)
        } else {
            meditatorView.setSelectionViewHidden(false, animated: true)
        }

        meditationProgressUpdateTimer = NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: #selector(MPMeditatorListViewController.meditationProgressTimerTick), userInfo: nil, repeats: true)

        meditatorService.reloadMeditatorsIfNeeded()
        enableMeditatorNotification()
        
//        meditatorManager.meditatorList
//        {
//            (meditators) -> Void in
//            self.meditatorDataSource.updateMeditators(meditators)
//            self.meditatorView.tableView.reloadData()
//        }
    }

    override func viewWillDisappear(animated: Bool)
    {
        super.viewWillDisappear(animated)

        timer.removeDelegate(self)

        meditationProgressUpdateTimer?.invalidate()
        meditationProgressUpdateTimer = nil
        
        disableMeditatorNotification()

        
    }
    
    private func enableMeditatorNotification()
    {
        guard self.meditatorNotificationToken == nil else {
            return
        }
        
        let (meditatorNotificationToken, results) = meditatorService.meditators()
        {
            (changes: RealmCollectionChange<Results<MPMeditator>>) in
            
            
            self.meditatorView.refreshControl.endRefreshing()
            
            switch changes {
            case .Initial(_):
                self.meditatorDataSource?.updateCache()
                self.meditatorView.tableView.reloadData()
            case .Update(_ , _, _, _):
                self.meditatorDataSource?.checkMeditatorProgress(self.meditatorView.tableView)
                for cell in self.meditatorView.tableView.visibleCells where cell is MPMeditatorCell
                {
                    (cell as! MPMeditatorCell).updateProgressIndicatorIfNeeded()
                }
            case .Error(let error):
                DDLogError(error.localizedDescription)
            }
        }
        
        self.meditatorNotificationToken = meditatorNotificationToken
        
        if meditatorDataSource == nil {
            meditatorDataSource = MeditatorDataSource(results: results)
            meditatorView.tableView.dataSource = meditatorDataSource
        }
    }

    private func disableMeditatorNotification()
    {
        meditatorNotificationToken.stop()
        meditatorNotificationToken = nil
    }
    
    func meditationProgressTimerTick()
    {
        meditatorDataSource?.checkMeditatorProgress(meditatorView.tableView)
        for cell in meditatorView.tableView.visibleCells where cell is MPMeditatorCell
        {
            (cell as! MPMeditatorCell).updateProgressIndicatorIfNeeded()
        }
    }

    // MARK: Actions

    @IBAction func didPressStartMeditationButton(sender: UIButton)
    {
        if timer.state == .Stopped {
            let selectedWalkingMeditationTime = meditatorView.meditationPickerView.selectedRowInComponent(0)
            let selectedSittingMeditationTime = meditatorView.meditationPickerView.selectedRowInComponent(2)
            var totalTime = 0

            NSUserDefaults.standardUserDefaults().setInteger(selectedWalkingMeditationTime, forKey: "walkingMeditationTimeId")
            NSUserDefaults.standardUserDefaults().setInteger(selectedSittingMeditationTime, forKey: "sittingMeditationTimeId")

            walkingTimeInMinutes = nil
            sittingTimeInMinutes = nil

            var meditationTimes: [MPMeditationSession] = [MPMeditationSession]()

            if selectedWalkingMeditationTime > 0 {
                walkingTimeInMinutes = timerDataSource.times[selectedWalkingMeditationTime]
                totalTime += walkingTimeInMinutes!
                meditationTimes.append(MPMeditationSession(type: .Walking, time: Double(walkingTimeInMinutes!) * 60.0))
            }

            if selectedSittingMeditationTime > 0 {
                sittingTimeInMinutes = timerDataSource.times[selectedSittingMeditationTime]
                totalTime += sittingTimeInMinutes!
                meditationTimes.append(MPMeditationSession(type: .Sitting, time: Double(sittingTimeInMinutes!) * 60.0))
            }

            if meditationTimes.count > 0 {
                try! timer.startTimer(meditationTimes, preparationTime: 3)
            }
        } else {
            timer.cancelTimer()
        }
    }


    func toggleSelectionView()
    {
        meditatorView.setSelectionViewHidden(!meditatorView.isSelectionViewHidden, animated: true)
    }

    // MARK: Notifications

    func willEnterForeground(notification: NSNotification)
    {
        if timer.state == .Meditation {
            meditatorView.setSelectionViewHidden(true, animated: true)
        } else if timer.state == .Preparation {
            meditatorView.setSelectionViewHidden(true, animated: true)
        } else {
            meditatorView.setSelectionViewHidden(false, animated: true)
        }
    }
}

extension MPMeditatorListViewController: UITableViewDelegate
{
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        return 80
    }

    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        guard tableView.dataSource != nil else {
            return 0
        }
        
        return tableView.dataSource?.tableView(tableView, numberOfRowsInSection: section) ?? 0 > 0 ? 40 : 0
    }

    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
    {
        return 0
    }


    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        let view = UITableViewHeaderFooterView()
        view.contentView.backgroundColor = UIColor.whiteColor()
        view.textLabel?.textColor = UIColor.darkGrayColor()
        return view
    }
}

extension MPMeditatorListViewController: UIPickerViewDelegate
{
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView?) -> UIView
    {
        var label: UILabel!
        var title = ""

        if view is UILabel {
            label = view as! UILabel
        } else {
            label = UILabel()
            label.textAlignment = .Left
        }

        if component == 0 || component == 2 {
            let hours = timerDataSource.times[row] / 60
            let minutes = timerDataSource.times[row] % 60
            title = String(format: "%d:%2.2d", hours, minutes)
        } else if component == 1 {
            title = "Walking"
        } else if component == 3 {
            title = "Sitting"
        }


        label.text = title

        return label
    }

    func pickerView(pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat
    {
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
        if state == MPMeditationState.Preparation {
            meditatorView.setSelectionViewHidden(true, animated: true)
        } else if state == MPMeditationState.Meditation {
//            meditatorService.startMeditation(sittingTimeInMinutes, walkingTimeInMinutes: walkingTimeInMinutes)
//            {
//                (response) -> Void in
//                
//                if response.isSuccess() {
//                    self.meditatorService.reloadMeditatorsIfNeeded(true)
//                }
//            }
        }
    }

    func meditationTimer(meditationTimer: MPMeditationTimer, didProgress progress: Double, withState state: MPMeditationState, timeLeft: NSTimeInterval)
    {
        if state == MPMeditationState.Preparation {
            meditatorView.preparationProgressView.setProgress(Float(1.0 - progress), animated: true)
        } else if state == MPMeditationState.Meditation {
            meditatorView.preparationProgressView.setProgress(0.0, animated: false)
            let seconds = timeLeft % 60;
            let hours = timeLeft / 3600
            let minutes = timeLeft / 60 % 60
            meditatorView.meditationTimerLabel.text = String(format: "%2.2d:%2.2d:%2.2d", Int(hours), Int(minutes), Int(seconds))
        }
    }

    func meditationTimer(meditationTimer: MPMeditationTimer, withState state: MPMeditationState, type: MPMeditationType, progress: Double, timeLeft: NSTimeInterval, totalProgress: Double, totalTimeLeft: NSTimeInterval)
    {
        if state == MPMeditationState.Preparation {
            meditatorView.preparationProgressView.setProgress(Float(1.0 - totalProgress), animated: true)
        } else if state == MPMeditationState.Meditation {
            meditatorView.preparationProgressView.setProgress(0.0, animated: false)
            let seconds = totalTimeLeft % 60;
            let hours = totalTimeLeft / 3600
            let minutes = totalTimeLeft / 60 % 60
            meditatorView.meditationTimerLabel.text = String(format: "%2.2d:%2.2d:%2.2d", Int(hours), Int(minutes), Int(seconds))
        }

//        NSLog("type: \(type), progress: \(progress), timeLeft: \(timeLeft), totalTimeLeft: \(totalTimeLeft)")
    }

    func meditationTimer(meditationTimer: MPMeditationTimer, didChangeMeditationFromType fromType: MPMeditationType, toType: MPMeditationType)
    {
//        NSLog("didChange meditation type")
    }

    func meditationTimer(meditationTimer: MPMeditationTimer, didStopWithState state: MPMeditationState)
    {
        if state == MPMeditationState.Meditation {
            meditatorView.setSelectionViewHidden(false, animated: true)
        }
    }

    func meditationTimerWasCancelled(meditationTimer: MPMeditationTimer)
    {
        sittingTimeInMinutes = nil
        walkingTimeInMinutes = nil

        meditatorView.setSelectionViewHidden(false, animated: true)
//        meditatorService.cancelMeditation(sittingTimeInMinutes, walkingTimeInMinutes: walkingTimeInMinutes)
//        {
//            (response) -> Void in
//            
//            if response.isSuccess() {
//                self.meditatorService.reloadMeditatorsIfNeeded(true)
//            }
//        }
    }
}


extension MPMeditatorListViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate
{
    // MARK: DZNEmptyDataSetDelegate

    func imageForEmptyDataSet(scrollView: UIScrollView!) -> UIImage!
    {
        return UIImage(named: "BuddhaIcon")
    }

    func imageAnimationForEmptyDataSet(scrollView: UIScrollView!) -> CAAnimation!
    {
        let animation = CABasicAnimation(keyPath: "transform")

        animation.fromValue = NSValue(CATransform3D: CATransform3DIdentity)
        animation.toValue = NSValue(CATransform3D: CATransform3DMakeRotation(CGFloat(M_PI_2), 0.0, 1.0, 0.0))
        animation.duration = 0.75
        animation.cumulative = true
        animation.repeatCount = 1000

        return animation
    }

    func emptyDataSetShouldAnimateImageView(scrollView: UIScrollView!) -> Bool
    {
        return true
    }
}
