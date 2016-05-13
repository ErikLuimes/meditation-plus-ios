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
    }
    
    static private func setupLogging() -> Void
    {
        DDTTYLogger.sharedInstance().logFormatter = LogFormatter()
        DDLog.addLogger(DDTTYLogger.sharedInstance())
        
        defaultDebugLevel = DDLogLevel.All
    }
    
    static private func setupCrashlytics() -> Void
    {
        let sendCrashesValue: NSNumber? = NSUserDefaults.standardUserDefaults().objectForKey("MICrashReportingPreference") as? NSNumber
        let sendCrashes = (sendCrashesValue == nil) || (sendCrashesValue!.boolValue == true)
        
        DDLogInfo("Send crashlogs: \(sendCrashes)")
        
        if (sendCrashes) {
            Fabric.with([Crashlytics.sharedInstance()])
            NSUserDefaults.standardUserDefaults().setValue(NSNumber(bool: true), forKey: "MICrashReportingPreference")
        }
    }
    
    static private func updateSettingsPage() -> Void
    {
        let versionNumber = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as! String
        let buildNumber = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleVersion") as! String
        
        NSUserDefaults.standardUserDefaults().setValue("\(versionNumber) (\(buildNumber))", forKey: "EIApplicationVersion")
        
        DDLogInfo("Version: \(versionNumber) (\(buildNumber))")
    }
}