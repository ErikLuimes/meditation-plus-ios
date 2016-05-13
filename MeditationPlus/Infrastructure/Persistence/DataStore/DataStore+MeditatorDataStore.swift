//
//  DataStore+MeditatorDataStore.swift
//  MeditationPlus
//
//  Created by Erik Luimes on 08/05/16.
//  Copyright © 2016 Maya Interactive. All rights reserved.
//

import Foundation
import RealmSwift

protocol MeditatorDataStoreProtocol
{
    
}

extension DataStore: MeditatorDataStoreProtocol
{
    public func meditators() -> Results<MPMeditator>
    {
        return mainRealm.objects(MPMeditator)
    }
    
    public func syncMeditators(meditators: [MPMeditator])
    {
        performWriteBlock
        {
            (backgroundRealm) in
            
            let availableMeditators = backgroundRealm.objects(MPMeditator)
            let newMeditators       = meditators.map({ $0.sid })
            var meditatorsToDelete  = [MPMeditator]()
            
            for meditator in availableMeditators {
                if !newMeditators.contains(meditator.sid) {
                    meditatorsToDelete.append(meditator)
                }
            }
            
            backgroundRealm.delete(meditatorsToDelete)
            backgroundRealm.add(meditators, update: true)
        }
    }
}