//
// Created by Erik Luimes on 12/09/15.
// Copyright (c) 2015 Maya Interactive. All rights reserved.
//

import Foundation

func clamp<T:Comparable>(value:T, lowerBound:T, upperBound:T) -> T {
    return min(max(lowerBound, value), upperBound)
}