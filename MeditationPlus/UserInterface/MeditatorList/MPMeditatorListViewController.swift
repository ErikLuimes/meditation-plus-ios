//
//  MPMeditatorListViewController.swift
//  MeditationPlus
//
//  Created by Erik Luimes on 08/09/15.
//  Copyright © 2015 Maya Interactive. All rights reserved.
//

import UIKit
class MPMeditatorListViewController: UIViewController, UITableViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate, MPMeditationTimerDelegate {
    private var meditatorView: MPMeditatorView { return self.view as! MPMeditatorView }

    private let timer = MPMeditationTimer.sharedInstance

    private let meditatorManager    = MPMeditatorManager()
    private let meditatorDataSource = MPMeditatorDataSource()

    var times = [Int]()

    // Current meditation times
    private var sittingTimeInMinutes: Int?
    
    private var walkingTimeInMinutes: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.timer.addDelegate(self)

        self.meditatorView.tableView.delegate   = self
        self.meditatorView.tableView.dataSource = self.meditatorDataSource
        self.meditatorView.refreshControl.addTarget(self, action: "refreshMeditators:", forControlEvents: UIControlEvents.ValueChanged)
        
        self.meditatorView.meditationPickerView.dataSource = self
        self.meditatorView.meditationPickerView.delegate   = self

//        self.meditatorManager.meditatorList({ (error) -> Void in
//            NSLog("error: \(error)")
//        }) { (meditators) -> Void in
//            self.meditatorDataSource.updateMeditators(meditators)
//            self.meditatorView.tableView.reloadData()
//        }

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
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80
    }
    
    // MARK: Actions
    
    func refreshMeditators(refreshControl: UIRefreshControl) {
//        self.meditatorManager.meditatorList({ (error) -> Void in
//            NSLog("error: \(error)")
//            refreshControl.endRefreshing()
//        }) { (meditators) -> Void in
//            self.meditatorDataSource.updateMeditators(meditators)
//            self.meditatorView.tableView.reloadData()
//            refreshControl.endRefreshing()
//        }
    }

    @IBAction func didPressStartMeditationButton(sender: UIButton) {
        if self.timer.state == .Stopped {
            let selectedWalkingMeditationTime = self.meditatorView.meditationPickerView.selectedRowInComponent(0)
            let selectedSittingMeditationTime = self.meditatorView.meditationPickerView.selectedRowInComponent(2)
            var totalTime = 0

            self.walkingTimeInMinutes = nil
            self.sittingTimeInMinutes = nil

            if selectedSittingMeditationTime > 0 {
                self.sittingTimeInMinutes = self.times[selectedSittingMeditationTime]
                totalTime += self.sittingTimeInMinutes!
            }

            if selectedWalkingMeditationTime > 0 {
                self.walkingTimeInMinutes = self.times[selectedWalkingMeditationTime]
                totalTime += self.walkingTimeInMinutes!
            }

            if totalTime != 0 {
//                self.meditatorManager.startMeditation(self.sittingTimeInMinutes, walkingTimeInMinutes: self.walkingTimeInMinutes, completion: { () -> Void in
//                    //
//                    NSLog("Did start")
//                }, failure: { (error) -> Void in
//                    NSLog("Start meditation failed")
//                    //
//                })

                self.meditatorView.setSelectionViewHidden(true, animated: true)

                self.timer.startTimer(Double(totalTime), preparationTime: 10)
            }
            
        } else {
//            self.meditatorManager.cancelMeditation(self.sittingTimeInMinutes, walkingTimeInMinutes: self.walkingTimeInMinutes, completion: { () -> Void in
//                //
//                NSLog("Did cancel")
//            }, failure: { (error) -> Void in
//                NSLog("Cancel meditation failed")
//                //
//            })

            self.sittingTimeInMinutes = nil
            self.walkingTimeInMinutes = nil

            self.meditatorView.setSelectionViewHidden(false, animated: true)
        }
    }
