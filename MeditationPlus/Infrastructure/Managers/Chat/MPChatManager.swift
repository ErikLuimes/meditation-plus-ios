//
// Created by Erik Luimes on 13/09/15.
// Copyright (c) 2015 Maya Interactive. All rights reserved.
//

import Foundation
import AFNetworking

class MPChatManager {
    private let authenticationManager = MTAuthenticationManager.sharedInstance

    func chatList(failure: ((NSError?) -> Void)? = nil, completion: ([MPChatItem]) -> Void) {
        if let username = self.authenticationManager.loggedInUser, token = self.authenticationManager.token {
            let parameters = [
                    "username": username,
                    "token":    token,
            ]

            let manager    = AFHTTPRequestOperationManager()
            let endpoint   = "http://meditation.sirimangalo.org/db.php"

            var jsonResponseSerializer : AFJSONResponseSerializer = MPResponseObjectSerializer<MPChatList>()
            var acceptableContentTypes = NSMutableSet(set: jsonResponseSerializer.acceptableContentTypes!)
            acceptableContentTypes.addObject("text/html")

            jsonResponseSerializer.acceptableContentTypes = acceptableContentTypes as Set
            manager.responseSerializer = jsonResponseSerializer

            manager.POST(
                endpoint,
                parameters: parameters,
                success: { (operation: AFHTTPRequestOperation!, responseObject: AnyObject?) in
                    if let chatList = responseObject as? MPChatList where chatList.chats != nil {
                        completion(chatList.chats!)
                    } else {
                        failure?(nil)
                    }

                },
                failure: { (operation: AFHTTPRequestOperation!, error: NSError!) in
                    failure?(nil)
                }
            )
        }
    }
}

