//
//  MTResponseObjectMapper.swift
//  MijnTelfort
//
//  Created by joost on 14-08-15.
//  Copyright (c) 2015 Elements Interactive. All rights reserved.
//

import UIKit
import ObjectMapper

class MPResponseObjectSerializer<T: Mappable>: MPResponseSerializer {
   
    override init() {
        super.init()
    }
    
    override func mapResponse(response: AnyObject!) -> AnyObject! {
        if response != nil {
            let parsedObject = Mapper<T>().map(response)
        
            return parsedObject as! AnyObject!
        }
        return nil
    }
}
