//
//  ChatService.swift
//  MeditationPlus
//
//  Created by Erik Luimes on 06/05/16.
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
import RealmSwift
import CryptoSwift
import CocoaLumberjack

protocol ChatServiceProtocol
{
    func reloadChatItemsIfNeeded(forceReload: Bool, completion: ((ServiceResult) -> Void)?) -> Bool
    
    func chatItems(notificationBlock: (RealmCollectionChange<Results<ChatItem>> -> Void)) -> (NotificationToken, Results<ChatItem>)
}

public class ChatService: ChatServiceProtocol
{
    private var apiClient: ChatApiClientProtocol!
    
    private var dataStore: DataStore!
    
    private var cacheManager: CacheManager!
    
    private var authenticationManager: AuthenticationManager
    
    convenience init()
    {
        self.init(apiClient: ChatApiClient(), dataStore: DataStore(), cacheManager: CacheManager(), authenticationManager: AuthenticationManager.sharedInstance)
    }
    
    public init(apiClient: ChatApiClientProtocol, dataStore: DataStore, cacheManager: CacheManager, authenticationManager: AuthenticationManager)
    {
        self.apiClient = apiClient
        self.dataStore = dataStore
        self.cacheManager = cacheManager
        self.authenticationManager = authenticationManager
    }
    
    /**
     Reloads the chat items from the api
     
     - parameter forceReload: force reload of chat items
     */
    public func reloadChatItemsIfNeeded(forceReload: Bool = false, completion: ((ServiceResult) -> Void)? = nil) -> Bool
    {
        let cacheKey    = String(ChatItem.self).sha256()
        let needsUpdate = forceReload ? forceReload : cacheManager.needsUpdate(cacheKey, timeout: 360)
        
        guard needsUpdate else {
            completion?(ServiceResult.Failure(nil))
            return false
        }
        
        guard let username = authenticationManager.loggedInUser?.username else {
            completion?(ServiceResult.Failure(nil))
            return false
        }
        
        let lastChatTimestamp: String = dataStore.chatItems.first?.timestamp ?? "0"
        
        apiClient.loadChatItems(username, lastChatTimestamp: lastChatTimestamp)
        {
            (response: ApiResponse<[ChatItem]>) in
            
            switch response {
            case ApiResponse.Success(let model):
                self.cacheManager.updateTimestampForCacheKey(cacheKey)
                self.dataStore.addOrUpdateObjects(model)
                completion?(ServiceResult.Success)
            case ApiResponse.NoData(_):
                completion?(ServiceResult.Success)
            case ApiResponse.Failure(let error):
                completion?(ServiceResult.Failure(nil))
                DDLogError(error?.localizedDescription ?? "Failed retrieving 'ChatItems'")
            }
        }
        
        return needsUpdate
    }
    
    public func postMessage(message: String, completionBlock: ((ServiceResult) -> Void)? = nil)
    {
        
        guard let username = authenticationManager.loggedInUser?.username else {
            return
        }
        
        let lastChatTimestamp: String = dataStore.chatItems.last?.timestamp ?? "0"
        
        apiClient.postMessage(username, message: message, lastChatTimestamp: lastChatTimestamp)
        {
            (response: ApiResponse<[ChatItem]>) in
            
            switch response {
            case ApiResponse.Success(let model):
                self.dataStore.addOrUpdateObjects(model)
                completionBlock?(ServiceResult.Success)
            case ApiResponse.NoData(_):
                completionBlock?(ServiceResult.Success)
            case ApiResponse.Failure(let error):
                DDLogError(error?.localizedDescription ?? "Failed retrieving 'ChatItems'")
                completionBlock?(ServiceResult.Failure(nil))
            }
        }
    }
 
    /**
     Returns an array of chat items in the notification block
     
     - parameter notificationBlock: Realm notification block
     
     - returns: returns a tuple with a `NotificationToken` and realm `Results`
     */
    public func chatItems(notificationBlock: (RealmCollectionChange<Results<ChatItem>> -> Void)) -> (NotificationToken, Results<ChatItem>)
    {
        let results = dataStore.chatItems
        let token   = results.addNotificationBlock(notificationBlock)
        
        return (token, results)
    }
}