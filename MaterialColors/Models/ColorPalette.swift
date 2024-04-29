//
//  ColorPalette.swift
//  MaterialColors
//
//  Created by Oscar De Moya on 28/04/24.
//

import Foundation

struct ColorPalette {
    static let tones = [02, 10, 20, 30, 40, 50, 60, 70, 80, 90, 95, 98]
    static func tones(light: Bool) -> [Int] { light ? tones.reversed() : tones }
}
