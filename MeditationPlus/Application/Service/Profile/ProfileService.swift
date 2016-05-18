//
//  ProfileService.swift
//  MeditationPlus
//
//  Created by Erik Luimes on 07/05/16.
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

protocol ProfileServiceProtocol
{
    func reloadProfileIfNeeded(name: String, forceReload: Bool, completion: ((ServiceResult) -> Void)?) -> Bool
    
    func profile(username: String) -> Results<Profile>
    
    func profile(username: String, notificationBlock: (RealmCollectionChange<Results<Profile>> -> Void)) -> (NotificationToken, Results<Profile>)
}

public class ProfileService: ProfileServiceProtocol
{
    public static let sharedInstance = ProfileService()
    
    private var apiClient: ProfileApiClientProtocol!
    
    private var dataStore: DataStore!
    
    private var cacheManager: CacheManager!
    
    private var queue: NSOperationQueue!
    
    private var chatNotificationToken: NotificationToken!
    
    deinit
    {
        chatNotificationToken.stop()
    }
    
    convenience init()
    {
        self.init(apiClient: ProfileApiClient(), dataStore: DataStore(), cacheManager: CacheManager())
    }
    
    required public init(apiClient: ProfileApiClientProtocol, dataStore: DataStore, cacheManager: CacheManager)
    {
        self.apiClient = apiClient
        self.dataStore = dataStore
        self.cacheManager = cacheManager
        
        queue = NSOperationQueue()
        queue.qualityOfService = NSQualityOfService.Background
        queue.maxConcurrentOperationCount = 1
        
        setupChatNotification()
    }
    
    private func setupChatNotification()
    {
        guard chatNotificationToken == nil else {
            return
        }
        
        chatNotificationToken = dataStore.chatItems.addNotificationBlock
        {
            (changes: RealmCollectionChange<Results<ChatItem>>) in
            
            if changes.isSuccess() {
                self.retrieveMisscingProfiles()
            }
        }
    }
    
    private func retrieveMisscingProfiles()
    {
        dataStore.usernamesWithoutProfile
        {
            (usernames: Set<String>) in
            
            for username in usernames {
                self.queue.addOperationWithBlock
                {
                    () -> Void in
                    
                    self.reloadProfileIfNeeded(username, forceReload: true)
                }
            }
        }
    }
    
    /**
     Reloads the chat items from the api
     
     - parameter forceReload: force reload of chat items
     */
    public func reloadProfileIfNeeded(name: String, forceReload: Bool = false, completion: ((ServiceResult) -> Void)? = nil) -> Bool
    {
        let cacheKey    = "\(Profile.self)-\(name)".sha256()
        let needsUpdate = forceReload ? forceReload : cacheManager.needsUpdate(cacheKey, timeout: 360)
        
        guard needsUpdate else {
            return false
        }
        
        apiClient.loadProfile(name)
        {
            (response: ApiResponse<Profile>) in
            
            switch response {
            case ApiResponse.Success(let model):
                self.cacheManager.updateTimestampForCacheKey(cacheKey)
                self.dataStore.addOrUpdateObject(model)
                completion?(ServiceResult.Success)
            case ApiResponse.NoData(_):
                completion?(ServiceResult.Success)
                break
            case ApiResponse.Failure(let error):
                completion?(ServiceResult.Failure(error))
                DDLogError(error?.localizedDescription ?? "Failed retrieving 'Profile'")
            }
        }
        
        return needsUpdate
    }
    
    /**
     Returns 'Profile' for given name
     
     - parameter notificationBlock: Realm notification block
     
     - returns: returns a tuple with a `NotificationToken` and realm `Results`
     */
    public func profile(username: String, notificationBlock: (RealmCollectionChange<Results<Profile>> -> Void)) -> (NotificationToken, Results<Profile>)
    {
        let results = dataStore.profile(username)
        let token   = results.addNotificationBlock(notificationBlock)
        
        return (token, results)
    }
    
    public func profile(username: String) -> Results<Profile>
    {
        return dataStore.profile(username)
    }
}