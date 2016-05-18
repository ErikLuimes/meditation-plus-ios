//
//  VideoItem.swift
//  MeditationPlus
//
//  Created by Erik Luimes on 06/11/15.
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
import ObjectMapper

/*
{
		"kind": "youtube#searchResult",
		"etag": "\"0KG1mRN7bm3nResDPKHQZpg5-do/IaOT6qBMxF6FedIG1l7vKmmB848\"",
		"id": {
			"kind": "youtube#video",
			"videoId": "R5p0_M1G-Dw"
		},
		"snippet": {
			"publishedAt": "2015-11-06T01:38:58.000Z",
			"channelId": "UCQJ6ESCWQotBwtJm0Ff_gyQ",
			"title": "Daily Broadcast, Nov. 5, 2015",
			"description": "Daily Broadcast, Nov. 5, 2015.",
			"thumbnails": {
				"default": {
					"url": "https://i.ytimg.com/vi/R5p0_M1G-Dw/default.jpg"
				},
				"medium": {
					"url": "https://i.ytimg.com/vi/R5p0_M1G-Dw/mqdefault.jpg"
				},
				"high": {
					"url": "https://i.ytimg.com/vi/R5p0_M1G-Dw/hqdefault.jpg"
				}
			},
			"channelTitle": "yuttadhammo",
			"liveBroadcastContent": "none"
		}
	}
*/

class VideoItem: Mappable
{
    var id: String?
    var publishedAt: NSDate?
    var title: String?
    var description: String?
    var thumbnail: NSURL?

    // MARK: Mappable

    required init?(_ map: Map)
    {
        mapping(map)
    }

    func mapping(map: Map)
    {
        id <- map["id.videoId"]
        publishedAt <- map["snipper.publishedAt"]
        title <- map["snippet.title"]
        description <- map["snippet.description"]
        thumbnail <- (map["snippet.thumbnails.high.url"], URLTransform())
    }
}
