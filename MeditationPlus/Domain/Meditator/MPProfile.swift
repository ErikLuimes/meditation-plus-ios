//
//  MPProfile.swift
//  MeditationPlus
//
//  Created by Erik Luimes on 25/10/15.
//  Copyright (c) 2015 Maya Interactive. All rights reserved.
//

import Foundation
import ObjectMapper

class MPProfile: NSObject, Mappable
{
    required init?(_ map: Map) {
        super.init()
        self.mapping(map)
    }

    func mapping(map: Map) {
//        self.meditators <- map["list"]
    }
}
