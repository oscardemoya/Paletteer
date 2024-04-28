//
//  Theme.swift
//  MaterialColors
//
//  Created by Oscar De Moya on 28/04/24.
//

import SwiftUI

enum Theme: String, CaseIterable, Identifiable {
    case dual
    case light
    case dark
    
    var id: Self { self }
    
    var title: String {
        rawValue.capitalized
    }
    
    func color(for color: ColorPair) -> Color {
        switch self {
        case .dual, .light:
            color.light
        case .dark:
            color.dark
        }
    }
}
