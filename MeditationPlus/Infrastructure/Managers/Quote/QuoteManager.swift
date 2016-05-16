//
//  QuoteManager.swift
//  MeditationPlus
//
//  Created by Erik Luimes on 24/10/15.
//  Copyright (c) 2015 Maya Interactive.
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

class MPQuoteManager
{
    private let authenticationManager = AuthenticationManager.sharedInstance

    func retrieveQuote(completion: (Quote -> Void)?)
    {
        if let username: String = self.authenticationManager.loggedInUser?.username, token: String = self.authenticationManager.token?.token {
            let endpoint = "http://meditation.sirimangalo.org/post.php"
            let parameters: [String:AnyObject] = ["username": username, "token": token, "submit": "Quote"]

            Alamofire.request(.POST, endpoint, parameters: parameters).validate(contentType: ["text/html"]).responseObject
            {
                (response: Response<Quote, NSError>) in
                
                if let quote = response.result.value {
                    completion?(quote)
                }
            }
        }
    }
}
