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
    /**
     List of people who have been meditating
     
     - returns: Result set of meditators ordered by start date of their meditation
     */
    public func meditators() -> Results<Meditator>
    {
        return mainRealm.objects(Meditator).sorted("start", ascending: false)
    }
    
    /**
     Synchronizes the list of meditators, the api is leading so meditators that are not retrieved
     through the latest api call will be removed from the database
     
     - parameter meditators: Newly retrieved meditators
     */
    public func syncMeditators(meditators: [Meditator])
    {
        performWriteBlock
        {
            (backgroundRealm) in
            
            let availableMeditators = backgroundRealm.objects(Meditator)
            let newMeditators       = meditators.map({ $0.sid })
            var meditatorsToDelete  = [Meditator]()
            
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