//
//  ChatApiClient.swift
//  MeditationPlus
//  
//  Created by Erik Luimes on 06/05/16
//  Copyright (c) 2016 Maya Interactive. All rights reserved.
//
// The MIT License (MIT)
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
import AlamofireObjectMapper
import Alamofire

public protocol ChatApiClientProtocol
{
    func loadChatItems(username: String, lastChatTimestamp: String, completionBlock: (ApiResponse<[MPChatItem]>) -> Void)
    
    func postMessage(username: String, message: String, lastChatTimestamp: String, completionBlock: (ApiResponse<[MPChatItem]>) -> Void)
}

public class ChatApiClient: BaseApiClient, ChatApiClientProtocol
{
    public func loadChatItems(username: String, lastChatTimestamp: String, completionBlock: (ApiResponse<[MPChatItem]>) -> Void)
    {
        let endpoint: String = "http://meditation.sirimangalo.org/db.php"
        let parameters: [String:AnyObject] = ["username": username, "last_chat": lastChatTimestamp]
        
        super.loadArray(Alamofire.Method.POST, endpoint, parameters: parameters, keyPath: "chat", completionBlock: completionBlock)
    }
    
    public func postMessage(username: String, message: String, lastChatTimestamp: String, completionBlock: (ApiResponse<[MPChatItem]>) -> Void)
    {
        let endpoint = "http://meditation.sirimangalo.org/db.php"
        let parameters: [String:AnyObject] = [
            "username": username,
            "form_id": "chatform",
            "message": message,
            "last_chat": MPChatManager.lastUpdateTimeStamp
        ]
        
        super.loadArray(Alamofire.Method.POST, endpoint, parameters: parameters, keyPath: "chat", completionBlock: completionBlock)
    }
}
