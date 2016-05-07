//
//  ServiceResponse.swift
//  MeditationPlus
//
//  Created by Erik Luimes on 06/05/16.
//  Copyright © 2016 Maya Interactive. All rights reserved.
//

import Foundation

public enum ApiResponse<T>
{
    case Success(T)
    case Failure(NSError?)
}