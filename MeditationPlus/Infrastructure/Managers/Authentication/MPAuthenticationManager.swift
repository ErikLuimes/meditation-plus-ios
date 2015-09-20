//
// Created by Erik Luimes on 21/06/15.
// Copyright (c) 2015 Maya Interactive. All rights reserved.
//

import Foundation
import Locksmith
import Alamofire
import AlamofireObjectMapper

class MTAuthenticationManager {
    static let sharedInstance = MTAuthenticationManager()
    
    private (set) var token: String?
//    {
//        get {
//            let (dictionary, error) = Locksmith.loadDataForUserAccount("token")
//            return dictionary?["token"] as? String
//        }
//
//        set {
//            if let token = newValue {
//                let error = Locksmith.updateData(["token": token], forUserAccount: "token")
//            } else {
//                let error = Locksmith.deleteDataForUserAccount("token")
//            }
//        }
//    }
    
    private (set) var username: String?
//    {
//        get {
//            let (dictionary, error) = Locksmith.loadDataForUserAccount("username")
//            return dictionary?["username"] as? String
//        }
//
//        set {
//            if let username = newValue {
//                let error = Locksmith.updateData(["username": username], forUserAccount: "username")
//            } else {
//                let error = Locksmith.deleteDataForUserAccount("username")
//            }
//        }
//    }

    private (set) var password: String?
//    {
//        get {
//            let (dictionary, error) = Locksmith.loadDataForUserAccount("password")
//            return dictionary?["password"] as? String
//        }
//
//        set {
//            if let password = newValue {
//                let error = Locksmith.updateData(["password": password], forUserAccount: "password")
//            } else {
//                let error = Locksmith.deleteDataForUserAccount("password")
//            }
//        }
//    }

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
            credentialsCompleted = password.characters.count > 0 && username.characters.count > 0
        }
        
        return credentialsCompleted
    }

    var isLoggedIn: Bool { return self.loggedInUser != nil }
    
    func loginWithUsername(username: String, password: String,failure: ((NSError?) -> Void)? = nil, completion: (MPUser) -> Void)
    {
        self.username = username
        self.password = password
        
        let endpoint   = "http://meditation.sirimangalo.org/post.php"
        let parameters = ["username": "erik", "password": "n3kaECQ471UB", "submit": "Login", "source": "ios"]
        
        Alamofire.request(.POST, endpoint, parameters: parameters).responseObject { (response: MPUser?, error: ErrorType?) in
            if let loggedInUser = response {
                loggedInUser.username = username
                
                if loggedInUser.token == nil {
                    self.loggedInUser = nil
                    self.token        = nil
                    failure?(nil)
                } else {
                    self.token    = loggedInUser.token
                    self.username = loggedInUser.username
                    completion(loggedInUser)
                }
            } else {
                if let unwrappedError = error {
                    NSLog("error: \(unwrappedError)")
                }
                failure?(nil)
            }
        }
    }
    
    func logout () -> Void {
        self.loggedInUser = nil
        self.token        = nil
        self.autologin    = false
    }
}
