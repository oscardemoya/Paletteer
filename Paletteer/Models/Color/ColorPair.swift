//
//  ColorPair.swift
//  Paletteer
//
//  Created by Oscar De Moya on 28/04/24.
//

import SwiftUI

struct ColorPair: Identifiable {
    var id: String = UUID().uuidString
    var name: String
    var toneCode: String
    var light: Color
    var dark: Color
    
    func color(for scheme: AppColorScheme) -> Color {
        switch scheme {
        case .system, .light:
            light
        case .dark:
            dark
        }
    }
}
