//
//  AuthenticationManager.swift
//  MeditationPlus
//
//  Created by Erik Luimes on 21/06/15.
//
//  The MIT License
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
//
// Except as contained in this notice, the name of Maya Interactive and Meditation+
// shall not be used in advertising or otherwise to promote the sale, use or other
// dealings in this Software without prior written authorization from Maya Interactive.
//

import Foundation
import Locksmith
import Alamofire
import AlamofireObjectMapper

public class AuthenticationManager
{
    static let sharedInstance = AuthenticationManager()
    
    var loggedInUser: User?

    var token: Token?

    var rememberPassword: Bool {
        get {
            return NSUserDefaults.standardUserDefaults().boolForKey("rememberPassword")
        }
        set {
            return NSUserDefaults.standardUserDefaults().setBool(newValue, forKey: "rememberPassword")
        }
    }

    var isLoggedIn: Bool {
        return self.loggedInUser != nil
    }

    func loginWithUsername(username: String, password: String, failure: ((error: NSError?, errorString: NSString?) -> Void)? = nil, completion: (User) -> Void) {
        let endpoint = "http://meditation.sirimangalo.org/post.php"
        let parameters = ["username": username, "password": password, "submit": "Login", "source": "ios"]

        if let cookies = NSHTTPCookieStorage.sharedHTTPCookieStorage().cookies {
            for cookie in cookies {
                NSHTTPCookieStorage.sharedHTTPCookieStorage().deleteCookie(cookie)
            }
        }

        UIApplication.sharedApplication().networkActivityIndicatorVisible = true

        Alamofire.request(.POST, endpoint, parameters: parameters).responseObject {
            (response: Response<Token, NSError>) in

            UIApplication.sharedApplication().networkActivityIndicatorVisible = false

            guard response.result.isSuccess else {
                print("Error while fetching remote rooms: \(response.result.error)")
                failure?(error: nil, errorString: nil)
                return
            }

            guard (response.result.value?.token) != nil else {
                return
            }

            self.loggedInUser = User(username: username, password: self.rememberPassword ? password : nil)
            do {
                try self.loggedInUser?.deleteFromSecureStore()
            } catch {
                NSLog("Failed deleting account from secure storage")
            }

            do {
                try self.loggedInUser?.createInSecureStore()
            } catch {
                NSLog("Failed creating account in secure storage")
            }

            self.token = response.result.value!
            
            ProfileService.sharedInstance.reloadProfileIfNeeded(username, forceReload: true)
            {
                (result) in
                
                if result.isSuccess() {
                    completion(self.loggedInUser!)
                } else {
                    self.logout()
                    failure?(error: result.error, errorString: "Failed retrieving profile")
                }
            }
        }
    }

    func logout() -> Void {
        self.loggedInUser = nil
        if self.token != nil {
            do {
                try self.token?.deleteFromSecureStore()
            } catch {
            }
            self.token = nil
        }
    }
}
