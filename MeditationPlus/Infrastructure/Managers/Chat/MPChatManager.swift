//
// Created by Erik Luimes on 13/09/15.
// Copyright (c) 2015 Maya Interactive. All rights reserved.
//

import Foundation
import Alamofire

class MPChatManager {
    private let authenticationManager = MTAuthenticationManager.sharedInstance
    static var lastUpdateTimeStamp: String = "0"

    func chatList(failure: ((NSError?) -> Void)? = nil, completion: ([MPChatItem]) -> Void) {
        if let username: String = self.authenticationManager.loggedInUser?.username {
            let endpoint                    = "http://meditation.sirimangalo.org/db.php"
            let parameters: [String:String] = ["username": username, "last_chat": MPChatManager.lastUpdateTimeStamp]
            
            Alamofire.request(.POST, endpoint, parameters: parameters).validate(contentType: ["text/html"]).responseObject { (response: MPChatList?, error: ErrorType?) in
                
                if let chats = response?.chats where chats.count > 0  {
                    MPChatManager.lastUpdateTimeStamp = chats.last?.timestamp ?? "0"
                    completion(chats)
                }
            }
        }
    }
    
    func postMessage(message:String,  completion: ([MPChatItem]) -> Void, failure: ((NSError?) -> Void)? = nil) {
        if let username: String = self.authenticationManager.loggedInUser?.username {
            let endpoint                    = "http://meditation.sirimangalo.org/db.php"
            let parameters: [String:String] = [
                "username":  username,
                "form_id":   "chatform",
                "message":   message,
                "last_chat": MPChatManager.lastUpdateTimeStamp
            ]
            
            Alamofire.request(.POST, endpoint, parameters: parameters).validate(contentType: ["text/html"]).responseObject { (response: MPChatList?, error: ErrorType?) in
                if let chats = response?.chats where chats.count > 0  {
                    MPChatManager.lastUpdateTimeStamp = chats.last?.timestamp ?? "0"
                    completion(chats)
                } else {
                    failure?(nil)
                }
            }
        }
    }
}

