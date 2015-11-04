//
// Created by Erik Luimes on 13/09/15.
// Copyright (c) 2015 Maya Interactive. All rights reserved.
//

import Foundation
import Alamofire

class MPChatManager {
    private let authenticationManager = MTAuthenticationManager.sharedInstance
    static var lastUpdateTimeStamp: UInt64 = 0

    func chatList(failure: ((NSError?) -> Void)? = nil, completion: ([MPChatItem]) -> Void) {
        if let username: String = self.authenticationManager.loggedInUser?.username {
            let endpoint                    = "http://meditation.sirimangalo.org/db.php"
            let parameters: [String:String] = ["username": username, "last_chat": String(UInt64(MPChatManager.lastUpdateTimeStamp))]
            
            Alamofire.request(.POST, endpoint, parameters: parameters).validate(contentType: ["text/html"]).responseObject { (response: MPChatList?, error: ErrorType?) in
                MPChatManager.lastUpdateTimeStamp = UInt64(NSDate().timeIntervalSince1970)
                
                if let chats = response?.chats {
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
                "last_chat": String(UInt64(MPChatManager.lastUpdateTimeStamp))
            ]
            
            Alamofire.request(.POST, endpoint, parameters: parameters).validate(contentType: ["text/html"]).responseObject { (response: MPChatList?, error: ErrorType?) in
                MPChatManager.lastUpdateTimeStamp = UInt64(NSDate().timeIntervalSince1970)
                
                if let chats = response?.chats {
                    completion(chats)
                } else {
                    failure?(nil)
                }
            }
        }
    }
    
//    func startMeditation(sittingTimeInMinutes: Int?, walkingTimeInMinutes: Int?, completion: (() -> Void)? = nil, failure: ((NSError?) -> Void)? = nil) {
//        if sittingTimeInMinutes == nil && walkingTimeInMinutes == nil { failure?(nil) }
//        
//        if let username = self.authenticationManager.loggedInUser?.username {
//            let endpoint   = "http://meditation.sirimangalo.org/db.php"
//            let parameters: [String:String] = [
//                "username": username,
//                "form_id":  "chat",
//                "last_chat": String(UInt(NSDate().timeIntervalSince1970)),
//                "source":   "ios"
//            ]
//            
////            Alamofire.request(.POST, endpoint, parameters: parameters).validate(contentType: ["text/html"]).responseString(completionHandler: { (request, response, result) -> Void in
////                if response != nil {
////                    if response!.statusCode >= 200 && response!.statusCode < 300 {
////                        completion?()
////                    } else {
////                        failure?(nil)
////                    }
////                } else {
////                    failure?(nil)
////                }
////            })
//        }
//    }
}

