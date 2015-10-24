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
    
    var loggedInUser: MPUser?
    
    var token: MPToken?
    
    var rememberPassword: Bool {
        get {
            return NSUserDefaults.standardUserDefaults().boolForKey("rememberPassword")
        }
        set {
            return NSUserDefaults.standardUserDefaults().setBool(newValue, forKey: "rememberPassword")
        }
    }
    
    var isLoggedIn: Bool { return self.loggedInUser != nil }
    
    func loginWithUsername(username: String, password: String,failure: ((NSError?) -> Void)? = nil, completion: (MPUser) -> Void)
    {
        let endpoint   = "http://meditation.sirimangalo.org/post.php"
        let parameters = ["username": username, "password": password, "submit": "Login"]
        
        Alamofire.request(.POST, endpoint, parameters: parameters).responseObject { (response: MPToken?, error: ErrorType?) in
            if let _ = response?.token {
                self.loggedInUser = MPUser(username: username, password: self.rememberPassword ? password : nil)
                try! self.loggedInUser?.deleteFromSecureStore()
                try! self.loggedInUser?.createInSecureStore()
                self.token = response!
                completion(self.loggedInUser!)
            } else {
                if let unwrappedError = error {
                    NSLog("error: \(unwrappedError)")
                }
                failure?(nil)
            }
        }
    }
    
    func logout() -> Void {
        self.loggedInUser = nil
        if self.token != nil {
            do { try self.token?.deleteFromSecureStore() } catch {}
            self.token = nil
        }
    }
}
