//
//  UserDefaults.swift
//  Paletteer
//
//  Created by Oscar De Moya on 28/04/24.
//

import SwiftUI

func key(_ key: UserDefaults.Key) -> String { key.rawValue }

extension UserDefaults {
    enum Key: String, CaseIterable {
        case colorScheme
        case primaryColor
        case secondaryColor
        case tertiaryColor
        case successColor
        case warningColor
        case destructiveColor
        case backgroundColor
        case foregroundColor
    }
}
