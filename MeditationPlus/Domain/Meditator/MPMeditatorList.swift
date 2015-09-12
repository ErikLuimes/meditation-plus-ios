//
// Created by Erik Luimes on 12/09/15.
// Copyright (c) 2015 Maya Interactive. All rights reserved.
//

import Foundation
import ObjectMapper

class MPMeditatorList: Mappable {
    var meditators: [MPMeditator]?

    class func newInstance(map: Map) -> Mappable? {
        return MPMeditatorList()
    }

    func mapping(map: Map) {
        self.meditators <- map["list"]
    }
}