//
//  CacheManager.swift
//  MeditationPlus
//
//  Created by Erik Luimes on 07/05/16.
//  Copyright © 2016 Maya Interactive. All rights reserved.
//

import Foundation

public class CacheManager
{
    private var once = dispatch_once_t()
    
    private let key: String = "Cache"
    
    public init()
    {
        dispatch_once(&once) {
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