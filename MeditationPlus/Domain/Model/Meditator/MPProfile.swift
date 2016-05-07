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

public class MPProfile: NSObject, Mappable
{
    public var uid: String?
    public var username: String?
    public var email: String?
    public var hours: [Int]?
    public var img: String?
    public var country: String?
    public var website: String?
    public var showEmail: String?

    public required init?(_ map: Map)
    {
        super.init()
    }

    public func mapping(map: Map)
    {
        uid <- map["uid"]
        username <- map["username"]
        email <- map["email"]
        hours <- map["hours"]
        img <- map["img"]
        country <- map["country"]
        website <- map["website"]
        showEmail <- map["showEmail"]
    }
}
