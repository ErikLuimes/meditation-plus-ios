//
//  MPValueTransform.swift
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