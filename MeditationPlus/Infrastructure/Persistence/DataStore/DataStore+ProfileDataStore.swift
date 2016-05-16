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
    /**
     Returns the profile by username
     
     - parameter username: username
     
     - returns: Result set with profile data
     */
    public func profile(username: String) -> Results<Profile>
    {
        let predicate = NSPredicate(format: "username = %@", username)
        return mainRealm.objects(Profile).filter(predicate)
    }
}