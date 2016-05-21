//
//  Config.swift
//  MeditationPlus
//
//  Created by Erik Luimes on 21/05/16.
//  Copyright © 2016 Maya Interactive. All rights reserved.
//

import Foundation

public struct Config
{
    static private let config: NSDictionary = {
        return NSDictionary(contentsOfURL: R.file.defaultConfigPlist.url()!)!
    }()

    public struct api
    {
        static public private(set) var endpoint: String = {
            return Config.config.valueForKeyPath("api.endpoint") as? String ?? ""
        }()
    }
    
    public struct youtube
    {
        static public private(set) var key: String = {
            return Config.config.valueForKeyPath("youtube.key") as? String ?? ""
        }()
    }
    
    public struct crashlytics
    {
        static public private(set) var key: String = {
            return Config.config.valueForKeyPath("crashlytics.key") as? String ?? ""
        }()
        
        static public private(set) var secret: String = {
            return Config.config.valueForKeyPath("crashlytics.secret") as? String ?? ""
        }()
    }
    
    private init()
    {}
}
