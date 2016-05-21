//
//  YoutubeManager.swift
//  MeditationPlus
//
//  Created by Erik Luimes on 06/11/15
//
//  The MIT License
//  Copyright (c) 2015 Maya Interactive. All rights reserved.
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
import Alamofire

class YoutubeManager
{
    static let sharedInstance = YoutubeManager()

    private var apiKey: String = ""

    class func setup()
    {
        sharedInstance.apiKey = Config.youtube.key
    }

    func videoList(completion: ([VideoItem] -> Void)?)
    {
        let endpoint = "https://www.googleapis.com/youtube/v3/search"
        let parameters: [String:String] = [
                "key": apiKey,
                "part": "snippet",
                "maxResults": "50",
                "order": "date",
                "channelId": "UCQJ6ESCWQotBwtJm0Ff_gyQ"
        ]

        Alamofire.request(.GET, endpoint, parameters: parameters).responseObject
        {
            (response: Response<VideoList, NSError>) in
            
            if let list = response.result.value where list.items?.count ?? 0 > 0 {
                completion?(list.items!)
            }
        }
    }
}
