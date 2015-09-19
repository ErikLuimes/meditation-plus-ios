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
    func meditationTimerDidStart(meditationTimer: MPMeditationTimer)

    // preparation timer
    func meditationTimer(meditationTimer: MPMeditationTimer, preparationTimerDidProgress: Double, timeLeft: NSTimeInterval)
    func meditationTimerPreparationDidStop(meditationTimer: MPMeditationTimer)

    // Meditation timer
    func meditationTimer(meditationTimer: MPMeditationTimer, meditationTimerDidProgress: Double, timeLeft: NSTimeInterval)
    func meditationTimerDidStop(meditationTimer: MPMeditationTimer)
}

enum MPMeditationTimingType: Int {
    case Preparation
    case Meditation
}

class MPMeditationTimer
{
    let sharedInstance: MPMeditationTimer = MPMeditationTimer()
    weak var delegate: MPMeditationTimerDelegate?

    private var sampleUrl = NSURL(string: NSBundle.mainBundle().pathForResource("bell", ofType: "mp3")!)!
    private var audioPlayer: AVAudioPlayer
    var playAudio = true

    private let timeInterval:            NSTimeInterval = 1
    private var meditationTimer:         NSTimer?

    private var totalMeditationTime:      NSTimeInterval = 0 {
        didSet {
            self.remainingMeditationTime = self.totalMeditationTime
        }
    }

    private var remainingMeditationTime: NSTimeInterval = 0

    private var meditationProgress: Double {
        return self.calculateProgress(self.totalMeditationTime, remaining: self.remainingMeditationTime)
    }

    private var totalPreparationTime: NSTimeInterval? {
        didSet {
            self.remainingPreparationTime = self.totalPreparationTime
        }
    }

    private var remainingPreparationTime: NSTimeInterval?

    private var preparationProgress: Double {
        var progress: Double = 0.0

        if let total = self.totalPreparationTime, remaining = self.remainingPreparationTime {
            progress = self.calculateProgress(total, remaining: remaining)
        }

        return progress
    }

    init() {
        self.audioPlayer = AVAudioPlayer(contentsOfURL: self.sampleUrl, error: nil)
        self.audioPlayer.prepareToPlay()
    }

    func startTimer(meditationTime: NSTimeInterval, preparationTime: NSTimeInterval?) {
        self.totalPreparationTime = preparationTime
        self.totalMeditationTime  = meditationTime

        self.meditationTimer = NSTimer.scheduledTimerWithTimeInterval(self.timeInterval, target: self, selector: "timerTick", userInfo: nil, repeats: true)
    }

    func stopTimer() {
        self.meditationTimer?.invalidate()
        self.meditationTimer = nil

        self.remainingPreparationTime = nil
        self.remainingMeditationTime = 0
    }

    func timerTick() {
        if let delay = self.remainingPreparationTime {
            self.delegate?.meditationTimer(self, preparationTimerDidProgress: self.preparationProgress, timeLeft: delay)

            if delay == 0 {
                self.remainingPreparationTime = nil
                self.delegate?.meditationTimerPreparationDidStop(self)
            } else {
                self.remainingPreparationTime! -= self.timeInterval
            }
        } else {
            if self.playAudio && self.totalMeditationTime == self.remainingMeditationTime {
                self.audioPlayer.play()
            }

            self.delegate?.meditationTimer(self, meditationTimerDidProgress: self.meditationProgress, timeLeft: self.remainingMeditationTime)

            if self.remainingMeditationTime <= 0{
                if (self.playAudio) {
                    self.audioPlayer.play()
                }
                self.stopTimer()
                self.delegate?.meditationTimerDidStop(self)
            } else {
                self.remainingMeditationTime -= self.timeInterval
            }

        }
    }

    func calculateProgress(total: NSTimeInterval, remaining: NSTimeInterval) -> Double
    {
        return total > 0 ? (total - remaining) / total : 0.0
    }
}
