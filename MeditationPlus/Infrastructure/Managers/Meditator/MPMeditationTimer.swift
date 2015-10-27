//
//  MPMeditationTimer.swift
//  MeditationPlus
//
//  Created by Erik Luimes on 19/09/15
//  Copyright (c) 2015 Maya Interactive
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

import Foundation
import AVFoundation

protocol MPMeditationTimerDelegate: NSObjectProtocol {
    func meditationTimer(meditationTimer: MPMeditationTimer, didStartWithState state: MPMeditationState)
    func meditationTimer(meditationTimer: MPMeditationTimer, didProgress progress: Double, withState state: MPMeditationState, timeLeft: NSTimeInterval)
    func meditationTimer(meditationTimer: MPMeditationTimer, withState state: MPMeditationState, type: MPMeditationType, progress: Double, timeLeft: NSTimeInterval, totalProgress: Double, totalTimeLeft: NSTimeInterval)
    func meditationTimer(meditationTimer: MPMeditationTimer, didStopWithState state: MPMeditationState)

    func meditationTimer(meditationTimer: MPMeditationTimer, didChangeMeditationFromType fromType: MPMeditationType, toType: MPMeditationType)

    func meditationTimerWasCancelled(meditationTimer: MPMeditationTimer)
}

enum MPMeditationState: Int {
    case Stopped
    case Preparation
    case Meditation

    init(remainingMeditationTime: NSTimeInterval, remainingPreparationTime: NSTimeInterval)
    {
        if remainingPreparationTime > 0 {
            self = .Preparation
        } else if remainingMeditationTime > 0 {
            self = .Meditation
        } else {
            self = .Stopped
        }
    }

    var title: String {
        switch self {
            case .Stopped:     return "Stopped"
            case .Preparation: return "Preparation"
            case .Meditation:  return "Meditation"
        }
    }
}

enum MPMeditationType {
    case Sitting
    case Walking
}

struct MPMeditationSession
{
    let type: MPMeditationType
    let time: NSTimeInterval
    var remaining: NSTimeInterval
    let endDateTime: NSDate
    var progress: Double {
        return time > 0 ? (time - remaining) / time : 0.0
    }

    init(type: MPMeditationType, time: NSTimeInterval) {
        self.type = type
        self.time = time

        remaining = time
        endDateTime = NSDate().dateByAddingTimeInterval(time)
    }
}

class MPMeditationTimer: NSObject
{
    static let sharedInstance: MPMeditationTimer = MPMeditationTimer()
    
    internal var delegate: MPMeditationTimerDelegate?

    private(set) var state: MPMeditationState = .Stopped

    private let timeInterval: NSTimeInterval = 1
    
    private var meditationTimer: NSTimer?

    // MARK: Meditation time
    private var meditationSessions: [MPMeditationSession]? = [MPMeditationSession]()

    private var currentSession: MPMeditationSession?

    private var totalMeditationTime: NSTimeInterval = 0 {
        didSet {
            totalRemainingMeditationTime = totalMeditationTime
        }
    }

    private var totalRemainingMeditationTime: NSTimeInterval = 0

    private var totalMeditationProgress: Double {
        return calculateProgress(totalMeditationTime, remaining: totalRemainingMeditationTime)
    }


    // MARK: Preparation time
    private var totalPreparationTime: NSTimeInterval = 0 {
        didSet {
            remainingPreparationTime = totalPreparationTime
        }
    }

    private var remainingPreparationTime: NSTimeInterval = 0

    private var preparationProgress: Double {
        return calculateProgress(totalPreparationTime, remaining: remainingPreparationTime)
    }
    
    private func calculateProgress(total: NSTimeInterval, remaining: NSTimeInterval) -> Double
    {
        return total > 0 ? (total - remaining) / total : 0.0
    }

    // MARK: Init

    override init() {
        super.init()
    }

    // MARK: Timer functions

    func startTimer(meditationTimes: [MPMeditationSession], preparationTime: NSTimeInterval = 0) {
        self.meditationSessions = meditationTimes.filter({ $0.time > 0})
        self.totalMeditationTime  = self.meditationSessions!.map({ $0.time }).reduce(0, combine: +)
        self.totalPreparationTime = preparationTime

        meditationTimer = NSTimer.scheduledTimerWithTimeInterval(timeInterval, target: self, selector: "meditationTimerCompoundTick", userInfo: nil, repeats: true)
        NSRunLoop.mainRunLoop().addTimer(meditationTimer!, forMode:NSRunLoopCommonModes)
        meditationTimerCompoundTick()
    }

    private func stopTimer() {
        meditationTimer?.invalidate()
        
        state                    = .Stopped
        remainingPreparationTime = 0
        totalRemainingMeditationTime = 0
    }
    
    func cancelTimer() {
        stopTimer()
        delegate?.meditationTimerWasCancelled(self)
    }

    func meditationTimerCompoundTick()
    {
        let oldState = self.state
        let newState = MPMeditationState(remainingMeditationTime: totalRemainingMeditationTime, remainingPreparationTime: remainingPreparationTime)
        
        if oldState != newState {
            notifyStateChangeFromState(oldState, toState: newState)
        }
        
        state = newState

        switch state {
            case .Preparation:
                remainingPreparationTime -= timeInterval
                delegate?.meditationTimer(self, didProgress: preparationProgress, withState: state, timeLeft: remainingPreparationTime)
            case .Meditation:
                totalRemainingMeditationTime -= timeInterval
                guard let _ = self.currentSession where self.currentSession!.remaining > 0 else {
                    self.startNextSession()
                    break
                }
                
                if self.currentSession != nil {
                    self.currentSession!.remaining -= timeInterval
                    delegate?.meditationTimer(self, withState: state, type: currentSession!.type, progress: currentSession!.progress, timeLeft: self.currentSession!.remaining, totalProgress: totalMeditationProgress, totalTimeLeft: totalRemainingMeditationTime)
                } else {
                    totalRemainingMeditationTime = 0
                }
            default:
                stopTimer()
        }
    }

    // MARK Session functions

    func startNextSession() {
        guard let _ = self.meditationSessions where self.meditationSessions!.count > 0 else {
            return
        }

        let previousSession = self.currentSession
        self.currentSession = self.meditationSessions![0]
        self.meditationSessions!.removeAtIndex(0)
        
        if previousSession != nil {
            self.delegate?.meditationTimer(self, didChangeMeditationFromType: previousSession!.type, toType: currentSession!.type)
        }
    }

    // MARK State change notifications 
    
    func notifyStateChangeFromState(fromState: MPMeditationState, toState: MPMeditationState) -> Void
    {
        if toState == .Stopped {
            delegate?.meditationTimer(self, didStopWithState: fromState)
        } else {
            switch fromState {
                case .Stopped:
                    delegate?.meditationTimer(self, didStartWithState: toState)
                case .Preparation:
                    delegate?.meditationTimer(self, didStopWithState: fromState)
                    delegate?.meditationTimer(self, didStartWithState: toState)
                default:
                    break
            }
        }
    }
}

