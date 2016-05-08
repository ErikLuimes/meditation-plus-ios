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
}