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

class MPChatItem: NSObject, Mappable {
    var uid:      String?
    var cid:      String?
    var username: String?
    var message:  String?
    var time:     NSDate?
    var country:  String?
    var me:       Bool?
    var attributedText: NSAttributedString?
    var profile: MPProfile?
    var avatarURL: NSURL?

    init(username: String, message: String) {
        self.username = username
        self.message  = message
        self.time     = NSDate()
        self.me       = true
    }
    

    // MARK: Mappable

    required init?(_ map: Map) {
        super.init()
        self.mapping(map)
    }

    func mapping(map: Map) {
        self.uid      <- map["uid"]
        self.cid      <- map["cid"]
        self.username <- map["username"]
        self.message  <- map["message"]
        self.time     <- (map["time"],     MPValueTransform.transformDateEpochString())
        self.country  <- map["country"]
        self.me       <- map["me"]
        
        createAttributedText()
    }
    
    func createAttributedText() {
        let regExp = MPTextManager.sharedInstance.regExp
        
        if let message = self.message {
            let font = UIFont.systemFontOfSize(15)
            
            // Html parsing
            let modified         = NSString(format:"<span style=\"font-family: \(font.fontName); font-size: \(font.pointSize)\">%@</span>", message) as String
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
            
            attributedText = attributedString
        }
        
    }
}
