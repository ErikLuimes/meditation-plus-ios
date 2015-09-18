//
// Created by Erik Luimes on 13/09/15.
// Copyright (c) 2015 Maya Interactive. All rights reserved.
//

import Foundation
import ObjectMapper

class MPChatList: Mappable {
    var chats: [MPChatItem]?

    class func newInstance(map: Map) -> Mappable? {
        return MPChatList()
    }

    func mapping(map: Map) {
        self.chats <- map["chat"]
    }
}
