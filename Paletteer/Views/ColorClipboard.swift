//
//  ColorClipboard.swift
//  Paletteer
//
//  Created by Oscar De Moya on 27/05/24.
//

import SwiftUI

@Observable
class ColorClipboard {
    struct Defaults {
        @AppStorage(key(.clipboardColors)) static var colors: [Color] = []
    }
    
    static let maxItems = 12
    var colors: [Color] = []
    
    init() {
        self.colors = Defaults.colors
    }
    
    func add(_ color: Color) {
        if colors.contains(color) {
            colors.removeAll(where: { $0 == color })
        } else if colors.count >= Self.maxItems {
            colors = colors.suffix(Self.maxItems - 1)
        }
        colors.append(color)
        Defaults.colors = colors
    }
    
    func add(_ colors: [Color]) {
        self.colors = colors
        Defaults.colors = colors
    }
}
