//
//  ColorPalette.swift
//  MaterialColors
//
//  Created by Oscar De Moya on 28/04/24.
//

import Foundation

struct ColorPalette {
    static let tones = [98, 95, 90, 80, 70, 60, 50, 40, 30, 20, 10, 02]
    static func tones(light: Bool) -> [Int] { light ? tones.reversed() : tones }
}
