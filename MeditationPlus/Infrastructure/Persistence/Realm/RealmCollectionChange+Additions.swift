//
//  RealmCollectionChange+Additions.swift
//  MeditationPlus
//
//  Created by Erik Luimes on 16/05/16.
//  Copyright © 2016 Maya Interactive. All rights reserved.
//

import Foundation
import RealmSwift

extension RealmCollectionChange
{
    public func isSuccess() -> Bool
    {
        switch self {
        case .Initial, .Update:
            return true
        default:
            return false
        }
    }
    
    public func isFailure() -> Bool
    {
        return !isSuccess()
    }
    
    public var results: T? {
        switch self {
        case .Initial(let results):
            return results
        case .Update(let results, _, _, _):
            return results
        default:
            return nil
        }
    }
    
    public var error: NSError? {
        if case .Error(let error) = self {
            return error
        } else {
            return nil
        }
    }
}