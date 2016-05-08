//
//  MPChatItem.swift
//  MeditationPlus
//
//  Created by Erik Luimes on 13/09/15.
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
import DTCoreText
import RealmSwift

public class MPChatItem: Object, Mappable
{
    dynamic public var uid: String?
    dynamic public var cid: String?
    dynamic public var username: String?
    dynamic public var message: String?
    dynamic public var time: NSDate?
    dynamic public var timestamp: String?
    dynamic public var country: String?
    dynamic public var me: Bool = false
    dynamic public var attributedTextData: NSData?
    
    lazy public var attributedText: NSAttributedString? = {
        guard let data = self.attributedTextData else {
            return nil
        }
        
        return NSKeyedUnarchiver.unarchiveObjectWithData(data) as? NSAttributedString
    }()
    
    public var profile: MPProfile?
    public var avatarURL: NSURL?

    convenience public init(username: String, message: String)
    {
        self.init()
        self.username = username
        self.message = message
        self.time = NSDate()
        self.me = true
    }


    // MARK: Mappable

    required convenience public init?(_ map: Map)
    {
        self.init()
    }
    
    override public static func primaryKey() -> String?
    {
        return "cid"
    }

    override public class func indexedProperties() -> [String]
    {
        return ["uid", "time"]
    }
    
    override public static func ignoredProperties() -> [String] {
        return ["attributedText", "profile", "avatarURL"]
    }

    public func mapping(map: Map)
    {
        uid <- map["uid"]
        cid <- map["cid"]
        username <- map["username"]
        message <- map["message"]
        time <- (map["time"], MPValueTransform.transformDateEpochString())
        timestamp <- map["time"]
        country <- map["country"]
        me <- (map["me"], MPValueTransform.transformBoolString())

        createAttributedText()
    }

    public func createAttributedText()
    {
        let regExp = MPTextManager.sharedInstance.regExp

        if let message = self.message {
            let font = UIFont.systemFontOfSize(15)

            // Html parsing
            let modified = NSString(format: "<span style=\"font-family: \(font.fontName); font-size: \(font.pointSize)\">%@</span>", message) as String
            let attributedString = NSMutableAttributedString(HTMLData: modified.dataUsingEncoding(NSUnicodeStringEncoding, allowLossyConversion: true)!, options: [DTUseiOS6Attributes: true], documentAttributes: nil)

            // Emoji parsing
            let matches = regExp.matchesInString(attributedString.mutableString as String, options: NSMatchingOptions(), range: NSMakeRange(0, (attributedString.mutableString as String).characters.count))

            for result: NSTextCheckingResult in matches.reverse() {
                let match = (message as NSString).substringWithRange(result.range)
                let textAttachment = NSTextAttachment()
                if let imageName = MPTextManager.sharedInstance.emoticons[match] {
                    textAttachment.image = UIImage(named: imageName)
                }

                let replacementForTemplate = NSAttributedString(attachment: textAttachment)
                attributedString.replaceCharactersInRange(result.range, withAttributedString: replacementForTemplate)
            }

            attributedTextData = NSKeyedArchiver.archivedDataWithRootObject(attributedString)
        }

    }
}
