//
//  LogFormatter.swift
//  MeditationPlus
//
//  Created by Erik Luimes on 07/05/16.
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