//
//  MeditatorService.swift
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
import RealmSwift
import CocoaLumberjack

protocol MeditatorServiceProtocol
{
    func reloadMeditatorsIfNeeded(forceReload: Bool) -> Bool
    
    func meditators(notificationBlock: (RealmCollectionChange<Results<Meditator>> -> Void)) -> (NotificationToken, Results<Meditator>)
}

private enum MeditationTimePublishState
{
    case Start
    case Cancel
}

public class MeditatorService: MeditatorServiceProtocol
{
    private var apiClient: MeditatorApiClientProtocol!
    
    private var dataStore: DataStore!
    
    private var cacheManager: CacheManager!
    
    private var authenticationManager: AuthenticationManager
    
    convenience init()
    {
        self.init(apiClient: MeditatorApiClient(), dataStore: DataStore(), cacheManager: CacheManager(), authenticationManager: AuthenticationManager.sharedInstance)
    }
    
    public init(apiClient: MeditatorApiClientProtocol, dataStore: DataStore, cacheManager: CacheManager, authenticationManager: AuthenticationManager)
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
    public func reloadMeditatorsIfNeeded(forceReload: Bool = false) -> Bool
    {
        let cacheKey    = String(Meditator.self).sha256()
        let needsUpdate = forceReload ? forceReload : cacheManager.needsUpdate(cacheKey, timeout: 360)
        
        guard needsUpdate else {
            return false
        }
        
        guard let username = authenticationManager.loggedInUser?.username else {
            return false
        }
        
        apiClient.loadMeditators(username)
        {
            (response: ApiResponse<[Meditator]>) in
            
            if let model = response.value where model.count > 0 {
                self.cacheManager.updateTimestampForCacheKey(cacheKey)
                self.dataStore.syncMeditators(model)
            } else {
                DDLogError(response.error?.localizedDescription ?? "Failed retrieving 'Meditators'")
            }
        }
        
        return needsUpdate
    }
    
    public func startMeditation(sittingTimeInMinutes: Int?, walkingTimeInMinutes: Int?, completionBlock: ((ServiceResult) -> Void)? = nil)
    {
        updateMeditationTime(MeditationTimePublishState.Start, sittingTimeInMinutes: sittingTimeInMinutes, walkingTimeInMinutes: walkingTimeInMinutes, completionBlock: completionBlock)
    }
    
    public func cancelMeditation(sittingTimeInMinutes: Int?, walkingTimeInMinutes: Int?, completionBlock: ((ServiceResult) -> Void)? = nil)
    {
        updateMeditationTime(MeditationTimePublishState.Cancel, sittingTimeInMinutes: sittingTimeInMinutes, walkingTimeInMinutes: walkingTimeInMinutes, completionBlock: completionBlock)
    }
    
    private func updateMeditationTime(state: MeditationTimePublishState, sittingTimeInMinutes: Int?, walkingTimeInMinutes: Int?, completionBlock: ((ServiceResult) -> Void)? = nil)
    {
       if sittingTimeInMinutes == nil && walkingTimeInMinutes == nil {
            completionBlock?(ServiceResult.Failure(nil))
        }
        
        guard let username = authenticationManager.loggedInUser?.username else {
            completionBlock?(ServiceResult.Failure(nil))
            return
        }
        
        guard let token = authenticationManager.token?.token else {
            completionBlock?(ServiceResult.Failure(nil))
            return
        }
        
        let cacheKey = String(Meditator.self).sha256()
        
        let apiResponseBlock: ((ApiResponse<[Meditator]>) -> Void) =
        {
            (response: ApiResponse<[Meditator]>) in
            
            if let model = response.value where model.count > 0 {
                self.cacheManager.updateTimestampForCacheKey(cacheKey)
                self.dataStore.syncMeditators(model)
            } else {
                DDLogError(response.error?.localizedDescription ?? "Failed retrieving 'Meditators'")
            }
        }
        
        switch state {
        case MeditationTimePublishState.Start:
            apiClient.startMeditation(username, token: token, sittingTimeInMinutes: sittingTimeInMinutes, walkingTimeInMinutes: walkingTimeInMinutes, completionBlock: apiResponseBlock)
        case MeditationTimePublishState.Cancel:
            apiClient.cancelMeditation(username, token: token, sittingTimeInMinutes: sittingTimeInMinutes, walkingTimeInMinutes: walkingTimeInMinutes, completionBlock: apiResponseBlock)
        }
    }
    
    /**
     Returns 'Meditator' for given name
     
     - parameter notificationBlock: Realm notification block
     
     - returns: returns a tuple with a `NotificationToken` and realm `Results`
     */
    public func meditators(notificationBlock: (RealmCollectionChange<Results<Meditator>> -> Void)) -> (NotificationToken, Results<Meditator>)
    {
        let results = dataStore.meditators()
        let token   = results.addNotificationBlock(notificationBlock)
        
        return (token, results)
    }
}