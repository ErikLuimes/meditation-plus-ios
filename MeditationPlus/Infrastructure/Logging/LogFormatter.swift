//
//  LogFormatter.swift
//  MeditationPlus
//
//  Created by Erik Luimes on 07/05/16.
//  Copyright © 2016 Maya Interactive. All rights reserved.
//

import Foundation
import CocoaLumberjack.DDDispatchQueueLogFormatter

class LogFormatter: DDDispatchQueueLogFormatter
{
    let threadUnsafeDateFormatter: NSDateFormatter
    
    lazy var bundleName: String = {
        guard let bundleName: String = NSBundle.mainBundle().infoDictionary?["CFBundleName"] as? String else {
            return ""
        }
        
        return bundleName
    }()
    
    override init()
    {
        threadUnsafeDateFormatter = NSDateFormatter()
        threadUnsafeDateFormatter.formatterBehavior = .Behavior10_4
        threadUnsafeDateFormatter.dateFormat = "YYYY-MM-dd HH:mm:ss.SSS"
        
        super.init()
    }
    
    override func formatLogMessage(logMessage: DDLogMessage!) -> String
    {
        let dateAndTime = threadUnsafeDateFormatter.stringFromDate(logMessage.timestamp)
        
        var logLevel: String
        let logFlag = logMessage.flag
        if logFlag.contains(.Error) {
            logLevel = "  ERROR"
        } else if logFlag.contains(.Warning) {
            logLevel = "WARNING"
        } else if logFlag.contains(.Info) {
            logLevel = "   INFO"
        } else if logFlag.contains(.Debug) {
            logLevel = "  DEBUG"
        } else if logFlag.contains(.Verbose) {
            logLevel = "VERBOSE"
        } else {
            logLevel = "      ?"
        }
        
        let formattedLog = "\(dateAndTime) \(logLevel) \(bundleName)[\(logMessage.queueLabel):\(logMessage.threadID)] (\(logMessage.fileName).\(logMessage.function):\(logMessage.line)) - \(logMessage.message)"
        
        return formattedLog;
    }
}