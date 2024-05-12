//
//  ColorPalette.swift
//  MaterialColors
//
//  Created by Oscar De Moya on 28/04/24.
//

import SwiftUI

struct ColorPalette {
    static func shadesCount(isMaterial: Bool) -> Int {
        if isMaterial {
            ColorPalette.tonesCount
        } else {
            ColorPalette.overlaysCount
        }
    }
    
    // RGB Conversion
    static var lightestColor: Color = .white
    static var darkestColor: Color = Color(hex: "#121212") ?? .black
    static var opacityValues = [0.95, 0.75, 0.55, 0.35, 0.15]
    static var overlaysCount: Int { overlayOpacities.count }
    static var overlayOpacities: [Double] { opacityValues + [0.0] + opacityValues.reversed() }
    static func overlay(for index: Int, light: Bool) -> Color {
        let rate = Double(index) / Double(overlaysCount - 1)
        if rate < 0.5 {
            return light ? lightestColor : darkestColor
        } else if rate > 0.5 {
            return light ? darkestColor : lightestColor
        } else {
            return .clear
        }
    }

    // HCT Conversion
    private static let toneValues = [01, 02, 05, 10, 20, 30, 40, 50, 60, 70, 80, 90, 95, 98, 99]
    static var tonesCount: Int { tones(light: false).count }
    static func tones(light: Bool) -> [Int] { Array((light ? toneValues.reversed() : toneValues).dropFirst()) }
}
