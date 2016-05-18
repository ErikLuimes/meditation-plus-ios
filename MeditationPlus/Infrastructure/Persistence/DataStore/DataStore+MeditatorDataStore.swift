//
//  DataStore+MeditatorDataStore.swift
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