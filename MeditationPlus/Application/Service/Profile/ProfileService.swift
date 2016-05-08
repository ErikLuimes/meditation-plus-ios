//
//  ProfileService.swift
//  MeditationPlus
//
//  Created by Erik Luimes on 07/05/16.
//  Copyright © 2016 Maya Interactive. All rights reserved.
//

import Foundation
import RealmSwift
import CryptoSwift
import CocoaLumberjack

protocol ProfileServiceProtocol
{
    func reloadProfileIfNeeded(name: String, forceReload: Bool) -> Bool
    
    func profile(username: String, notificationBlock: (RealmCollectionChange<Results<MPProfile>> -> Void)) -> (NotificationToken, Results<MPProfile>)
}

public class ProfileService: ProfileServiceProtocol
{
    private var apiClient: ProfileApiClientProtocol!
    
    private var dataStore: DataStore!
    
    private var cacheManager: CacheManager!
    
    convenience init()
    {
        self.init(apiClient: ProfileApiClient(), dataStore: DataStore(), cacheManager: CacheManager())
    }
    
    public init(apiClient: ProfileApiClientProtocol, dataStore: DataStore, cacheManager: CacheManager)
    {
        self.apiClient = apiClient
        self.dataStore = dataStore
        self.cacheManager = cacheManager
    }
    
    /**
     Reloads the chat items from the api
     
     - parameter forceReload: force reload of chat items
     */
    public func reloadProfileIfNeeded(name: String, forceReload: Bool = false) -> Bool
    {
        let cacheKey    = String(MPProfile.self).sha256()
        let needsUpdate = forceReload ? forceReload : cacheManager.needsUpdate(cacheKey, timeout: 360)
        
        guard needsUpdate else {
            return false
        }
        
        apiClient.loadProfile(name)
        {
            (response: ApiResponse<MPProfile>) in
            
            switch response {
            case ApiResponse.Success(let model):
                self.cacheManager.updateTimestampForCacheKey(cacheKey)
                self.dataStore.addOrUpdateObject(model)
            case ApiResponse.NoData(_):
                break
            case ApiResponse.Failure(let error):
                DDLogError(error?.localizedDescription ?? "Failed retrieving 'ChatItems'")
            }
        }
        
        return needsUpdate
    }
    
    /**
     Returns 'Profile' for given name
     
     - parameter notificationBlock: Realm notification block
     
     - returns: returns a tuple with a `NotificationToken` and realm `Results`
     */
    public func profile(username: String, notificationBlock: (RealmCollectionChange<Results<MPProfile>> -> Void)) -> (NotificationToken, Results<MPProfile>)
    {
        let results = dataStore.profile(username)
        let token   = results.addNotificationBlock(notificationBlock)
        
        return (token, results)
    }
}