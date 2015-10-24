//
//  MPQuoteManager.swift
//  MeditationPlus
//
//  Created by Erik Luimes on 24/10/15.
//  Copyright (c) 2015 Maya Interactive. All rights reserved.
//

import Foundation
import Alamofire

class MPQuoteManager
{
    private let authenticationManager = MTAuthenticationManager.sharedInstance

    func retrieveQuote(completion: (MPQuote -> Void)?)
    {
        if let username: String = self.authenticationManager.loggedInUser?.username, token: String = self.authenticationManager.token?.token {
            let endpoint   = "http://meditation.sirimangalo.org/post.php"
            let parameters = ["username": username, "token": token, "submit": "Quote"]

            Alamofire.request(.POST, endpoint, parameters: parameters).validate(contentType: ["text/html"]).responseObject { (response: MPQuote?, error: ErrorType?) in
                if let quote = response {
                    completion?(quote)
                }
            }
        }
    }
}
