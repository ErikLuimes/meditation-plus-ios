//
//  Meditator.swift
//  MeditationPlus
//
//  Created by Erik Luimes on 12/09/15.
//
//  The MIT License
//  Copyright (c) 2015 Maya Interactive. All rights reserved.
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
import ObjectMapper
import RealmSwift

public class Meditator: Object, Mappable
{
    dynamic public var sid: String = ""
    dynamic public var username: String = ""
    dynamic public var avatarString: String?
    dynamic public var country: String?
    dynamic public var me: Bool = false
    
    dynamic public var start: NSDate?
    dynamic public var end: NSDate?
    
    public let timeDiff: RealmOptional<Double> = RealmOptional<Double>()
    public let walkingMinutes: RealmOptional<Int> = RealmOptional<Int>()
    public let sittingMinutes: RealmOptional<Int> = RealmOptional<Int>()
    public let anumodana: RealmOptional<Int> = RealmOptional<Int>()
    
    lazy public var avatar: NSURL? = {
        guard self.avatarString != nil else {
           return nil
        }
        
        return NSURL(string: self.avatarString!)
    }()

    required convenience public init?(_ map: Map)
    {
        self.init()
    }
    
    override public class func primaryKey() -> String
    {
        return "sid"
    }
    
    override public class func indexedProperties() -> [String]
    {
        return ["username", "me", "country", "start"]
    }
    
    override public class func ignoredProperties() -> [String]
    {
        return ["avatar"]
    }
    
    public func mapping(map: Map)
    {
        self.sid                  <- map["sid"]
        self.username             <- map["username"]
        self.avatarString         <- map["avatar"]
        self.walkingMinutes.value <- (map["walking"], ValueTransform.transformIntString())
        self.sittingMinutes.value <- (map["sitting"], ValueTransform.transformIntString())
        self.anumodana.value      <- (map["anumodana"], ValueTransform.transformIntString())
        self.country              <- map["country"]
        self.start                <- (map["start"], ValueTransform.transformDateEpochString())
        self.end                  <- (map["end"], ValueTransform.transformDateEpochString())
        self.me                   <- (map["me"], ValueTransform.transformBoolString())

        if let startDate = self.start, endDate: NSDate = self.end {
            self.timeDiff.value = endDate.timeIntervalSinceDate(startDate)
        }
    }

    // Meditation progress
    public var normalizedProgress: Double
    {
        var progress: Double = 1.0

        if let meditationTotal = self.timeDiff.value, meditationEndTime = self.end where meditationTotal > 0 {
            let timeLeft = meditationEndTime.timeIntervalSinceNow
            progress = clamp((meditationTotal - timeLeft) / meditationTotal, lowerBound: 0, upperBound: 1)
        }

        return progress
    }
}
