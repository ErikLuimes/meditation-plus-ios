//
//  MPMeditatorListViewController.swift
//  MeditationPlus
//
//  Created by Erik Luimes on 08/09/15.
//  Copyright © 2015 Maya Interactive. All rights reserved.
//

import UIKit
class MPMeditatorListViewController: UIViewController, UITableViewDelegate, UIPickerViewDelegate, MPMeditationTimerDelegate {
    private var meditatorView: MPMeditatorView { return view as! MPMeditatorView }

    private let timer = MPMeditationTimer.sharedInstance

    private let meditatorManager    = MPMeditatorManager()
    private let meditatorDataSource = MPMeditatorDataSource()

    private let timerDataSource = MPTimerDataSource()


    // Current meditation times
    private var sittingTimeInMinutes: Int?
    
    private var walkingTimeInMinutes: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        timer.addDelegate(self)

        meditatorView.tableView.delegate   = self
        meditatorView.tableView.dataSource = meditatorDataSource
        meditatorView.refreshControl.addTarget(self, action: "refreshMeditators:", forControlEvents: UIControlEvents.ValueChanged)
        
        meditatorView.meditationPickerView.dataSource = timerDataSource
        meditatorView.meditationPickerView.delegate   = self

        meditatorView.setSelectionViewHidden(false, animated: true)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80
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

    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        var title = ""
        
        if row == 0 && (component == 1 || component == 3) {
            title = component == 1 ? "Walking" : "Sitting"
        } else {
            let hours   = timerDataSource.times[row] / 60
            let minutes = timerDataSource.times[row] % 60
            title = String(format: "%d:%2.2d" , hours ,minutes)
        }
        
        return title
    }

    func toggleSelectionView() {
        meditatorView.setSelectionViewHidden(!meditatorView.isSelectionViewHidden, animated: true)
    }

    // MARK: MPMeditationTimerDelegate: NSObjectProtocol {


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
