//
//  MeditatorListViewController.swift
//  MeditationPlus
//
//  Created by Erik Luimes on 08/09/15.
//
//  The MIT License
//  Copyright (c) 2015 Maya Interactive. All rights reserved.
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
//
// Except as contained in this notice, the name of Maya Interactive and Meditation+
// shall not be used in advertising or otherwise to promote the sale, use or other
// dealings in this Software without prior written authorization from Maya Interactive.
//

import UIKit
import DZNEmptyDataSet
import RealmSwift
import CocoaLumberjack

class MeditatorListViewController: UIViewController
{
    private var meditatorView: MeditatorView
    {
        return view as! MeditatorView
    }
    
    // MARK: Service content providers
    
    private var meditatorDataSource: MeditatorDataSource?
    
    private var meditatorContentProvider: MeditatorContentProvider!
    
    private let meditatorService: MeditatorService = MeditatorService()
    
    private let profileService: ProfileService = ProfileService.sharedInstance
    
    private let authenticationManager: AuthenticationManager = AuthenticationManager.sharedInstance
    
    // MARK: Timing methods
    
    private var meditationProgressUpdateTimer: NSTimer?
    
    private let timer = MeditationTimer.sharedInstance

    private let timerDataSource = TimerDataSource()
    
    private var meditatorListUpdateTimer: NSTimer?

    // Current meditation times
    
    private var sittingTimeInMinutes: Int?

