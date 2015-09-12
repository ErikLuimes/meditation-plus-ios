//
// Created by Erik Luimes on 21/06/15.
// Copyright (c) 2015 Maya Interactive. All rights reserved.
//

import Foundation
import Locksmith
import AFNetworking

class MTAuthenticationManager {
    static let sharedInstance = MTAuthenticationManager()
    
    private (set) var token: String? {
        get {
            let (dictionary, error) = Locksmith.loadDataForUserAccount("token")
            return dictionary?["token"] as? String
        }

        set {
            if let token = newValue {
                let error = Locksmith.updateData(["token": token], forUserAccount: "token")
            } else {
                let error = Locksmith.deleteDataForUserAccount("token")
            }
        }
    }
    
    private (set) var username: String? {
        get {
            let (dictionary, error) = Locksmith.loadDataForUserAccount("username")
            return dictionary?["username"] as? String
        }

        set {
            if let username = newValue {
                let error = Locksmith.updateData(["username": username], forUserAccount: "username")
            } else {
                let error = Locksmith.deleteDataForUserAccount("username")
            }
        }
    }

    private (set) var password: String? {
        get {
            let (dictionary, error) = Locksmith.loadDataForUserAccount("password")
            return dictionary?["password"] as? String
        }

        set {
            if let password = newValue {
                let error = Locksmith.updateData(["password": password], forUserAccount: "password")
            } else {
                let error = Locksmith.deleteDataForUserAccount("password")
            }
        }
    }

    private (set) var autologin: Bool {
        get {
            return NSUserDefaults.standardUserDefaults().boolForKey("autologin")
        }

        set {
            NSUserDefaults.standardUserDefaults().setBool(newValue, forKey: "autologin")
        }
    }
    
    var loggedInUser: MPUser?

    var credentialsCompleted: Bool {
        var credentialsCompleted: Bool = false
        
        if let password = self.password, username = self.username {
            credentialsCompleted = count(password) > 0 && count(username) > 0
        }
        
        return credentialsCompleted
    }

    var isLoggedIn: Bool { return self.loggedInUser != nil }
    
    func loginWithUsername(username: String, password: String,failure: ((NSError?) -> Void)? = nil, completion: (MPUser) -> Void) {
        self.username = username
        self.password = password
        
        let parameters = ["username": username, "password": password, "submit": "Login"]
        let manager    = AFHTTPRequestOperationManager()
        let endpoint   = "http://meditation.sirimangalo.org/post.php"

        var jsonResponseSerializer : AFJSONResponseSerializer = AFJSONResponseSerializer()
        var acceptableContentTypes = NSMutableSet(set: jsonResponseSerializer.acceptableContentTypes!)
        acceptableContentTypes.addObject("text/html")
        
        jsonResponseSerializer.acceptableContentTypes = acceptableContentTypes as Set
        manager.responseSerializer = jsonResponseSerializer

        manager.POST(
            endpoint,
            parameters: parameters,
            success: { (operation: AFHTTPRequestOperation!, responseObject: AnyObject?) in
                if let jsonResponse = responseObject as? [String: AnyObject], token = jsonResponse["login_token"] as? String {
                    let user = MPUser(username)
                    
                    self.loggedInUser = user
                    self.token        = token
                    NSLog("login token: \(token)")
                    
                    completion(user)
                } else {
                    NSLog("Failed logging in")
                    failure?(nil)
                }
            },
            failure: { (operation: AFHTTPRequestOperation!, error: NSError!) in
                NSLog("error: \(error.localizedDescription)")
                self.token        = nil
                self.loggedInUser = nil
                failure?(nil)
            }
        )
    }
    
    func logout () -> Void {
        self.loggedInUser = nil
        self.token        = nil
        self.password     = nil
        self.autologin    = false
        
//        if let username = self.username {
//            let parameters = ["username": username, "submit": "Logout"]
//            let manager    = AFHTTPRequestOperationManager()
//            let endpoint   = "http://meditation.sirimangalo.org/post.php"
//
//            manager.POST(endpoint, parameters: parameters, success: nil, failure: nil)
//        }
    }
}
