//
//  SetupManager.swift
//  MeditationPlus
//
//  Created by Erik Luimes on 06/05/16.
//
//  The MIT License
//  Copyright (c) 2016 Maya Interactive. All rights reserved.
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

import Foundation
import CocoaLumberjack
import Fabric
import Crashlytics

public class SetupManager
{
    static public func setup() -> Void
    {
        setupLogging()
        setupConfig()
        setupR()
        setupCrashlytics()
        updateSettingsPage()
        setupDefaults()
        setupMeditationTimer()
    }
    
    static private func setupConfig()
    {
        DDLogInfo("Using api config:\n\(Config.api.endpoint)" )
    }
    
    static private func setupR()
    {
        R.assertValid()
    }
    
    static private func setupLogging() -> Void
    {
        DDTTYLogger.sharedInstance().logFormatter = LogFormatter()
        DDLog.addLogger(DDTTYLogger.sharedInstance())
        
        defaultDebugLevel = DDLogLevel.All
    }
    
    static private func setupCrashlytics() -> Void
    {
        let sendCrashes = NSUserDefaults.standardUserDefaults().objectForKey("CrashReportingPreference")?.boolValue ?? true
        DDLogInfo("Send crashlogs: \(sendCrashes)")
        
        if (sendCrashes) {
            Crashlytics.startWithAPIKey(Config.crashlytics.key)
            NSUserDefaults.standardUserDefaults().setValue(NSNumber(bool: true), forKey: "CrashReportingPreference")
        }
    }
    
    static private func updateSettingsPage() -> Void
    {
        let versionNumber = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as! String
        let buildNumber = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleVersion") as! String
        
        NSUserDefaults.standardUserDefaults().setValue("\(versionNumber) (\(buildNumber))", forKey: "ApplicationVersion")
        
        DDLogInfo("Version: \(versionNumber) (\(buildNumber))")
    }
    
    static private func setupDefaults()
    {
        NSUserDefaults.standardUserDefaults().registerDefaults([
            "rememberPassword": false,
            "walkingMeditationTimeId": 6,
            "sittingMeditationTimeId": 6
        ])
    }

    static private func setupMeditationTimer()
    {
        MeditationTimer.sharedInstance.addDelegate(AudioPlayerManager.sharedInstance)
        MeditationTimer.sharedInstance.addDelegate(IdleTimeoutMeditationTimerDelegate.sharedInstance)
    }
}