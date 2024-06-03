//
//  ColorPalette.swift
//  Paletteer
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
    static var darkestColor: Color = Color(hex: "#080808")
    static var overlaysCount: Int { overlayOpacities(light: true, full: true).count }
    
    static func overlayOpacities(light: Bool, full: Bool) -> [(light: Bool?, opacity: Int)] {
        if full {
            if light {
                [
                    (true, 10),
                    (true, 20),
                    (true, 30),
                    (true, 40),
                    (true, 60),
                    (true, 80),
                    (nil, 100),
                    (false, 80),
                    (false, 60),
                    (false, 40),
                    (false, 30),
                    (false, 20),
                    (false, 10),
                    (false, 02)
                ]
            } else {
                [
                    (false, 02),
                    (false, 10),
                    (false, 20),
                    (false, 30),
                    (false, 40),
                    (false, 60),
                    (false, 80),
                    (nil, 100),
                    (true, 80),
                    (true, 60),
                    (true, 40),
                    (true, 30),
                    (true, 20),
                    (true, 10)
                ]
            }
        } else {
            if light {
                [
                    (true, 10),
                    (true, 20),
                    (true, 30),
                    (true, 40),
                    (true, 50),
                    (true, 60),
                    (true, 70),
                    (true, 80),
                    (true, 85),
                    (true, 90),
                    (true, 95),
                    (true, 98),
                    (true, 99),
                    (nil, 100)
                ]
            } else {
                [
                    (false, 01),
                    (false, 02),
                    (false, 05),
                    (false, 10),
                    (false, 15),
                    (false, 20),
                    (false, 30),
                    (false, 40),
                    (false, 50),
                    (false, 60),
                    (false, 70),
                    (false, 80),
                    (false, 90),
                    (nil, 100)
                ]
            }
        }
    }
    
    static var overlayTones: [Int] = {
        [01, 02, 05, 10, 20, 30, 40, 50, 60, 70, 80, 90, 95, 98, 99]
    }()
    
    static func overlay(light: Bool?) -> Color {
        guard let light else { return .clear }
        return light ? lightestColor : darkestColor
    }

    // HCT Conversion
    private static let toneValues = [01, 02, 05, 10, 20, 30, 40, 50, 60, 70, 80, 90, 95, 98, 99]
    static var tonesCount: Int { tones(light: false).count }
    static func tones(light: Bool) -> [Int] { Array((light ? toneValues.reversed() : toneValues).dropFirst()) }
}
