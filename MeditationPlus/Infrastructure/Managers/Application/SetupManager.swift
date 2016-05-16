//
//  SetupManager.swift
//  MeditationPlus
//
//  Created by Erik Luimes on 06/05/16.
//  Copyright © 2016 Maya Interactive. All rights reserved.
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
        setupCrashlytics()
        updateSettingsPage()
        setupDefaults()
        setupMeditationTimer()
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
            Fabric.with([Crashlytics.sharedInstance()])
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