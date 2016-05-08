//
//  DataStore+ProfileDataStore.swift
//  MeditationPlus
//
//  Created by Erik Luimes on 08/05/16.
//  Copyright © 2016 Maya Interactive. All rights reserved.
//

import Foundation
import RealmSwift

protocol ProfileDataStoreProtocol
{
    
}

extension DataStore: ProfileDataStoreProtocol
{
    public func profile(username: String) -> Results<MPProfile>
    {
        let predicate = NSPredicate(format: "username = %@", username)
        return mainRealm.objects(MPProfile).filter(predicate)
    }
}