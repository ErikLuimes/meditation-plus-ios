//
//  ChatDataStore.swift
//  MeditationPlus
//
//  Created by Erik Luimes on 07/05/16.
//  Copyright © 2016 Maya Interactive. All rights reserved.
//

import Foundation

protocol ChatDataStoreProtocol
{
    
}

extension DataStore: ChatDataStoreProtocol
{
    public mutating func usernamesWithoutProfile(completion: (Set<String>) -> Void) {
        performBackgroundBlock
            { (backgroundRealm) in
            
                let availableUids = backgroundRealm.objects(MPProfile).flatMap({ $0.uid })
                
                let predicate = NSPredicate(format: "NOT uid IN %@", availableUids)
                let usernames = Set(backgroundRealm.objects(MPChatItem).filter(predicate).flatMap({ $0.username }))
                dispatch_async(dispatch_get_main_queue(), { 
                    completion(usernames)
                })

        }
    }
}