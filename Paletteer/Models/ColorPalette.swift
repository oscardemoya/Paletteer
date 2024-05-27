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
    static var darkestColor: Color = Color(hex: "#080808") ?? .black
    static var overlaysCount: Int { overlayOpacities(light: true, narrow: false).count }
    
    static func overlayOpacities(light: Bool, narrow: Bool) -> [(Bool?, Int)] {
        if narrow {
            if light {
                [
                    (true, 01),
                    (true, 02),
                    (true, 05),
                    (true, 10),
                    (true, 20),
                    (true, 30),
                    (true, 40),
                    (true, 50),
                    (true, 60),
                    (true, 70),
                    (true, 80),
                    (true, 90),
                    (true, 95),
                    (true, 100)
                ]
            } else {
                [
                    (false, 100),
                    (false, 98),
                    (false, 95),
                    (false, 90),
                    (false, 85),
                    (false, 80),
                    (false, 70),
                    (false, 60),
                    (false, 50),
                    (false, 40),
                    (false, 30),
                    (false, 20),
                    (false, 10),
                    (false, 01)
                ]
            }
        } else {
            if light {
                [
                    (true, 02),
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
                    (false, 20),
                    (false, 10),
                    (false, 02)
                ]
            } else {
                [
                    (false, 02),
                    (false, 05),
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
                    (true, 20),
                    (true, 10)
                ]
            }
        }
    }
    
    static var overlayTones: [Int] = {
        [01, 05, 10, 15, 20, 30, 40, 50, 60, 70, 80, 85, 90, 95]
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
