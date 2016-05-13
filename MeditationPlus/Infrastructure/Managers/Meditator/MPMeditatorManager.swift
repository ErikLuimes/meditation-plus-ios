//
//  MPMeditationManager.swift
//  MeditationPlus
//
//  Created by Erik Luimes on 12/09/15.
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

import Foundation
import Alamofire
import AlamofireObjectMapper

class MPMeditatorManager {
    private let authenticationManager = MTAuthenticationManager.sharedInstance

    func meditatorList(completion: ([MPMeditator] -> Void)?) {
        if let username: String = self.authenticationManager.loggedInUser?.username {
            let endpoint = "http://meditation.sirimangalo.org/db.php"
            // Always post 'last_chat' date so that no chat data is returned
            let parameters: [String:AnyObject] = ["username": username, "last_chat": String(UInt(NSDate().timeIntervalSince1970))]


            Alamofire.request(.POST, endpoint, parameters: parameters).validate(contentType: ["text/html"]).responseObject {
                (response: Response<MPMeditatorList, NSError>) in

                if let meditators = response.result.value?.meditators {
                    dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), {
                        for m in meditators {
                            if let avatar = m.avatar where m.me == true {
                                NSUserDefaults.standardUserDefaults().setURL(avatar, forKey: "avatar")
                            }
                        }

                        dispatch_async(dispatch_get_main_queue(), {
                            () -> Void in
                            completion?(meditators)
                        })
                    })

                }
            }
        }
    }

    func startMeditation(sittingTimeInMinutes: Int?, walkingTimeInMinutes: Int?, completion: (() -> Void)? = nil, failure: ((NSError?) -> Void)? = nil) {
        if sittingTimeInMinutes == nil && walkingTimeInMinutes == nil {
            failure?(nil)
        }

        if let username = self.authenticationManager.loggedInUser?.username, token = self.authenticationManager.token?.token {
            let endpoint = "http://meditation.sirimangalo.org/db.php"
            var parameters: [String:String] = [
                "username"  : username,
                "token"     : token,
                "form_id"   : "timeform",
                "last_chat" : String(UInt(NSDate().timeIntervalSince1970)),
                "source"    : "ios"
            ]

            parameters["sitting"] = sittingTimeInMinutes == nil ? "" : String(sittingTimeInMinutes!)
            parameters["walking"] = walkingTimeInMinutes == nil ? "" : String(walkingTimeInMinutes!)

            Alamofire.request(.POST, endpoint, parameters: parameters).validate(contentType: ["text/html"]).responseString(completionHandler: {
                (response) -> Void in

                guard response.result.isSuccess else {
                    failure?(nil)
                    return
                }

                completion?()
            })
        }
    }

    func cancelMeditation(sittingTimeInMinutes: Int?, walkingTimeInMinutes: Int?, completion: (() -> Void)? = nil, failure: ((NSError?) -> Void)? = nil) {
        if sittingTimeInMinutes == nil && walkingTimeInMinutes == nil {
            failure?(nil)
        }

        if let username = self.authenticationManager.loggedInUser?.username, token = self.authenticationManager.token?.token {
            let endpoint = "http://meditation.sirimangalo.org/db.php"
            var parameters: [String:String] = [
                "username"  : username,
                "token"     : token,
                "form_id"   : "cancelform",
                "last_chat" : String(UInt(NSDate().timeIntervalSince1970)),
                "source"    : "ios"
            ]

            parameters["sitting"] = sittingTimeInMinutes == nil ? "" : String(sittingTimeInMinutes!)
            parameters["walking"] = walkingTimeInMinutes == nil ? "" : String(walkingTimeInMinutes!)

            Alamofire.request(.POST, endpoint, parameters: parameters).validate(contentType: ["text/html"]).responseString(completionHandler: {
                (response) -> Void in

                response.result.isSuccess ? completion?() : failure?(nil)
            })
        }
    }
}
