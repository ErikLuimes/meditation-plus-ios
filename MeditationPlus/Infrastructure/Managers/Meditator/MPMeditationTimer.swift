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
    func meditationTimer(meditationTimer: MPMeditationTimer, didStopWithState state: MPMeditationState)
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

class MPMeditationTimer: NSObject
{
    static let sharedInstance: MPMeditationTimer = MPMeditationTimer()
    weak var delegate: MPMeditationTimerDelegate?

//    var stateChangeHandler: (fromState: MPMeditationState, toState: MPMeditationState) -> Void = {[weak self] (fromState, toState) -> Void in

    private var state: MPMeditationState = .Stopped {
        didSet {
            if (oldValue != self.state) { self.stateChangeHandlerFromState(oldValue, toState: self.state) }
        }
    }

    private let timeInterval:            NSTimeInterval = 1
    private var meditationTimer:         NSTimer?

    // MARK: Meditation time
    private var totalMeditationTime:      NSTimeInterval = 0 {
        didSet {
            self.remainingMeditationTime = self.totalMeditationTime
        }
    }

    private var remainingMeditationTime: NSTimeInterval = 0

    private var meditationProgress: Double {
        return self.calculateProgress(self.totalMeditationTime, remaining: self.remainingMeditationTime)
    }


    // MARK: Preparation time
    private var totalPreparationTime: NSTimeInterval = 0 {
        didSet {
            self.remainingPreparationTime = self.totalPreparationTime
        }
    }

    private var remainingPreparationTime: NSTimeInterval = 0

    private var preparationProgress: Double {
        return self.calculateProgress(totalPreparationTime, remaining: remainingPreparationTime)
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

    func startTimer(meditationTime: NSTimeInterval, preparationTime: NSTimeInterval = 0) {
        self.totalPreparationTime = preparationTime
        self.totalMeditationTime  = meditationTime

        self.meditationTimer = NSTimer.scheduledTimerWithTimeInterval(self.timeInterval, target: self, selector: "meditationTimerTick", userInfo: nil, repeats: true)
    }

    func stopTimer() {
        self.meditationTimer?.invalidate()

        self.remainingPreparationTime = 0
        self.remainingMeditationTime  = 0
    }

    func meditationTimerTick()
    {
        self.state = MPMeditationState(remainingMeditationTime: self.remainingMeditationTime, remainingPreparationTime: self.remainingPreparationTime)

        switch self.state {
            case .Preparation:
                self.remainingPreparationTime -= self.timeInterval
                self.delegate?.meditationTimer(self, didProgress: self.preparationProgress, withState: self.state, timeLeft: self.remainingPreparationTime)
            case .Meditation:
                self.remainingMeditationTime -= self.timeInterval
                self.delegate?.meditationTimer(self, didProgress: self.meditationProgress, withState: self.state, timeLeft: self.remainingMeditationTime)
            default:
                self.stopTimer()
        }
    }
    
    // MARK State change notifications 
    func stateChangeHandlerFromState(fromState: MPMeditationState, toState: MPMeditationState) -> Void
    {
        if toState == .Stopped {
            self.delegate?.meditationTimer(self, didStopWithState: fromState)
        } else {
            switch fromState {
                case .Stopped:
                    self.delegate?.meditationTimer(self, didStartWithState: toState)
                case .Preparation:
                    self.delegate?.meditationTimer(self, didStopWithState: fromState)
                    self.delegate?.meditationTimer(self, didStartWithState: toState)
                default:
                    break
            }
        }
    }

}
