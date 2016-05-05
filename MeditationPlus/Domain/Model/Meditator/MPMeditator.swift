//
//  MPMeditator.swift
//  MeditationPlus
//
//  Created by Erik Luimes on 12/09/15.
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
import ObjectMapper

class MPMeditator: NSObject, Mappable
{
    var username: String = ""
    var avatar: NSURL?
    var start: NSDate?
    var end: NSDate?
    var timeDiff: NSTimeInterval?
    var walkingMinutes: Int?
    var sittingMinutes: Int?
    var anumodanaMinutes: Int?
    var country: String?
    var me: Bool?


    override init()
    {
        super.init()
    }

    // MARK: Mappable

    required init?(_ map: Map)
    {
        super.init()
        self.mapping(map)
    }

    func mapping(map: Map)
    {
        self.username <- map["username"]
        self.avatar <- (map["avatar"], URLTransform())
        self.walkingMinutes <- (map["walking"], MPValueTransform.transformIntString())
        self.sittingMinutes <- (map["sitting"], MPValueTransform.transformIntString())
        self.anumodanaMinutes <- (map["anumodana"], MPValueTransform.transformIntString())
        self.country <- map["country"]
        self.start <- (map["start"], MPValueTransform.transformDateEpochString())
        self.end <- (map["end"], MPValueTransform.transformDateEpochString())
        self.me <- (map["me"], MPValueTransform.transformBoolString())

        if let startDate = self.start, endDate: NSDate = self.end {
            self.timeDiff = endDate.timeIntervalSinceDate(startDate)
        }
    }

    // Meditation progress
    var normalizedProgress: Double
    {
        var progress: Double = 1.0

        if let meditationTotal = self.timeDiff, meditationEndTime = self.end where meditationTotal > 0 {
            let timeLeft = meditationEndTime.timeIntervalSinceNow
            progress = clamp((meditationTotal - timeLeft) / meditationTotal, lowerBound: 0, upperBound: 1)
        }

        return progress
    }
}
