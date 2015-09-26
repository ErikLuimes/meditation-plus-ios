//
//  MPResponseSerializer.swift
//  MeditationPlus
//
//  Created by Erik Luimes on 12/09/15.
//  Copyright (c) 2015 Maya Interactive. All rights reserved.
//

import Foundation
import AFNetworking

public class MPResponseSerializer: AFJSONResponseSerializer {
    
    public override func responseObjectForResponse(response: NSURLResponse!, data: NSData!, error: NSErrorPointer) -> AnyObject! {
        
        let jsonResponse: AnyObject! = super.responseObjectForResponse(response, data: data, error: error)
        
        var resultObject : AnyObject!
        
        if response.isKindOfClass(NSHTTPURLResponse) {
            let httpResponse = response as! NSHTTPURLResponse
            
            if httpResponse.statusCode >= 200 && httpResponse.statusCode < 300 {
                resultObject = jsonResponse
            }
//            else if httpResponse.statusCode >= 400 {
//                error.memory = self.handleError(jsonResponse as? [String: AnyObject], httpResponse: httpResponse, error: error.memory)
//            }
            
        }
        
        if var value = self.mapResponse(resultObject) {
            return value
        }
        throw error
    }
    
    /**
    * Work around for swift vs objc subclasses in order to be able to implement MTResponseObjectSerializer
    */
    public func mapResponse(response : AnyObject!) -> AnyObject! {
        return response
    }
    
    
//    public func handleError(jsonDictionary: [String: AnyObject]?, httpResponse : NSHTTPURLResponse, error : NSError?) -> NSError? {
//        if let json = jsonDictionary, code = json["code"] as? String {
//            
//            var mappedError : MTError?
//            
//            switch code.uppercaseString {
//                
//                
//            case "INVALID_SESSION":
//                mappedError = Mapper<MTSessionExpiredError>().map(jsonDictionary)
//                
//            case "SESSION_LIMIT":
//                mappedError = Mapper<MTSessionLimitError>().map(jsonDictionary)
//                
//            case "MAINTENANCE":
//                mappedError = Mapper<MTMaintenanceError>().map(jsonDictionary)
//                
//            case "VERSION_BLOCKED":
//                mappedError = Mapper<MTVersionBlockedError>().map(jsonDictionary)
//                
//            case "LOCKED_OUT",
//            "NOT_ACTIVE",
//            "BUSINESS_PROPOSITION_NOT_ALLOWED",
//            "LOGIN_FAILED",
//            "INVALID_INPUT",
//            "SESSION_LIMIT" :
//                mappedError = Mapper<MTLoginError>().map(jsonDictionary)
//                
//            default: ()
//            }
//            
//            // Temporary error handling to identify possible session errors
//            if (mappedError == nil) {
//                
//                mappedError = Mapper<MTError>().map(jsonDictionary)
//                
//            }
//            
//            if (mappedError != nil) {
//                return mappedError
//            }
//        }
//        
//        return error
//        
//    }
}