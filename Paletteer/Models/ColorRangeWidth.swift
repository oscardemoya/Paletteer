//
//  ColorRangeWidth.swift
//  Paletteer
//
//  Created by Oscar De Moya on 28/04/24.
//

import SwiftUI

enum ColorRangeWidth: String, Codable, CaseIterable, Identifiable, Hashable {
    case full
    case wide
    case half
    case narrow
    
    var id: Self { self }
    var isFull: Bool { self == .full }
    var isWide: Bool { self == .wide }
    var isHalf: Bool { self == .half }
    var isNarrow: Bool { self == .narrow }

    var name: String {
        switch self {
        case .full: String(localized: "Full")
        case .wide: String(localized: "Wide")
        case .half: String(localized: "Half")
        case .narrow: String(localized: "Narrow")
        }
    }
    
    var iconName: String {
        switch self {
        case .full: return "circle" // 􀀁
        case .wide: return "field.of.view.ultrawide.fill" // 􁿽
        case .half: return "circle.tophalf.filled" // 􀪗
        case .narrow: return "field.of.view.wide.fill" // 􁿿
        }
    }
    
    var progress: Double {
        switch self {
        case .full: 1.0
        case .wide: 0.75
        case .half: 0.5
        case .narrow: 0.25
        }
    }
}
