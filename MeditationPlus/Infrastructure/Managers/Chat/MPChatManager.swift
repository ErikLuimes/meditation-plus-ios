//
// Created by Erik Luimes on 13/09/15.
// Copyright (c) 2015 Maya Interactive. All rights reserved.
//

import Foundation
import Alamofire

class MPChatManager {
    private let authenticationManager = MTAuthenticationManager.sharedInstance

    func chatList(failure: ((NSError?) -> Void)? = nil, completion: ([MPChatItem]) -> Void) {
        if let username: String = self.authenticationManager.loggedInUser?.username {
            let endpoint                    = "http://meditation.sirimangalo.org/db.php"
            let parameters: [String:String] = ["username": username, "last_chat": "0"]
            
            Alamofire.request(.POST, endpoint, parameters: parameters).validate(contentType: ["text/html"]).responseObject { (response: MPChatList?, error: ErrorType?) in
                if let chats = response?.chats {
                    completion(chats)
                }
            }
        }
    }
}

