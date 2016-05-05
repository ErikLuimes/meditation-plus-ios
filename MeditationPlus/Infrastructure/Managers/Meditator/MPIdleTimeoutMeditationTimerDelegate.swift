//
//  MPIdleTimeoutDelegate.swift
//  MeditationPlus
//
//  Created by Erik Luimes on 25/10/15
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

class MPIdleTimeoutMeditationTimerDelegate: NSObject, MPMeditationTimerDelegate
{
    static let sharedInstance = MPIdleTimeoutMeditationTimerDelegate()

    // MARK: MPMeditationTimerDelegate

    func meditationTimer(meditationTimer: MPMeditationTimer, didStartWithState state: MPMeditationState)
    {
        UIApplication.sharedApplication().idleTimerDisabled = true
    }

    func meditationTimer(meditationTimer: MPMeditationTimer, withState state: MPMeditationState, type: MPMeditationType, progress: Double, timeLeft: NSTimeInterval, totalProgress: Double, totalTimeLeft: NSTimeInterval)
    {
    }

    func meditationTimer(meditationTimer: MPMeditationTimer, didProgress progress: Double, withState state: MPMeditationState, timeLeft: NSTimeInterval)
    {
    }

    func meditationTimerWasCancelled(meditationTimer: MPMeditationTimer)
    {
        UIApplication.sharedApplication().idleTimerDisabled = false
    }

    func meditationTimer(meditationTimer: MPMeditationTimer, didChangeMeditationFromType fromType: MPMeditationType, toType: MPMeditationType)
    {
    }

    func meditationTimer(meditationTimer: MPMeditationTimer, didStopWithState state: MPMeditationState)
    {
        if state == MPMeditationState.Meditation {
            UIApplication.sharedApplication().idleTimerDisabled = false
        }
    }
}
