//
// Created by Erik Luimes on 12/09/15.
// Copyright (c) 2015 Maya Interactive. All rights reserved.
//

import Foundation
import ObjectMapper

/*
		"username": "Tim",
		"avatar": "http:\/\/www.gravatar.com\/avatar\/10c416f030a8333ed4d149db6a1d1b2c?d=wavatar&s=140",
		"start": "1442061512",
		"end": "1442065112",
		"walking": "30",
		"sitting": "30",
		"country": "US",
		"type": null,
		"sid": "11898",
		"anumodana": "0",
		"anu_me": "0",
		"can_edit": "false",
		"me": "false"
*/
class MPMeditator: Mappable {
    var username:         String = ""
    var avatar:           NSURL?
    var start:            NSDate?
    var end:              NSDate?
    var timeDiff:         NSTimeInterval?
    var walkingMinutes:   Int?
	var sittingMinutes:   Int?
    var anumodanaMinutes: Int?
	var country:          String?
	var me:               Bool?

    // MARK: Mappable

    class func newInstance(map: Map) -> Mappable? {
        return MPMeditator()
    }

	func mapping(map: Map) {
		self.username         <- map["username"]
		self.avatar           <- (map["avatar"],    URLTransform())
		self.walkingMinutes   <- (map["walking"],   MPValueTransform.transformIntString())
		self.sittingMinutes   <- (map["sitting"],   MPValueTransform.transformIntString())
        self.anumodanaMinutes <- (map["anumodana"], MPValueTransform.transformIntString())
        self.country          <- map["country"]
        self.start            <- (map["start"],     MPValueTransform.transformDateEpochString())
        self.end              <- (map["end"],       MPValueTransform.transformDateEpochString())
        self.me               <- map["me"]
        
        if let startDate = self.start, endDate: NSDate = self.end {
            self.timeDiff = endDate.timeIntervalSinceDate(startDate)
        }
	}
    
    var normalizedProgress: Double {
        var progress: Double = 0
        
        if let meditationTotal = self.timeDiff, meditationEndTime = self.end where meditationTotal > 0 {
            let timeLeft = meditationEndTime.timeIntervalSinceNow
            progress     = clamp(timeLeft / meditationTotal, 0, 1)
        }
        
        return progress
    }
}