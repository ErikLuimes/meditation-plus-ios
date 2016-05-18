//
//  CacheManager.swift
//  MeditationPlus
//
//  Created by Erik Luimes on 07/05/16.
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

public class CacheManager
{
    private var once = dispatch_once_t()
    
    private let key: String = "Cache"
    
    public init()
    {
        dispatch_once(&once)
        {
            NSUserDefaults.standardUserDefaults().registerDefaults([self.key : [:]])
        }
    }
    
    private var cacheDictionary: [NSString:AnyObject]?
    {
        get
        {
            return NSUserDefaults.standardUserDefaults().dictionaryForKey(key)
        }
        
        set
        {
            NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: key)
        }
    }
    
    public func needsUpdate(cacheKey: String, timeout: NSTimeInterval) -> Bool
    {
        guard let lastUpdateTime = cacheDictionary?[cacheKey] as? NSTimeInterval else {
            return true
        }
        
        return lastUpdateTime + timeout < NSDate().timeIntervalSince1970
    }
    
    public func updateTimestampForCacheKey(cacheKey: String)
    {
        if let cache = cacheDictionary {
            var writableCache = cache
            writableCache[cacheKey] = NSDate().timeIntervalSince1970
            
            cacheDictionary = writableCache
        }
    }
}