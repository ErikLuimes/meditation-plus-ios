//
// Created by Erik Luimes on 12/09/15.
// Copyright (c) 2015 Maya Interactive. All rights reserved.
//

import Foundation
import AFNetworking

class MPMeditatorManager {
    private let authenticationManager = MTAuthenticationManager.sharedInstance

    func meditatorList(failure: ((NSError?) -> Void)? = nil, completion: ([MPMeditator]) -> Void) {
        if let username = self.authenticationManager.loggedInUser?.username, token = self.authenticationManager.token {
            let parameters = [
                    "username": username,
                    "token":    token,
            ]

            let manager    = AFHTTPRequestOperationManager()
            let endpoint   = "http://meditation.sirimangalo.org/db.php"

            var jsonResponseSerializer : AFJSONResponseSerializer = MPResponseObjectSerializer<MPMeditatorList>()
            var acceptableContentTypes = NSMutableSet(set: jsonResponseSerializer.acceptableContentTypes!)
            acceptableContentTypes.addObject("text/html")

            jsonResponseSerializer.acceptableContentTypes = acceptableContentTypes as Set
            manager.responseSerializer = jsonResponseSerializer

            manager.POST(
                endpoint,
                parameters: parameters,
                success: { (operation: AFHTTPRequestOperation!, responseObject: AnyObject?) in
                    if let meditatorList = responseObject as? MPMeditatorList where meditatorList.meditators != nil {
                        completion(meditatorList.meditators!)
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
    
    func startMeditation(sittingTimeInMinutes: Int?, walkingTimeInMinutes: Int?, completion: () -> Void, failure: ((NSError?) -> Void)? = nil) {
        if sittingTimeInMinutes == nil && walkingTimeInMinutes == nil { failure?(nil) }
        
        if let username = self.authenticationManager.loggedInUser?.username, token = self.authenticationManager.token {
            var parameters = [
                "username": username,
                "token":    token,
                "form_id":  "timeform",
                "source":   "ios"
            ]
            
            parameters["sitting"] = sittingTimeInMinutes == nil ? "" : String(sittingTimeInMinutes!)
            parameters["walking"] = walkingTimeInMinutes == nil ? "" : String(walkingTimeInMinutes!)

            let manager    = AFHTTPRequestOperationManager()
            let endpoint   = "http://meditation.sirimangalo.org/db.php"
//            let endpoint   = "http://massasolis.com"

            var jsonResponseSerializer = AFJSONResponseSerializer()
            var acceptableContentTypes = NSMutableSet(set: jsonResponseSerializer.acceptableContentTypes!)
            acceptableContentTypes.addObject("text/html")

            jsonResponseSerializer.acceptableContentTypes = acceptableContentTypes as Set
            manager.responseSerializer = jsonResponseSerializer

            manager.POST(
                endpoint,
                parameters: parameters,
                success: { (operation: AFHTTPRequestOperation!, responseObject: AnyObject?) in
                    completion()
                },
                failure: { (operation: AFHTTPRequestOperation!, error: NSError!) in
                    failure?(nil)
                }
            )

        }
    }
    
    func cancelMeditation(sittingTimeInMinutes: Int?, walkingTimeInMinutes: Int?, completion: () -> Void, failure: ((NSError?) -> Void)? = nil) {
        if let username = self.authenticationManager.loggedInUser?.username, token = self.authenticationManager.token {
            var parameters = [
                "username": username,
                "token":    token,
                "form_id":  "cancelform",
                "source":   "ios"
            ]
            
            parameters["sitting"] = sittingTimeInMinutes == nil ? "" : String(sittingTimeInMinutes!)
            parameters["walking"] = walkingTimeInMinutes == nil ? "" : String(walkingTimeInMinutes!)

            let manager    = AFHTTPRequestOperationManager()
            let endpoint   = "http://meditation.sirimangalo.org/db.php"
//            let endpoint   = "http://massasolis.com"

            var jsonResponseSerializer = AFJSONResponseSerializer()
            var acceptableContentTypes = NSMutableSet(set: jsonResponseSerializer.acceptableContentTypes!)
            acceptableContentTypes.addObject("text/html")

            jsonResponseSerializer.acceptableContentTypes = acceptableContentTypes as Set
            manager.responseSerializer = jsonResponseSerializer

            manager.POST(
                endpoint,
                parameters: parameters,
                success: { (operation: AFHTTPRequestOperation!, responseObject: AnyObject?) in
                    completion()
                },
                failure: { (operation: AFHTTPRequestOperation!, error: NSError!) in
                    failure?(nil)
                }
            )

        }
    }
}