    private var walkingTimeInMinutes: Int?
    
    
    // MARK: Init
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?)
    {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

        tabBarItem = UITabBarItem(title: nil, image: R.image.buddhaIcon(), tag: 0)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MeditatorListViewController.willEnterForeground(_:)), name: UIApplicationWillEnterForegroundNotification, object: nil)
        
        meditatorContentProvider = MeditatorContentProvider(meditatorService: meditatorService)
    }

    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }

    deinit
    {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: View life cycle

    override func viewDidLoad()
    {
        super.viewDidLoad()

        meditatorView.tableView.delegate             = self
        meditatorView.tableView.emptyDataSetSource   = self
        meditatorView.tableView.emptyDataSetDelegate = self
        meditatorView.refreshControl.addTarget(self, action: #selector(MeditatorListViewController.refreshMeditators), forControlEvents: UIControlEvents.ValueChanged)

        meditatorView.meditationPickerView.dataSource = timerDataSource
        meditatorView.meditationPickerView.delegate   = self

        if timer.state != .Stopped {
            timer.cancelTimer()
        }

        meditatorView.setSelectionViewHidden(false, animated: true)

        meditatorView.meditationPickerView.selectRow(NSUserDefaults.standardUserDefaults().integerForKey("walkingMeditationTimeId"), inComponent: 0, animated: true)
        meditatorView.meditationPickerView.selectRow(NSUserDefaults.standardUserDefaults().integerForKey("sittingMeditationTimeId"), inComponent: 2, animated: true)
        
        registerForPreviewingWithDelegate(self, sourceView: meditatorView.tableView)
        
        setupMeditatorContentProvider()
        
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)

        UIApplication.sharedApplication().registerUserNotificationSettings(UIUserNotificationSettings(forTypes: [UIUserNotificationType.Alert, UIUserNotificationType.Badge, UIUserNotificationType.Sound], categories: nil))
        
        if let username = self.authenticationManager.loggedInUser?.username, profile = profileService.profile(username).first {
            meditatorView.configureWithProfile(profile)
        }

        timer.addDelegate(self)

        if timer.state == .Meditation {
            meditatorView.setSelectionViewHidden(true, animated: true)
        } else if timer.state == .Preparation {
            meditatorView.setSelectionViewHidden(true, animated: true)
        } else {
            meditatorView.setSelectionViewHidden(false, animated: true)
        }

        meditationProgressUpdateTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(MeditatorListViewController.meditationProgressTimerTick), userInfo: nil, repeats: true)
        NSRunLoop.mainRunLoop().addTimer(meditationProgressUpdateTimer!, forMode: NSRunLoopCommonModes)

        meditatorContentProvider.fetchContentIfNeeded()
        
        startMeditatorListUpdateTimer()
    }

    override func viewWillDisappear(animated: Bool)
    {
        super.viewWillDisappear(animated)

        timer.removeDelegate(self)

        meditationProgressUpdateTimer?.invalidate()
        meditationProgressUpdateTimer = nil
        
        meditatorContentProvider.disableNotification()
        stopMeditatorListUpdateTimer()
    }
    
    // MARK: Data handling
    
    private func setupMeditatorContentProvider()
    {
        meditatorContentProvider.resultsBlock = {
            (results: Results<Meditator>) in
            
            if self.meditatorDataSource == nil {
                self.meditatorDataSource = MeditatorDataSource(results: results)
                self.meditatorView.tableView.dataSource = self.meditatorDataSource
            }
        }
        
        meditatorContentProvider.notificationBlock = {
            (changes:  RealmCollectionChange<Results<Meditator>>) in
            
            self.meditatorView.refreshControl.endRefreshing()

            switch changes {
            case .Initial(_):
                self.meditatorDataSource?.updateSections()
                self.meditatorView.tableView.reloadData()
            case .Update(_,_,_,_):
                self.meditatorDataSource?.update(self.meditatorView.tableView)
                
                for cell in self.meditatorView.tableView.visibleCells where cell is MeditatorCell
                {
                    (cell as! MeditatorCell).updateProgressIndicatorIfNeeded()
                }
            case .Error(let error):
                DDLogError(error.localizedDescription)
            }
        }
    }
    
    func refreshMeditators()
    {
        meditatorContentProvider.fetchContentIfNeeded(forceReload: true)
    }
    
    func meditationProgressTimerTick()
    {
        meditatorDataSource?.checkMeditatorProgress(meditatorView.tableView)
        for cell in meditatorView.tableView.visibleCells where cell is MeditatorCell
        {
            (cell as! MeditatorCell).updateProgressIndicatorIfNeeded()
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

            var meditationTimes: [MeditationSession] = [MeditationSession]()

            if selectedWalkingMeditationTime > 0 {
                walkingTimeInMinutes = timerDataSource.times[selectedWalkingMeditationTime]
                totalTime += walkingTimeInMinutes!
                meditationTimes.append(MeditationSession(type: .Walking, time: Double(walkingTimeInMinutes!) * 60.0))
            }

            if selectedSittingMeditationTime > 0 {
                sittingTimeInMinutes = timerDataSource.times[selectedSittingMeditationTime]
                totalTime += sittingTimeInMinutes!
                meditationTimes.append(MeditationSession(type: .Sitting, time: Double(sittingTimeInMinutes!) * 60.0))
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

// MARK: - UITableViewDelegate

extension MeditatorListViewController: UITableViewDelegate
{
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

    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath?
    {
        return nil
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        if let meditator = self.meditatorDataSource?.meditatorForIndexPath(indexPath) {
            let viewController = ProfileViewController(
                nib: R.nib.profileView,
                username: meditator.username,
                profileContentProvider: ProfileContentProvider(profileService: ProfileService.sharedInstance)
            )
            
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if let meditator = self.meditatorDataSource?.meditatorForIndexPath(indexPath), meditatorCell = cell as? MeditatorCell {
            meditatorCell.configureWithMeditator(meditator, displayProgress: indexPath.section == 0)
        }
        (cell as? MeditatorCell)?.delegate = self
    }
    
    func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        (cell as? MeditatorCell)?.delegate = nil
    }
}

// MARK: - UIPickerViewDelegate

extension MeditatorListViewController: UIPickerViewDelegate
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

// MARK: - MeditationTimerDelegate

extension MeditatorListViewController: MeditationTimerDelegate
{

    func meditationTimer(meditationTimer: MeditationTimer, didStartWithState state: MeditationState)
    {
        if state == MeditationState.Preparation {
            meditatorView.setSelectionViewHidden(true, animated: true)
        } else if state == MeditationState.Meditation {
            meditatorService.startMeditation(sittingTimeInMinutes, walkingTimeInMinutes: walkingTimeInMinutes)
        }
    }

    func meditationTimer(meditationTimer: MeditationTimer, didProgress progress: Double, withState state: MeditationState, timeLeft: NSTimeInterval)
    {
        if state == MeditationState.Preparation {
            meditatorView.preparationProgressView.setProgress(Float(1.0 - progress), animated: true)
        } else if state == MeditationState.Meditation {
            meditatorView.preparationProgressView.setProgress(0.0, animated: false)
            let seconds = timeLeft % 60;
            let hours = timeLeft / 3600
            let minutes = timeLeft / 60 % 60
            meditatorView.meditationTimerLabel.text = String(format: "%2.2d:%2.2d:%2.2d", Int(hours), Int(minutes), Int(seconds))
        }
    }

    func meditationTimer(meditationTimer: MeditationTimer, withState state: MeditationState, type: MeditationType, progress: Double, timeLeft: NSTimeInterval, totalProgress: Double, totalTimeLeft: NSTimeInterval)
    {
        if state == MeditationState.Preparation {
            meditatorView.preparationProgressView.setProgress(Float(1.0 - totalProgress), animated: true)
        } else if state == MeditationState.Meditation {
            meditatorView.preparationProgressView.setProgress(0.0, animated: false)
            let seconds = totalTimeLeft % 60;
            let hours = totalTimeLeft / 3600
            let minutes = totalTimeLeft / 60 % 60
            meditatorView.meditationTimerLabel.text = String(format: "%2.2d:%2.2d:%2.2d", Int(hours), Int(minutes), Int(seconds))
        }
    }

    func meditationTimer(meditationTimer: MeditationTimer, didChangeMeditationFromType fromType: MeditationType, toType: MeditationType)
    {
    }

    func meditationTimer(meditationTimer: MeditationTimer, didStopWithState state: MeditationState)
    {
        if state == MeditationState.Meditation {
            meditatorView.setSelectionViewHidden(false, animated: true)
        }
    }

    func meditationTimerWasCancelled(meditationTimer: MeditationTimer)
    {
        sittingTimeInMinutes = nil
        walkingTimeInMinutes = nil

        meditatorView.setSelectionViewHidden(false, animated: true)
        meditatorService.cancelMeditation(sittingTimeInMinutes, walkingTimeInMinutes: walkingTimeInMinutes)
    }
}

// MARK: - DZNEmptyDataSet

extension MeditatorListViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate
{

    func imageForEmptyDataSet(scrollView: UIScrollView!) -> UIImage!
    {
        return R.image.buddhaIcon()
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

// MARK: - UIViewControllerPreviewingDelegate

extension MeditatorListViewController: UIViewControllerPreviewingDelegate
{
    func previewingContext(previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController?
    {
        var viewController: UIViewController?
        
        if let indexPath = meditatorView.tableView.indexPathForRowAtPoint(location) {
            if let meditator = self.meditatorDataSource?.meditatorForIndexPath(indexPath) {
                previewingContext.sourceRect = meditatorView.tableView.rectForRowAtIndexPath(indexPath)
                viewController               = ProfileViewController(
                    nib: R.nib.profileView,
                    username: meditator.username,
                    profileContentProvider: ProfileContentProvider(profileService: ProfileService.sharedInstance)
                )
            }
        }
        
        return viewController
    }
    
    func previewingContext(previewingContext: UIViewControllerPreviewing, commitViewController viewControllerToCommit: UIViewController)
    {
        navigationController?.pushViewController(viewControllerToCommit, animated: true)
    }
}

extension MeditatorListViewController: MeditatorCellDelegate
{
    func cell(cell: MeditatorCell, didTapInfoButton button: UIButton)
    {
        guard let indexPath = self.meditatorView.tableView.indexPathForCell(cell) else {
            return
        }
        
        if let meditator = self.meditatorDataSource?.meditatorForIndexPath(indexPath)
        {
            let viewController = ProfileViewController(
                nib: R.nib.profileView,
                username: meditator.username,
                profileContentProvider: ProfileContentProvider(profileService: ProfileService.sharedInstance)
            )
            
            navigationController?.pushViewController(viewController, animated: true)
        }
    }
}

// MARK: - Timer handling

extension MeditatorListViewController
{
    
    private func startMeditatorListUpdateTimer()
    {
        meditatorListUpdateTimer?.invalidate()
        meditatorListUpdateTimer = NSTimer.scheduledTimerWithTimeInterval(360, target: self, selector: #selector(MeditatorListViewController.refreshMeditators), userInfo: nil, repeats: true)
        NSRunLoop.mainRunLoop().addTimer(meditatorListUpdateTimer!, forMode: NSRunLoopCommonModes)
    }
    
    private func stopMeditatorListUpdateTimer()
    {
        meditatorListUpdateTimer?.invalidate()
        meditatorListUpdateTimer = nil
    }
}