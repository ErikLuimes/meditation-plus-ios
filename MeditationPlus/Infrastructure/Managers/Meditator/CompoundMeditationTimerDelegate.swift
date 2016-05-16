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

class CompoundMeditationTimerDelegate: NSObject, MeditationTimerDelegate
{
    var delegates: [MeditationTimerDelegate] = [MeditationTimerDelegate]()

    override init()
    {
        super.init()
    }

    func meditationTimer(meditationTimer: MeditationTimer, didStartWithState state: MeditationState)
    {
        _ = self.delegates.map({ $0.meditationTimer(meditationTimer, didStartWithState: state) })
    }

    func meditationTimer(meditationTimer: MeditationTimer, didProgress progress: Double, withState state: MeditationState, timeLeft: NSTimeInterval)
    {
        _ = self.delegates.map({ $0.meditationTimer(meditationTimer, didProgress: progress, withState: state, timeLeft: timeLeft) })
    }

    func meditationTimer(meditationTimer: MeditationTimer, withState state: MeditationState, type: MeditationType, progress: Double, timeLeft: NSTimeInterval, totalProgress: Double, totalTimeLeft: NSTimeInterval)
    {
        _ = self.delegates.map({ $0.meditationTimer(meditationTimer, withState: state, type: type, progress: progress, timeLeft: timeLeft, totalProgress: totalProgress, totalTimeLeft: totalTimeLeft) })
    }

    func meditationTimer(meditationTimer: MeditationTimer, didStopWithState state: MeditationState)
    {
        _ = self.delegates.map({ $0.meditationTimer(meditationTimer, didStopWithState: state) })
    }

    func meditationTimer(meditationTimer: MeditationTimer, didChangeMeditationFromType fromType: MeditationType, toType: MeditationType)
    {
        _ = self.delegates.map({ $0.meditationTimer(meditationTimer, didChangeMeditationFromType: fromType, toType: toType) })
    }

    func meditationTimerWasCancelled(meditationTimer: MeditationTimer)
    {
        _ = self.delegates.map({ $0.meditationTimerWasCancelled(meditationTimer) })
    }
}

protocol MeditationTimerCompoundDelegate: NSObjectProtocol
{
    func addDelegate(delegate: MeditationTimerDelegate)

    func removeDelegate(delegate: MeditationTimerDelegate)
}

extension MeditationTimer: MeditationTimerCompoundDelegate
{
    // Removes existing delegate if it's not a compound delegate
    func addDelegate(delegate: MeditationTimerDelegate)
    {
        if !(self.delegate is CompoundMeditationTimerDelegate) {
            self.delegate = CompoundMeditationTimerDelegate()
        }

        if let compoundDelegate = self.delegate as? CompoundMeditationTimerDelegate {
            compoundDelegate.delegates.append(delegate)
        }
    }

    func removeDelegate(delegate: MeditationTimerDelegate)
    {
        if let compoundDelegate = self.delegate as? CompoundMeditationTimerDelegate {
            compoundDelegate.delegates = compoundDelegate.delegates.filter
            {
                return $0 !== delegate
            }
        }
    }
}
