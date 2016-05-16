//
//  MeditationTimer.swift
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
import UIKit

protocol MPMeditationTimerDelegate: NSObjectProtocol {
    func meditationTimer(meditationTimer: MPMeditationTimer, didStartWithState state: MPMeditationState)

    func meditationTimer(meditationTimer: MPMeditationTimer, didProgress progress: Double, withState state: MPMeditationState, timeLeft: NSTimeInterval)

    func meditationTimer(meditationTimer: MPMeditationTimer, withState state: MPMeditationState, type: MPMeditationType, progress: Double, timeLeft: NSTimeInterval, totalProgress: Double, totalTimeLeft: NSTimeInterval)

    func meditationTimer(meditationTimer: MPMeditationTimer, didStopWithState state: MPMeditationState)

    func meditationTimer(meditationTimer: MPMeditationTimer, didChangeMeditationFromType fromType: MPMeditationType, toType: MPMeditationType)

    func meditationTimerWasCancelled(meditationTimer: MPMeditationTimer)
}

enum MPMeditationTimerError: ErrorType {
    case NoValidTimeAvailable
    case InvalidTime
}

enum MPMeditationState: Int {
    case Stopped
    case Suspended
    case Preparation
    case Meditation

    init(remainingMeditationTime: NSTimeInterval, remainingPreparationTime: NSTimeInterval) {
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
            case .Suspended:   return "Suspended"
            case .Preparation: return "Preparation"
            case .Meditation:  return "Meditation"
        }
    }
}

enum MPMeditationType: String {
    case Sitting
    case Walking
}

class MPMeditationSession {
    let type: MPMeditationType
    let time: NSTimeInterval

    var remaining: NSTimeInterval {
        var remaining = endDate.timeIntervalSinceNow
        if remaining < 0 {
            remaining = 0
        }

        return remaining
    }

    var startDate: NSDate!
    var endDate: NSDate!

    var isCurrent: Bool {
        let timeInterval = NSDate().timeIntervalSince1970
        return startDate.timeIntervalSince1970 <= timeInterval && timeInterval <= timeInterval
    }

    var progress: Double {
        return time > 0 ? (time - remaining) / time : 0.0
    }

    init(type: MPMeditationType, time: NSTimeInterval, startDate: NSDate = NSDate()) {
        self.type = type
        self.time = time

        self.updateDateWithOffset(0.0)
    }

    func updateDateWithOffset(offset: NSTimeInterval) {
        self.startDate = NSDate().dateByAddingTimeInterval(offset)
        self.endDate = startDate.dateByAddingTimeInterval(time)
    }
}

class MPMeditationTimer: NSObject {
    static let sharedInstance: MPMeditationTimer = MPMeditationTimer()

    internal var delegate: MPMeditationTimerDelegate?

    private(set) var state: MPMeditationState = .Stopped

    private let timeInterval: NSTimeInterval = 1

    private var meditationTimer: NSTimer?

    // MARK: Meditation time
    private var meditationSessions: [MPMeditationSession] = [MPMeditationSession]()

    private var currentSessionIndex: Int = 0 {
        didSet {
            if currentSessionIndex < meditationSessions.count {
                currentSessionIndex = 0
            }
        }
    }

    private var meditationTimerStartDate: NSDate = NSDate()

    private var totalMeditationTime: NSTimeInterval = 0

    private var totalRemainingMeditationTime: NSTimeInterval {
        var totalRemainingMeditationTime: NSTimeInterval = 0.0
        if let lastMeditationSession = meditationSessions.last {
            totalRemainingMeditationTime = lastMeditationSession.endDate.timeIntervalSinceNow
            if totalRemainingMeditationTime < 0 {
                totalRemainingMeditationTime = 0
            }
        }
        return totalRemainingMeditationTime
    }

    private var totalMeditationProgress: Double {
        return calculateProgress(totalMeditationTime, remaining: totalRemainingMeditationTime)
    }


    // MARK: Preparation time
    private var totalPreparationTime: NSTimeInterval = 0

    private var remainingPreparationTime: NSTimeInterval {
        var remainingTime = meditationTimerStartDate.dateByAddingTimeInterval(totalPreparationTime).timeIntervalSinceNow
        if remainingTime < 0 {
            remainingTime = 0
        }
        return remainingTime
    }

