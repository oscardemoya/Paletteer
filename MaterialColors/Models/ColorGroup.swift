//
//  ColorGroup.swift
//  MaterialColors
//
//  Created by Oscar De Moya on 28/04/24.
//

import SwiftUI

struct ColorGroup: Identifiable, Hashable {
    var id: String { "\(hexColor)\(colorName)\(groupName)\(reversed)\(narrow)" }
    var color: Color
    var groupName: String
    var colorName: String
    var reversed: Bool = false
    var narrow: Bool = false
    
    var hexColor: String { color.hexRGB }
    
    func hash(into hasher: inout Hasher) {
        var hasher = hasher
        hasher.combine(hexColor)
        hasher.combine(groupName)
        hasher.combine(colorName)
        hasher.combine(reversed)
        hasher.combine(narrow)
    }
}
