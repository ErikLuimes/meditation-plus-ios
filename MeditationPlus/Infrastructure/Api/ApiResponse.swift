//
//  ServiceResponse.swift
//  MeditationPlus
//
//  Created by Erik Luimes on 06/05/16.
//  Copyright © 2016 Maya Interactive. All rights reserved.
//

import Foundation

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
}