    private var preparationProgress: Double {
        return calculateProgress(totalPreparationTime, remaining: remainingPreparationTime)
    }

    private func calculateProgress(total: NSTimeInterval, remaining: NSTimeInterval) -> Double {
        return total > 0 ? (total - remaining) / total : 0.0
    }

    // MARK: Init

    override init() {
        super.init()
    }

    // MARK: Timer functions

    func startTimer(meditationSessions: [MPMeditationSession], preparationTime: NSTimeInterval = 0) throws -> Void {
        self.meditationSessions = meditationSessions.filter({ $0.time > 0 })

        if self.meditationSessions.count == 0 {
            throw MPMeditationTimerError.NoValidTimeAvailable
        }

        self.meditationTimerStartDate = NSDate()
        self.totalPreparationTime = preparationTime

        var offset = totalPreparationTime
        for session in self.meditationSessions {
            session.updateDateWithOffset(offset)
            offset += session.time
        }

        self.totalMeditationTime = meditationSessions.map({ $0.time }).reduce(0, combine: +)

        initTimer()
    }

    private func initTimer() {
        meditationTimer = NSTimer.scheduledTimerWithTimeInterval(timeInterval, target: self, selector: #selector(MPMeditationTimer.meditationTimerCompoundTick), userInfo: nil, repeats: true)
        NSRunLoop.mainRunLoop().addTimer(meditationTimer!, forMode: NSRunLoopCommonModes)
        meditationTimerCompoundTick()
    }

    private func stopTimer() {
        meditationTimer?.invalidate()

        state = .Stopped
        currentSessionIndex = 0
        meditationSessions.removeAll()
    }

    private func suspendTimer() {
        meditationTimer?.invalidate()

        state = .Suspended
    }

    func cancelTimer() {
        stopTimer()
        delegate?.meditationTimerWasCancelled(self)
        UIApplication.sharedApplication().cancelAllLocalNotifications()
    }

    func meditationTimerCompoundTick() {
        let oldState = self.state
        let newState = MPMeditationState(remainingMeditationTime: totalRemainingMeditationTime, remainingPreparationTime: remainingPreparationTime)

        if oldState != newState {
            notifyStateChangeFromState(oldState, toState: newState)
        }

        state = newState

        switch state {
            case .Preparation:
                delegate?.meditationTimer(self, didProgress: preparationProgress, withState: state, timeLeft: remainingPreparationTime)
            case .Meditation:
                for session in meditationSessions {
                    if session.isCurrent {
                        delegate?.meditationTimer(self, withState: state, type: session.type, progress: session.progress, timeLeft: session.remaining, totalProgress: totalMeditationProgress, totalTimeLeft: totalRemainingMeditationTime)
                    }
                }
            default:
                stopTimer()
        }
    }

    // MARK State change notifications

    func notifyStateChangeFromState(fromState: MPMeditationState, toState: MPMeditationState) -> Void {
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

    func applicationDidEnterBackground() {
        registerNotificationForSessionStart()
        registerNotificationForSessionEnd()
    }

    func applicationWillEnterForeground() {
        UIApplication.sharedApplication().cancelAllLocalNotifications()

        self.meditationTimer?.invalidate()
        initTimer()
    }

    func registerNotificationForSessionStart() {
        if remainingPreparationTime > 0 {
            let localNotification: UILocalNotification = UILocalNotification()
            localNotification.alertBody = "Meditation session started."
            localNotification.fireDate = NSDate().dateByAddingTimeInterval(remainingPreparationTime)
            localNotification.soundName = "bell.mp3"

            UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
        }
    }

    func registerNotificationForSessionEnd() {
        let numSessions = meditationSessions.count

        var currentSessionNumber = 1
        for session in meditationSessions {
            if session.endDate.timeIntervalSince1970 > NSDate().timeIntervalSince1970 {
                let localNotification: UILocalNotification = UILocalNotification()
                localNotification.alertBody = "\(session.type) session ended."
                localNotification.fireDate = session.endDate
                localNotification.soundName = currentSessionNumber == numSessions ? "bell.mp3" : "bowl.mp3"

                UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
            }

            currentSessionNumber += 1
        }
    }
}
