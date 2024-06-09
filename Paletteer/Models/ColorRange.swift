//
//  ColorRange.swift
//  Paletteer
//
//  Created by Oscar De Moya on 28/04/24.
//

import SwiftUI

enum ColorRange: String, Codable, CaseIterable, Identifiable, Hashable {
    case whole
    case waningGibbous
    case waxingGibbous
    case firstHalf
    case centerHalf
    case lastHalf
    case firstQuarter
    case secondQuarter
    case thirdQuarter
    case lastQuarter
    
    var id: Self { self }
    var startPercent: Double { startValue * 100 }
    
    var name: String {
        switch self {
        case .whole: String(localized: "Whole")
        case .waningGibbous: String(localized: "Waning Gibbous")
        case .waxingGibbous: String(localized: "Waxing Gibbous")
        case .firstHalf: String(localized: "First Half")
        case .centerHalf: String(localized: "Center Half")
        case .lastHalf: String(localized: "Last Half")
        case .firstQuarter: String(localized: "First Quarter")
        case .secondQuarter: String(localized: "Second Quarter")
        case .thirdQuarter: String(localized: "Third Quarter")
        case .lastQuarter: String(localized: "Last Quarter")
        }
    }
    
    var width: ColorRangeWidth {
        switch self {
        case .whole: .whole
        case .waningGibbous, .waxingGibbous: .gibbous
        case .firstHalf, .centerHalf, .lastHalf: .half
        case .firstQuarter, .secondQuarter, .thirdQuarter, .lastQuarter: .quarter
        }
    }
    
    var startValue: Double {
        switch self {
        case .whole: 0
        case .waningGibbous: 0
        case .waxingGibbous: 0.25
        case .firstHalf: 0
        case .centerHalf: 0.25
        case .lastHalf: 0.5
        case .firstQuarter: 0
        case .secondQuarter: 0.25
        case .thirdQuarter: 0.5
        case .lastQuarter: 0.75
        }
    }
}

enum ColorRangeWidth: String, Codable, CaseIterable, Identifiable, Hashable {
    case whole
    case gibbous
    case half
    case quarter
    
    var id: Self { self }
    var isWhole: Bool { self == .whole }
    var isGibbous: Bool { self == .gibbous }
    var isHalf: Bool { self == .half }
    var isQuarter: Bool { self == .quarter }
    var percent: Double { value * 100 }
        
    var name: String {
        switch self {
        case .whole: String(localized: "Whole")
        case .gibbous: String(localized: "Gibbous")
        case .half: String(localized: "Half")
        case .quarter: String(localized: "Quarter")
        }
    }
    
    var ranges: [ColorRange] {
        switch self {
        case .whole: [.whole]
        case .gibbous: [.waningGibbous, .waxingGibbous]
        case .half: [.firstHalf, .centerHalf, .lastHalf]
        case .quarter: [.firstQuarter, .secondQuarter, .thirdQuarter, .lastQuarter]
        }
    }
    
    var defaultRange: ColorRange {
        switch self {
        case .whole: .whole
        case .gibbous: .waningGibbous
        case .half: .firstHalf
        case .quarter: .firstQuarter
        }
    }
    
    var value: Double {
        switch self {
        case .whole: 1.0
        case .gibbous: 0.75
        case .half: 0.5
        case .quarter: 0.25
        }
    }
}
