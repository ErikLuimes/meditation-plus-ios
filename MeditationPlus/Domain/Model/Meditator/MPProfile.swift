//
//  MPProfile.swift
//  MeditationPlus
//
//  Created by Erik Luimes on 25/10/15.
//  Copyright (c) 2015 Maya Interactive. All rights reserved.
//

import Foundation
import ObjectMapper
import RealmSwift

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

public class MPProfile: Object, Mappable
{
    public dynamic var uid: String?
    public dynamic var username: String?
    public dynamic var email: String?
    public dynamic var hoursData: NSData?
    public dynamic var img: String?
    public dynamic var country: String?
    public dynamic var website: String?
    public dynamic var showEmail: String?
    
    lazy public var hours: Array<Int>? = {
        guard let data = self.hoursData else {
            return nil
        }
        
        return NSKeyedUnarchiver.unarchiveObjectWithData(data) as? Array<Int>
    }()
    
    required convenience public init?(_ map: Map)
    {
        self.init()
    }
    
    override public static func primaryKey() -> String?
    {
        return "uid"
    }
    
    override public class func indexedProperties() -> [String]
    {
        return ["username", "email"]
    }
    
    override public static func ignoredProperties() -> [String] {
        return ["hours"]
    }

    public func mapping(map: Map)
    {
        uid <- map["uid"]
        username <- map["username"]
        email <- map["email"]
        hoursData <- (map["hours"], MPValueTransform.transformNSDataArray())
        img <- map["img"]
        country <- map["country"]
        website <- map["website"]
        showEmail <- map["showEmail"]
    }
}
