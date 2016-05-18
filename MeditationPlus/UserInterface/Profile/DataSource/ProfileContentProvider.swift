//
//  ProfileContentProvider.swift
//  MeditationPlus
//
//  Created by Erik Luimes on 16/05/16.
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