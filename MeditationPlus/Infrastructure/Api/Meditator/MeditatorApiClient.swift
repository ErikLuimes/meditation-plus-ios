//
//  MeditatorApiClient.swift
//  MeditationPlus
//
//  Created by Erik Luimes on 08/05/16.
//
//  The MIT License
//  Copyright (c) 2016 Maya Interactive. All rights reserved.
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
import AlamofireObjectMapper
import Alamofire
import ObjectMapper

public protocol MeditatorApiClientProtocol
{
    func loadMeditators(username: String, completionBlock: (ApiResponse<[Meditator]>) -> Void)
    
    func startMeditation(username: String, token: String, sittingTimeInMinutes: Int?, walkingTimeInMinutes: Int?, completionBlock: (ApiResponse<[Meditator]>) -> Void)
    
    func cancelMeditation(username: String, token: String, sittingTimeInMinutes: Int?, walkingTimeInMinutes: Int?, completionBlock: (ApiResponse<[Meditator]>) -> Void)
}

public class MeditatorApiClient: BaseApiClient, MeditatorApiClientProtocol
{
    public func loadMeditators(username: String, completionBlock: (ApiResponse<[Meditator]>) -> Void)
    {
        let endpoint = "http://meditation.sirimangalo.org/db.php"
        // Always post 'last_chat' date so that no chat data is returned
        let parameters: [String:AnyObject] = ["username": username, "last_chat": String(UInt(NSDate().timeIntervalSince1970))]
        
        super.loadArray(Alamofire.Method.POST, endpoint, parameters: parameters, keyPath: "list", completionBlock: completionBlock)
    }
    
    
    public func startMeditation(username: String, token: String, sittingTimeInMinutes: Int?, walkingTimeInMinutes: Int?, completionBlock: (ApiResponse<[Meditator]>) -> Void)
    {
        let endpoint = "http://meditation.sirimangalo.org/db.php"
        var parameters: [String:String] = [
                "username": username,
                "token": token,
                "form_id": "timeform",
                "last_chat": String(UInt(NSDate().timeIntervalSince1970)),
                "source": "ios"
        ]

        parameters["sitting"] = sittingTimeInMinutes == nil ? "" : String(sittingTimeInMinutes!)
        parameters["walking"] = walkingTimeInMinutes == nil ? "" : String(walkingTimeInMinutes!)

        super.loadArray(Alamofire.Method.POST, endpoint, parameters: parameters, keyPath: "list", completionBlock: completionBlock)
    }
    
    public func cancelMeditation(username: String, token: String, sittingTimeInMinutes: Int?, walkingTimeInMinutes: Int?, completionBlock: (ApiResponse<[Meditator]>) -> Void)
    {
        let endpoint = "http://meditation.sirimangalo.org/db.php"
        var parameters: [String:String] = [
                "username": username,
                "token": token,
                "form_id": "cancelform",
                "last_chat": String(UInt(NSDate().timeIntervalSince1970)),
                "source": "ios"
        ]

        parameters["sitting"] = sittingTimeInMinutes == nil ? "" : String(sittingTimeInMinutes!)
        parameters["walking"] = walkingTimeInMinutes == nil ? "" : String(walkingTimeInMinutes!)
        
        super.loadArray(Alamofire.Method.POST, endpoint, parameters: parameters, keyPath: "list", completionBlock: completionBlock)
    }
}