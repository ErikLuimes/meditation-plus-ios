//
// Created by Erik Luimes on 12/09/15.
// Copyright (c) 2015 Maya Interactive. All rights reserved.
//

import Foundation
import ObjectMapper

public class MPValueTransform {
    class public func transformIntString() -> TransformOf<Int, String> {
        return TransformOf<Int, String>(fromJSON: { (value: String?) -> Int? in
            // transform value from String? to Int?
            return value?.toInt()
        }, toJSON: { (value: Int?) -> String? in
            // transform value from Int? to String?
            if let value = value {
                return String(value)
            }
            return nil
        })
    }

    class public func transformTimeIntervalMinuteString() -> TransformOf<NSTimeInterval, String> {
        return TransformOf<NSTimeInterval, String>(fromJSON: { (value: String?) -> NSTimeInterval? in
            // transform value from String? to NSTimeInterval?
            if let minuteInt = value?.toInt() {
                return NSTimeInterval(Double(minuteInt * 60))
            }
            return nil
        }, toJSON: { (value: NSTimeInterval?) -> String? in
            // transform value from NSTimeInterval? to String?
            if let minuteInterval: NSTimeInterval = value {
                return String(Int(minuteInterval / 60) )
            }

            return nil
        })
    }

    class public func transformDateEpochString() -> TransformOf<NSDate, String> {
        return TransformOf<NSDate, String>(fromJSON: { (value: String?) -> NSDate? in
            var date: NSDate?

            if let dateInteger = value?.toInt() {
                date = NSDate(timeIntervalSince1970: Double(dateInteger))
            }

            return date
        }, toJSON: { (value: NSDate?) -> String? in
            var epochString : String?

            if let epochTimeInterval = value?.timeIntervalSince1970 {
                epochString = String(stringInterpolationSegment: epochTimeInterval)
            }

            return epochString
        })
    }
}