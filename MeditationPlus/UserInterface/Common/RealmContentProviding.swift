//
//  ContentProviding.swift
//  MeditationPlus
//
//  Created by Erik Luimes on 14/05/16.
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
