//
//  ServiceResult.swift
//  MeditationPlus
//
//  Created by Erik Luimes on 08/05/16.
//  Copyright © 2016 Maya Interactive. All rights reserved.
//

import Foundation

public enum ServiceResult
{
    case Success
    case Failure(NSError?)
    
    public func isSuccess() -> Bool
    {
        if case .Success = self {
            return true
        } else {
            return false
        }
    }
    
    public func isFailure() -> Bool
    {
        return !isSuccess()
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