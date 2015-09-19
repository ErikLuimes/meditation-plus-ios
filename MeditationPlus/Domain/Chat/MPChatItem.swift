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

class MPChatItem: Mappable {
    var uid:      String?
    var cid:      String?
    var username: String?
    var message:  String?
    var time:     NSDate?
    var country:  String?
    var me:       Bool?

    init(username: String, message: String) {
        self.username = username
        self.message  = message
        self.time     = NSDate()
        self.me       = true
    }
    
    init() {
        
    }

    // MARK: Mappable

    class func newInstance(map: Map) -> Mappable? {
        return MPChatItem()
    }

    func mapping(map: Map) {
        self.uid      <- map["uid"]
        self.cid      <- map["cid"]
        self.username <- map["username"]
        self.message  <- map["message"]
        self.time     <- (map["time"],     MPValueTransform.transformDateEpochString())
        self.country  <- map["country"]
        self.me       <- map["me"]
    }
}
