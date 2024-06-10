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
    static let toneValues = [01, 05, 10, 15, 20, 30, 40, 50, 60, 70, 80, 85, 90, 95, 99]
    static var tonesCount: Int { tones(light: false).count }
    static func tones(light: Bool) -> [Int] { Array((light ? toneValues.reversed() : toneValues).dropFirst()) }
}

struct ColorPaletteParams {
    // HCT
    static var hctDarkColorsHueOffset = 0.02
    static var hctLightChromaFactor = 1.0
    static var hctDarkChromaFactor = 0.75
    static var hctLightToneFactor = 1.0
    static var hctDarkToneFactor = 0.95
    // HSB
    static var hsbDarkColorsHueOffset = 0.02
    static var hsbLightSaturationFactor = 2.0
    static var hsbDarkSaturationFactor = 1.5
    static var hsbLightBrightnessFactor = 1.5
    static var hsbDarkBrightnessFactor = 0.85
    // RGB
    static var rgbDarkColorsHueOffset = 0.02
    static var rgbBlendIntensityFactor = 0.55
    static var rgbLightSaturationFactor = 0.01
    static var rgbDarkSaturationFactor = -0.01
    static var rgbLightBrightnessFactor = 0.05
    static var rgbDarkBrightnessFactor = -0.05
}

#Preview {
    ColorPaletteView(colorList: .sample, colorSpace: .hct)
}
