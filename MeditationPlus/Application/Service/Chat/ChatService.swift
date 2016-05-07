//
//  ChatService.swift
//  MeditationPlus
//
//  Created by Erik Luimes on 06/05/16.
//  Copyright © 2016 Maya Interactive. All rights reserved.
//

import Foundation
import RealmSwift
import CryptoSwift
import CocoaLumberjack

protocol ChatServiceProtocol
{
    func reloadChatItemsIfNeeded(forceReload: Bool) -> Bool
    
    func chatItems(notificationBlock: (RealmCollectionChange<Results<MPChatItem>> -> Void)) -> (NotificationToken, Results<MPChatItem>)
}



public class ChatService: ChatServiceProtocol
{
    private var apiClient: ChatApiClientProtocol!
    
    private var dataStore: DataStore!
    
    private var cacheManager: CacheManager!
    
    private var authenticationManager: MTAuthenticationManager
    
    convenience init()
    {
        self.init(apiClient: ChatApiClient(), dataStore: DataStore(), cacheManager: CacheManager(), authenticationManager: MTAuthenticationManager.sharedInstance)
    }
    
    public init(apiClient: ChatApiClientProtocol, dataStore: DataStore, cacheManager: CacheManager, authenticationManager: MTAuthenticationManager)
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
    public func reloadChatItemsIfNeeded(forceReload: Bool = false) -> Bool
    {
        let cacheKey    = String(MPChatItem.self).sha256()
        let needsUpdate = forceReload ? forceReload : cacheManager.needsUpdate(cacheKey, timeout: 360)
        
        guard needsUpdate else {
            return false
        }
        
        guard let username = authenticationManager.loggedInUser?.username else {
            return false
        }
        
        let lastChatTimestamp: String = dataStore.chatItems.last?.timestamp ?? "0"
        
        apiClient.loadData(username, lastChatTimestamp: lastChatTimestamp)
        {
            (response: ApiResponse<[MPChatItem]>) in
            
            switch response {
            case ApiResponse.Success(let model):
                self.cacheManager.updateTimestampForCacheKey(cacheKey)
                self.dataStore.addOrUpdateObjects(model)
                break
            case ApiResponse.Failure(let error):
                DDLogError(error?.localizedDescription ?? "Failed retrieving 'ChatItems'")
                break
            }
        }
        
        return needsUpdate
    }
 
    /**
     Returns an array of chat items in the notification block
     
     - parameter notificationBlock: Realm notification block
     
     - returns: returns a tuple with a `NotificationToken` and realm `Results`
     */
    public func chatItems(notificationBlock: (RealmCollectionChange<Results<MPChatItem>> -> Void)) -> (NotificationToken, Results<MPChatItem>)
    {
        let results = dataStore.chatItems
        let token   = results.addNotificationBlock(notificationBlock)
        
        return (token, results)
    }
}