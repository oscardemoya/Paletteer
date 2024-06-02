//
//  ColorConfig.swift
//  Paletteer
//
//  Created by Oscar De Moya on 28/04/24.
//

import SwiftUI

enum ColorScale: String, Codable, CaseIterable, Identifiable, Hashable {
    case lightening
    case darkening
    
    var id: Self { self }
    var isDarkening: Bool { self == .darkening }
    var isLightening: Bool { self == .lightening }

    var name: String {
        switch self {
        case .darkening: String(localized: "Darkening")
        case .lightening: String(localized: "Lightening")
        }
    }
    
    var iconName: String {
        switch self {
        case .darkening: return "square.2.layers.3d.top.filled" // 􀯮
        case .lightening: return "square.2.layers.3d.bottom.filled" // 􀯯
        }
    }
}
