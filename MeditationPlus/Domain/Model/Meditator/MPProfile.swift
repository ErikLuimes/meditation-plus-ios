//
//  MPProfile.swift
//  MeditationPlus
//
//  Created by Erik Luimes on 25/10/15.
//  Copyright (c) 2015 Maya Interactive. All rights reserved.
//

import Foundation
import ObjectMapper

/*
{
	"uid": "430",
	"username": "",
	"show_email": "0",
	"website": "",
	"description": "",
	"country": "CA",
	"img": "",
	"email": null,
	"hours": [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
	"can_edit": "false"
}
*/
class MPProfile: NSObject, Mappable
{
    var uid: String?
    var username: String?
    var email: String?
    var hours: [Int]?
    var img: String?
    var country: String?
    var website: String?
    var showEmail: String?

    required init?(_ map: Map) {
        super.init()
        self.mapping(map)
    }

    func mapping(map: Map) {
        uid       <- map["uid"]
        username  <- map["username"]
        email     <- map["email"]
        hours     <- map["hours"]
        img       <- map["img"]
        country   <- map["country"]
        website   <- map["website"]
        showEmail <- map["showEmail"]
    }
}
