//
//  ServiceResponse.swift
//  MeditationPlus
//
//  Created by Erik Luimes on 06/05/16.
//  Copyright © 2016 Maya Interactive. All rights reserved.
//

import Foundation
import Alamofire

/**
 Response from the API client
 
 - Success: API response was successful and model has been parsed
 - NoData:  API response was successful but no data returned
 - Failure: API server failure
 */
public enum ApiResponse<T>
{
    case Success(T)
    case NoData(T?)
    case Failure(NSError?)
    
    public var isSuccess: Bool
    {
        var success: Bool = true
        
        if case .Success(_) = self {
            success = true
        } else {
            success = false
        }
        
        return success
    }
    
    public var isFailure: Bool
    {
        return !isSuccess
    }
    
    public var value: T?
    {
        if case .Success(let value) = self {
            return value
        } else {
            return nil
        }
    }
    
    public var error: NSError?
    {
        if case .Failure(let error) = self {
            return error
        } else {
            return nil
        }
    }
}