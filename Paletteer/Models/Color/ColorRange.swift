//
//  ColorRange.swift
//  Paletteer
//
//  Created by Oscar De Moya on 28/04/24.
//

import SwiftUI

enum ColorRange: String, Codable, CaseIterable, Identifiable, Hashable {
    case whole
    case startThreeQuarters
    case endThreeQuarters
    case firstHalf
    case centerHalf
    case lastHalf
    case firstQuarter
    case secondQuarter
    case thirdQuarter
    case lastQuarter
    
    var id: Self { self }
    var startPercent: Double { startValue * 100 }
    var percentDescription: String { "[\(Int(startPercent)),\(Int(width.percent))]" }
    var startValue: Double { Double(index) * 0.25 }
    var startAngle: Angle { .degrees(startValue * 360) }
    
    var index: Int {
        guard let index = width.ranges.firstIndex(of: self) else {
            fatalError("Range not found: \(self)")
        }
        return index
    }

    init?(percentDescription: String) {
        guard !percentDescription.isEmpty,
              let value = Self.allCases.first(where: { $0.percentDescription == percentDescription }) else {
            return nil
        }
        self = value
    }
    
    var name: String {
        switch self {
        case .whole: String(localized: "Whole")
        case .startThreeQuarters: String(localized: "Start")
        case .endThreeQuarters: String(localized: "End")
        case .firstHalf: String(localized: "First")
        case .centerHalf: String(localized: "Center")
        case .lastHalf: String(localized: "Last")
        case .firstQuarter: String(localized: "First")
        case .secondQuarter: String(localized: "Second")
        case .thirdQuarter: String(localized: "Third")
        case .lastQuarter: String(localized: "Last")
        }
    }
    
    var width: ColorRangeWidth {
        switch self {
        case .whole: .whole
        case .startThreeQuarters, .endThreeQuarters: .threeQuarters
        case .firstHalf, .centerHalf, .lastHalf: .half
        case .firstQuarter, .secondQuarter, .thirdQuarter, .lastQuarter: .quarter
        }
    }
}

enum ColorRangeWidth: String, Codable, CaseIterable, Identifiable, Hashable {
    case whole
    case threeQuarters
    case half
    case quarter
    
    var id: Self { self }
    var isWhole: Bool { self == .whole }
    var isThreeQuarters: Bool { self == .threeQuarters }
    var isHalf: Bool { self == .half }
    var isQuarter: Bool { self == .quarter }
    var percent: Double { value * 100 }
        
    var name: String {
        switch self {
        case .whole: String(localized: "Whole")
        case .threeQuarters: String(localized: "Three Quarters")
        case .half: String(localized: "Half")
        case .quarter: String(localized: "Quarter")
        }
    }
    
    var ranges: [ColorRange] {
        switch self {
        case .whole: [.whole]
        case .threeQuarters: [.startThreeQuarters, .endThreeQuarters]
        case .half: [.firstHalf, .centerHalf, .lastHalf]
        case .quarter: [.firstQuarter, .secondQuarter, .thirdQuarter, .lastQuarter]
        }
    }
    
    var defaultRange: ColorRange {
        switch self {
        case .whole: .whole
        case .threeQuarters: .startThreeQuarters
        case .half: .firstHalf
        case .quarter: .firstQuarter
        }
    }
    
    var value: Double {
        switch self {
        case .whole: 1.0
        case .threeQuarters: 0.75
        case .half: 0.5
        case .quarter: 0.25
        }
    }
}