//    @IBAction func didPressStartMeditationButton(sender: UIButton) {
//        self.meditationTimer?.invalidate()
//
//        if self.meditatorView.isSelectionViewHidden {
////            self.meditatorManager.cancelMeditation(self.sittingTimeInMinutes, walkingTimeInMinutes: self.walkingTimeInMinutes, completion: { () -> Void in
////                //
////                NSLog("Did cancel")
////            }, failure: { (error) -> Void in
////                NSLog("Cancel meditation failed")
////                //
////            })
//
//            self.sittingTimeInMinutes = nil
//            self.walkingTimeInMinutes = nil
//
//            self.remainingMeditationTime = 0
//            self.updateRemainingTimeLabel()
//            self.meditatorView.setSelectionViewHidden(false, animated: true)
//
//        } else {
//            // Start
//            let selectedWalkingMeditationTime = self.meditatorView.meditationPickerView.selectedRowInComponent(0)
//            let selectedSittingMeditationTime = self.meditatorView.meditationPickerView.selectedRowInComponent(1)
//            var totalTime = 0
//
//            self.walkingTimeInMinutes = nil
//            self.sittingTimeInMinutes = nil
//
//            if selectedSittingMeditationTime > 0 {
//                self.sittingTimeInMinutes = self.times[selectedSittingMeditationTime]
//                totalTime += self.sittingTimeInMinutes!
//            }
//
//            if selectedWalkingMeditationTime > 0 {
//                self.walkingTimeInMinutes = self.times[selectedWalkingMeditationTime]
//                totalTime += self.walkingTimeInMinutes!
//            }
//
//            if totalTime != 0 {
//
////                self.meditatorManager.startMeditation(self.sittingTimeInMinutes, walkingTimeInMinutes: self.walkingTimeInMinutes, completion: { () -> Void in
////                    //
////                    NSLog("Did start")
////                }, failure: { (error) -> Void in
////                    NSLog("Start meditation failed")
////                    //
////                })
//                self.remainingMeditationTime = Double(totalTime * 60)
//
//                self.meditationTimer = NSTimer.scheduledTimerWithTimeInterval(self.timeInterval, target: self, selector: "meditationTimerTick", userInfo: nil, repeats: true)
//                self.updateRemainingTimeLabel()
//                self.meditatorView.setSelectionViewHidden(true, animated: true)
//
//                self.audioPlayer.play()
//            }
//        }
//    }

    // returns the number of 'columns' to display.
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 4
    }
    
    // returns the # of rows in each component..
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        if component == 1 || component == 3 {
            return 1
        } else {
            return self.times.count
        }
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        var title = ""
        
        if row == 0 && (component == 1 || component == 3) {
            title = component == 1 ? "Walking" : "Sitting"
        } else {
            let hours   = times[row] / 60
            let minutes = times[row] % 60
            title = String(format: "%d:%2.2d" , hours ,minutes)
        }
        
        return title
    }

    func toggleSelectionView() {
        self.meditatorView.setSelectionViewHidden(!self.meditatorView.isSelectionViewHidden, animated: true)
    }

    // MARK: MPMeditationTimerDelegate: NSObjectProtocol {


    func meditationTimer(meditationTimer: MPMeditationTimer, didStartWithState state: MPMeditationState)
    {
        NSLog("start state: \(state.title)")
    }

    func meditationTimer(meditationTimer: MPMeditationTimer, didProgress progress: Double, withState state: MPMeditationState, timeLeft: NSTimeInterval)
    {
        NSLog("progress state: \(state.title), progress: \(progress), timeLeft: \(timeLeft)")
        
        if state == MPMeditationState.Meditation {
            let seconds = timeLeft % 60;
            let hours   = timeLeft / 3600
            let minutes = timeLeft / 60 % 60
            self.meditatorView.meditationTimerLabel.text = String(format: "%2.2d:%2.2d:%2.2d" , Int(hours) , Int(minutes), Int(seconds))
        }
    }

    func meditationTimer(meditationTimer: MPMeditationTimer, didStopWithState state: MPMeditationState)
    {
        NSLog("stop state: \(state.title)")
        
        if state == MPMeditationState.Meditation {
            self.meditatorView.meditationTimerLabel.text = "00:00:00"
            self.meditatorView.setSelectionViewHidden(false, animated: true)
        }
    }

//    private func updateRemainingTimeLabel() {
//        if self.remainingMeditationTime <= 0 {
//            self.meditationTimer?.invalidate()
//            self.meditatorView.meditationTimerLabel.text = "00:00:00"
//            self.remainingMeditationTime = 0
//            self.meditatorView.setSelectionViewHidden(true, animated: true)
//        } else {
//            var seconds = self.remainingMeditationTime % 60;
//            var hours   = self.remainingMeditationTime / 3600
//            var minutes = self.remainingMeditationTime / 60 % 60
//            self.meditatorView.meditationTimerLabel.text = String(format: "%2.2d:%2.2d:%2.2d" , Int(hours) , Int(minutes), Int(seconds))
//        }
//    }

}
