//
//  Double.swift
//  Paletteer
//
//  Created by Oscar De Moya on 5/06/24.
//

import Foundation

extension Double {
    var widened: Self { pow(sin((.pi / 2) * self), 2) }
    var narrowed: Self { (2 / .pi) * asin(self) }
    
    func exponential(_ base: Self = M_E) -> Self {
        exp(self * log(base / M_E))
    }
    
    func logaritmic(_ epsilon: Self = M_E) -> Self {
        let epsilon = M_E * 2
        let logValue = log(self * (1.0 - epsilon) + epsilon)
        let minLog = log(epsilon)
        let maxLog = 0.0
        let normalizedLogValue = (logValue - minLog) / (maxLog - minLog)
        let invertedValue = 1.0 - normalizedLogValue
        return invertedValue
    }
    
    func mapped(to range: ClosedRange<Self>) -> Self {
        let rangeSize = range.upperBound - range.lowerBound
        return self * rangeSize + range.lowerBound
    }
    
    func skewed(towards target: Self, alpha: Self = 2) -> Self {
        if self < target {
            return pow(self / target, alpha) * target
        } else {
            return 1 - pow((1 - self) / (1 - target), alpha) * (1 - target)
        }
    }
}

extension CGFloat {
    var widened: Self { pow(sin((.pi / 2) * self), 2) }
    var narrowed: Self { (2 / .pi) * asin(self) }
    
    func exponential(_ base: Self = M_E) -> Self {
        exp(self * log(base / M_E))
    }
    
    func logaritmic(_ epsilon: Self = M_E) -> Self {
        let logValue = log(self * (1.0 - epsilon) + epsilon)
        let minLog = log(epsilon)
        let maxLog = 0.0
        let normalizedLogValue = (logValue - minLog) / (maxLog - minLog)
        let invertedValue = 1.0 - normalizedLogValue
        return invertedValue
    }
    
    func mapped(to range: ClosedRange<Self>) -> Self {
        let rangeSize = range.upperBound - range.lowerBound
        return self * rangeSize + range.lowerBound
    }
    
    func skewed(towards target: Self, alpha: Self = 2) -> Self {
        if self < target {
            return pow(self / target, alpha) * target
        } else {
            return 1 - pow((1 - self) / (1 - target), alpha) * (1 - target)
        }
    }
}
