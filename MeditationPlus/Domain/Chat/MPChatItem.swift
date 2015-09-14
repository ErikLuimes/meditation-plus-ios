//
// Created by Erik Luimes on 13/09/15.
// Copyright (c) 2015 Maya Interactive. All rights reserved.
//

import Foundation
import ObjectMapper

/*
[{
		"cid": "7404",
		"uid": "310",
		"username": "Ryan",
		"country": "US",
		"time": "1442062421",
		"message": "good morning (peace)",
		"me": "false",
		"can_edit": "false"
	}, {
	*/
class MPChatItem: Mappable {
    var uid:      String?
    var cid:      String?
    var username: String?
    var message:  String?
    var time:     NSDate?
    var country:  String?
    var me:       Bool?

    // MARK: Mappable
    init(username: String, message: String) {
        self.username = username
        self.message  = message
        self.time     = NSDate()
        self.me       = true
    }
    
    init() {
        
    }

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
