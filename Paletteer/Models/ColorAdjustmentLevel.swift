//
//  ColorAdjustmentLevel.swift
//  Paletteer
//
//  Created by Oscar De Moya on 28/04/24.
//

import SwiftUI

enum ColorAdjustmentLevel: String, Codable, CaseIterable, Identifiable, Hashable {
    case min
    case low
    case medium
    case high
    case max
    
    var id: Self { self }
    
    init(symbol: String) {
        switch symbol {
        case Self.low.symbol: self = .low
        case Self.medium.symbol: self = .medium
        case Self.high.symbol: self = .high
        default: self = .medium
        }
    }

    var name: String {
        switch self {
        case .min: String(localized: "Min")
        case .low: String(localized: "Low")
        case .medium: String(localized: "Normal")
        case .high: String(localized: "High")
        case .max: String(localized: "Max")
        }
    }
    
    var iconName: String {
        switch self {
        case .min: return "light.min" // 􀇭
        case .low: return "dial.low.fill" // 􀍻
        case .medium: return "dial.medium.fill" // 􁎵
        case .high: return "dial.high.fill" // 􀪑
        case .max: return "light.max" // 􀇮
        }
    }
    
    var multiplier: Double {
        switch self {
        case .min: 0.25
        case .low: 0.5
        case .medium: 1
        case .high: 1.5
        case .max: 2
        }
    }
    
    var symbol: String {
        switch self {
        case .min: "N"
        case .low: "L"
        case .medium: "M"
        case .high: "H"
        case .max: "X"
        }
    }
}
