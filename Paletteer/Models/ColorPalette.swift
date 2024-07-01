//
//  ColorPalette.swift
//  Paletteer
//
//  Created by Oscar De Moya on 28/04/24.
//

import SwiftUI

struct ColorPalette {
    static var shadesCount: Int { ColorPalette.tonesCount }
    static var lightestColor: Color = Color(hex: "#FFFFFF")
    static var darkestColor: Color = Color(hex: "#080808")
    static func overlay(light: Bool) -> Color { light ? lightestColor : darkestColor }
    static let lightTones = [98, 95, 90, 85, 80, 75, 70, 60, 50, 40, 30, 20, 10]
    static let darkTones  = [02, 05, 10, 20, 30, 40, 50, 60, 70, 80, 90, 95, 98]
    static var tonesCount: Int { tones(light: false).count }
    
    static func tones(light: Bool) -> [Int] {
        light ? lightTones : darkTones
    }
}

struct ColorPaletteParams {
    // HCT
    static var hctDarkColorsHueOffset = 0.02
    static var hctLightChromaFactor = 1.0
    static var hctDarkChromaFactor = 0.75
    static var hctLightToneFactor = 1.0
    static var hctDarkToneFactor = 0.95
    // HSB
    static var hsbDarkColorsHueOffset = 0.01
    static var hsbLightSaturationFactor = 2.5
    static var hsbDarkSaturationFactor = 2.0
    static var hsbLightBrightnessFactor = 1.25
    static var hsbDarkBrightnessFactor = 1.5
    // RGB
    static var rgbDarkColorsHueOffset = 0.02
    static var rgbBlendIntensityFactor = 0.55
    static var rgbLightSaturationFactor = 0.01
    static var rgbDarkSaturationFactor = -0.01
    static var rgbLightBrightnessFactor = 0.05
    static var rgbDarkBrightnessFactor = -0.05
}

#Preview {
    ColorPaletteView(colorList: .sample, colorSpace: .hsb)
}
