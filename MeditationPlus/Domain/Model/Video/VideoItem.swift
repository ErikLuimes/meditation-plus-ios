//
//  VideoItem.swift
//  MeditationPlus
//
//  Created by Erik Luimes on 06/11/15.
//  Copyright (c) 2015 Maya Interactive. All rights reserved.
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
