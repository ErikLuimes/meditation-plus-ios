//
//  Config.swift
//  MeditationPlus
//
//  Created by Erik Luimes on 21/05/16.
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
