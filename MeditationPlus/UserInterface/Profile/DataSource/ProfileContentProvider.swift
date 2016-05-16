//
//  ProfileContentProvider.swift
//  MeditationPlus
//
//  Created by Erik Luimes on 16/05/16.
//  Copyright © 2016 Maya Interactive. All rights reserved.
//

import Foundation
import RealmSwift

public struct ProfileContentProvider: RealmContentProviding
{
    var notificationBlock: ((changes: RealmCollectionChange<Results<Profile>>) -> Void)?
    
    var resultsBlock: ((results: Results<Profile>) -> Void)?
    
    private let profileService: ProfileService!
    
    private var notificationToken: NotificationToken?
    
    init(profileService: ProfileService)
    {
        self.profileService = profileService
    }
    
    public mutating func fetchContentIfNeeded(username: String, forceReload: Bool = false) -> Bool
    {
        enableNotification(username)
        return profileService.reloadProfileIfNeeded(username, forceReload: forceReload)
    }
    
    private mutating func enableNotification(username: String)
    {
        guard notificationToken == nil && notificationBlock != nil else {
            return
        }
        
        let (newNotificationToken, results) = profileService.profile(username, notificationBlock: notificationBlock!)
        notificationToken = newNotificationToken
        
        resultsBlock?(results: results)
    }
    
    public mutating func disableNotification()
    {
        notificationToken?.stop()
        notificationToken = nil
    }
}