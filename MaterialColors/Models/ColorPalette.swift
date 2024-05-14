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
    static var darkestColor: Color = Color(hex: "#080808") ?? .black
    static var overlaysCount: Int { overlayOpacities(narrow: false).count }
    static var opacityValues: [Int] = [02, 10, 20, 30, 40, 60, 80]
    
    static func overlayOpacities(narrow: Bool) -> [Int] {
        if narrow {
            [01, 05, 10, 20, 30, 40, 50, 60, 70, 80, 85, 90, 95, 100]
        } else {
            opacityValues + [100] + opacityValues.dropFirst().reversed().map { $0 }
        }
    }
    
    static var overlayTones: [Int] = {
        [01, 05, 10, 15, 20, 30, 40, 50, 60, 70, 80, 85, 90, 95]
    }()
    
    static func overlay(for index: Int, light: Bool, narrow: Bool) -> Color {
        if narrow {
            return light ? lightestColor : darkestColor
        }
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
