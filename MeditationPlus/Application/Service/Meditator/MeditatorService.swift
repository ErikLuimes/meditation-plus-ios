//
//  MeditatorService.swift
//  MeditationPlus
//
//  Created by Erik Luimes on 08/05/16.
//  Copyright © 2016 Maya Interactive. All rights reserved.
//

import Foundation
import RealmSwift
import CocoaLumberjack

protocol MeditatorServiceProtocol
{
    func reloadMeditatorsIfNeeded(forceReload: Bool) -> Bool
    
    func meditators(notificationBlock: (RealmCollectionChange<Results<MPMeditator>> -> Void)) -> (NotificationToken, Results<MPMeditator>)
}

private enum MeditationState
{
    case Start
    case Cancel
}

public class MeditatorService: MeditatorServiceProtocol
{
    private var apiClient: MeditatorApiClientProtocol!
    
    private var dataStore: DataStore!
    
    private var cacheManager: CacheManager!
    
    private var authenticationManager: MTAuthenticationManager
    
    convenience init()
    {
        self.init(apiClient: MeditatorApiClient(), dataStore: DataStore(), cacheManager: CacheManager(), authenticationManager: MTAuthenticationManager.sharedInstance)
    }
    
    public init(apiClient: MeditatorApiClientProtocol, dataStore: DataStore, cacheManager: CacheManager, authenticationManager: MTAuthenticationManager)
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
        let cacheKey    = String(MPMeditator.self).sha256()
        let needsUpdate = forceReload ? forceReload : cacheManager.needsUpdate(cacheKey, timeout: 360)
        
        guard needsUpdate else {
            return false
        }
        
        guard let username = authenticationManager.loggedInUser?.username else {
            return false
        }
        
        apiClient.loadMeditators(username)
        {
            (response: ApiResponse<[MPMeditator]>) in
            
            if let model = response.value where model.count > 0 {
                self.cacheManager.updateTimestampForCacheKey(cacheKey)
                self.dataStore.addOrUpdateObjects(model)
            } else {
                DDLogError(response.error?.localizedDescription ?? "Failed retrieving 'Meditators'")
            }
        }
        
        return needsUpdate
    }
    
    public func startMeditation(sittingTimeInMinutes: Int?, walkingTimeInMinutes: Int?, completionBlock: ((ServiceResult) -> Void)?)
    {
        updateMeditationTime(MeditationState.Start, sittingTimeInMinutes: sittingTimeInMinutes, walkingTimeInMinutes: walkingTimeInMinutes, completionBlock: completionBlock)
    }
    
    public func cancelMeditation(sittingTimeInMinutes: Int?, walkingTimeInMinutes: Int?, completionBlock: ((ServiceResult) -> Void)?)
    {
        updateMeditationTime(MeditationState.Cancel, sittingTimeInMinutes: sittingTimeInMinutes, walkingTimeInMinutes: walkingTimeInMinutes, completionBlock: completionBlock)
    }
    
    private func updateMeditationTime(state: MeditationState, sittingTimeInMinutes: Int?, walkingTimeInMinutes: Int?, completionBlock: ((ServiceResult) -> Void)?)
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
        
        let apiResponseBlock: ((ApiResponse<Bool>) -> Void) = {
            (response: ApiResponse<Bool>) in

            completionBlock?(response.isSuccess ? ServiceResult.Success : ServiceResult.Failure(nil))
        }
        
        switch state {
        case .Start:
            apiClient.startMeditation(username, token: token, sittingTimeInMinutes: sittingTimeInMinutes, walkingTimeInMinutes: walkingTimeInMinutes, completionBlock: apiResponseBlock)
        case .Cancel:
            apiClient.cancelMeditation(username, token: token, sittingTimeInMinutes: sittingTimeInMinutes, walkingTimeInMinutes: walkingTimeInMinutes, completionBlock: apiResponseBlock)
        }
    }
    
    /**
     Returns 'Meditator' for given name
     
     - parameter notificationBlock: Realm notification block
     
     - returns: returns a tuple with a `NotificationToken` and realm `Results`
     */
    public func meditators(notificationBlock: (RealmCollectionChange<Results<MPMeditator>> -> Void)) -> (NotificationToken, Results<MPMeditator>)
    {
        let results = dataStore.meditators()
        let token   = results.addNotificationBlock(notificationBlock)
        
        return (token, results)
    }
}