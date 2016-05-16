//
//  ContentProviding.swift
//  MeditationPlus
//
//  Created by Erik Luimes on 14/05/16.
//  Copyright © 2016 Maya Interactive. All rights reserved.
//

import Foundation
import RealmSwift

protocol RealmContentProviding
{
    associatedtype Content: Object
    
    /// Closure that returns 'Results' enum from realm, this is triggered when a new Realm notification is initiated
    var resultsBlock: ((results: Results<Content>) -> Void)? { get set }
    
    var notificationBlock: ((changes: RealmCollectionChange<Results<Content>>) -> Void)? { get set }
    
    mutating func disableNotification()
}

public struct MeditatorContentProvider: RealmContentProviding
{
    var notificationBlock: ((changes: RealmCollectionChange<Results<Meditator>>) -> Void)?
    
    var resultsBlock: ((results: Results<Meditator>) -> Void)?
    
    private let meditatorService: MeditatorService!
    
    private var notificationToken: NotificationToken?
    
    init(meditatorService: MeditatorService)
    {
        self.meditatorService = meditatorService
    }
    
    public mutating func fetchContentIfNeeded(forceReload forceReload: Bool = false) -> Bool
    {
        enableNotification()
        return meditatorService.reloadMeditatorsIfNeeded(forceReload)
    }
    
    private mutating func enableNotification()
    {
        guard notificationToken == nil && notificationBlock != nil else {
            return
        }
        
        let (newNotificationToken, results) = meditatorService.meditators(notificationBlock!)
        notificationToken = newNotificationToken
        
        resultsBlock?(results: results)
    }
    
    public mutating func disableNotification()
    {
        notificationToken?.stop()
        notificationToken = nil
    }
}
