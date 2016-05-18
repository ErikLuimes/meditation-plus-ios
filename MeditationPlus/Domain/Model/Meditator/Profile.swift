//
//  Profile.swift
//  MeditationPlus
//
//  Created by Erik Luimes on 25/10/15.
//
//  The MIT License
//  Copyright (c) 2015 Maya Interactive. All rights reserved.
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
//
// Except as contained in this notice, the name of Maya Interactive and Meditation+
// shall not be used in advertising or otherwise to promote the sale, use or other
// dealings in this Software without prior written authorization from Maya Interactive.
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

extension NSURL
{
    public convenience init?(meditator: Meditator)
    {
        guard let avatarString = meditator.avatarString else {
            self.init(string: "http://www.gravatar.com/avatar/00000000000000000000000000000000?d=mm&f=y&s=140")
            return
        }
    
        if avatarString.rangeOfString("@") != nil {
            let emailhash = avatarString.lowercaseString.md5()
            self.init(string: "http://www.gravatar.com/avatar/\(emailhash)?d=mm&s=140")!
        } else if avatarString.characters.count > 0 {
            self.init(string: avatarString)
        } else {
            self.init(string: "http://www.gravatar.com/avatar/00000000000000000000000000000000?d=mm&f=y&s=140")
        }
    }
    
    public convenience init?(profile: Profile)
    {
        if let img = profile.img where img.characters.count > 0 {
            // In some case the email address is filled in here
            if img.rangeOfString("@") != nil {
                let emailhash = img.lowercaseString.md5()
                self.init(string: "http://www.gravatar.com/avatar/\(emailhash)?d=mm&s=140")!
            } else {
                self.init(string: img)
            }
            
        } else if let email = profile.email where email.characters.count > 0 {
            self.init(string: "http://www.gravatar.com/avatar/\(email.lowercaseString.md5())?d=wavatar&s=140")
        } else {
            self.init(string: "http://www.gravatar.com/avatar/00000000000000000000000000000000?d=mm&f=y&s=140")
        }
    }
}

public class Profile: Object, Mappable
{
    public dynamic var uid: String = ""
    public dynamic var username: String = ""
    public dynamic var about: String?
    public dynamic var email: String?
    public dynamic var hoursData: NSData?
    public dynamic var img: String?
    public dynamic var country: String?
    public dynamic var website: String?
    public dynamic var showEmail: String?
    
    lazy public var avatar: NSURL? = {
        return NSURL(profile: self)
    }()
    
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
        return ["hours", "avatar"]
    }

    public func mapping(map: Map)
    {
        uid <- map["uid"]
        username <- map["username"]
        about <- map["description"]
        email <- map["email"]
        hoursData <- (map["hours"], ValueTransform.transformNSDataArray())
        img <- map["img"]
        country <- map["country"]
        website <- map["website"]
        showEmail <- map["showEmail"]
    }
}
