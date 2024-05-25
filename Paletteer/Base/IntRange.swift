//
//  IntRange.swift
//  Paletteer
//
//  Created by Oscar De Moya on 28/04/24.
//

import Foundation

extension ClosedRange where ClosedRange.Bound == Double {
    var median: Double {
        lowerBound + ((upperBound - lowerBound) / 2)
    }
}
