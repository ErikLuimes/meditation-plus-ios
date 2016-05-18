//
//  ServiceResponse.swift
//  MeditationPlus
//
//  Created by Erik Luimes on 06/05/16.
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