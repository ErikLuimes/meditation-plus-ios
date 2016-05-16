//
//  CompoundMeditationTimerDelegate.swift
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

// Be sure to remove your delegates since there are no weak references

class MPCompoundMeditationTimerDelegate: NSObject, MPMeditationTimerDelegate
{
    var delegates: [MPMeditationTimerDelegate] = [MPMeditationTimerDelegate]()

    override init()
    {
        super.init()
    }

    func meditationTimer(meditationTimer: MPMeditationTimer, didStartWithState state: MPMeditationState)
    {
        _ = self.delegates.map({ $0.meditationTimer(meditationTimer, didStartWithState: state) })
    }

    func meditationTimer(meditationTimer: MPMeditationTimer, didProgress progress: Double, withState state: MPMeditationState, timeLeft: NSTimeInterval)
    {
        _ = self.delegates.map({ $0.meditationTimer(meditationTimer, didProgress: progress, withState: state, timeLeft: timeLeft) })
    }

    func meditationTimer(meditationTimer: MPMeditationTimer, withState state: MPMeditationState, type: MPMeditationType, progress: Double, timeLeft: NSTimeInterval, totalProgress: Double, totalTimeLeft: NSTimeInterval)
    {
        _ = self.delegates.map({ $0.meditationTimer(meditationTimer, withState: state, type: type, progress: progress, timeLeft: timeLeft, totalProgress: totalProgress, totalTimeLeft: totalTimeLeft) })
    }

    func meditationTimer(meditationTimer: MPMeditationTimer, didStopWithState state: MPMeditationState)
    {
        _ = self.delegates.map({ $0.meditationTimer(meditationTimer, didStopWithState: state) })
    }

    func meditationTimer(meditationTimer: MPMeditationTimer, didChangeMeditationFromType fromType: MPMeditationType, toType: MPMeditationType)
    {
        _ = self.delegates.map({ $0.meditationTimer(meditationTimer, didChangeMeditationFromType: fromType, toType: toType) })
    }

    func meditationTimerWasCancelled(meditationTimer: MPMeditationTimer)
    {
        _ = self.delegates.map({ $0.meditationTimerWasCancelled(meditationTimer) })
    }
}

protocol MPMeditationTimerCompoundDelegate: NSObjectProtocol
{
    func addDelegate(delegate: MPMeditationTimerDelegate)

    func removeDelegate(delegate: MPMeditationTimerDelegate)
}

extension MPMeditationTimer: MPMeditationTimerCompoundDelegate
{
    // Removes existing delegate if it's not a compound delegate
    func addDelegate(delegate: MPMeditationTimerDelegate)
    {
        if !(self.delegate is MPCompoundMeditationTimerDelegate) {
            self.delegate = MPCompoundMeditationTimerDelegate()
        }

        if let compoundDelegate = self.delegate as? MPCompoundMeditationTimerDelegate {
            compoundDelegate.delegates.append(delegate)
        }
    }

    func removeDelegate(delegate: MPMeditationTimerDelegate)
    {
        if let compoundDelegate = self.delegate as? MPCompoundMeditationTimerDelegate {
            compoundDelegate.delegates = compoundDelegate.delegates.filter
            {
                return $0 !== delegate
            }
        }
    }
}
