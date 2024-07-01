//
//  ColorAdjustmentLevel.swift
//  Paletteer
//
//  Created by Oscar De Moya on 28/04/24.
//

import SwiftUI

enum ColorAdjustmentLevel: String, Codable, CaseIterable, Identifiable, Hashable {
    case low
    case medium
    case high
    
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
        case .low: String(localized: "Low")
        case .medium: String(localized: "Normal")
        case .high: String(localized: "High")
        }
    }
    
    var iconName: String {
        switch self {
        case .low: return "dial.low.fill" // 􀍻
        case .medium: return "dial.medium.fill" // 􁎵
        case .high: return "dial.high.fill" // 􀪑
        }
    }
    
    var multiplier: Double {
        switch self {
        case .low: 0.5
        case .medium: 1
        case .high: 1.5
        }
    }
    
    var symbol: String {
        switch self {
        case .low: "L"
        case .medium: "M"
        case .high: "H"
        }
    }
}
