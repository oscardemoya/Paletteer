//
//  ColorConfig.swift
//  MaterialColors
//
//  Created by Oscar De Moya on 28/04/24.
//

import Foundation

struct ColorConfig: Identifiable, Hashable {
    var id: String { "\(hexColor)\(reversed)" }
    var hexColor: String
    var groupName: String
    var colorName: String
    var reversed: Bool = false
    
    func hash(into hasher: inout Hasher) {
        var hasher = hasher
        hasher.combine(hexColor)
        hasher.combine(groupName)
        hasher.combine(colorName)
        hasher.combine(reversed)
    }
}
