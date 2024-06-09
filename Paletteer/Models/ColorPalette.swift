//
//  ColorPalette.swift
//  Paletteer
//
//  Created by Oscar De Moya on 28/04/24.
//

import SwiftUI

struct ColorPalette {
    static func shadesCount(isMaterial: Bool) -> Int { ColorPalette.tonesCount }
    
    // RGB Conversion
    static var lightestColor: Color = Color(hex: "#FFFFFF")
    static var darkestColor: Color = Color(hex: "#080808")
    
    static var overlayTones: [Int] = {
        [01, 02, 05, 10, 20, 30, 40, 50, 60, 70, 80, 90, 95, 98, 99]
    }()
    
    static func overlay(light: Bool) -> Color {
        return light ? lightestColor : darkestColor
    }

    // HCT Conversion
    private static let toneValues = [01, 02, 05, 10, 20, 30, 40, 50, 60, 70, 80, 90, 95, 98, 99]
    static var tonesCount: Int { tones(light: false).count }
    static func tones(light: Bool) -> [Int] { Array((light ? toneValues.reversed() : toneValues).dropFirst()) }
}
