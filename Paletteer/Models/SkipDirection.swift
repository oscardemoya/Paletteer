//
//  SkipDirection.swift
//  Paletteer
//
//  Created by Oscar De Moya on 8/25/24.
//

import Foundation

enum SkipDirection: String, Codable, CaseIterable, Identifiable, Hashable {
    case forward
    case backward
    
    var id: Self { self }
    var isForward: Bool { self == .forward }
    var isBackward: Bool { self == .backward }
    
    var name: String {
        switch self {
        case .forward: String(localized: "Forward")
        case .backward: String(localized: "Backward")
        }
    }
    
    var iconName: String {
        switch self {
        case .forward: return "forward.fill" // 􀊌
        case .backward: return "backward.fill" // 􀊊
        }
    }
    
    var symbol: String {
        switch self {
        case .forward: return "⏩︎"
        case .backward: return "⏪︎"
        }
    }
}
