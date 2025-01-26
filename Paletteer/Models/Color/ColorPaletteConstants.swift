//
//  ColorPaletteConstants.swift
//  Paletteer
//
//  Created by Oscar De Moya on 28/04/24.
//

import SwiftUI

struct ColorPaletteConstants {
    static var shadesCount: Int { ColorPaletteConstants.tonesCount }
    static var lightestColor: Color = Color(hex: "#FFFFFF")
    static var darkestColor: Color = Color(hex: "#000000")
    static func overlay(light: Bool) -> Color { light ? lightestColor : darkestColor }
    static let toneNames  = [01, 02, 05, 10, 20, 30, 40, 50, 60, 70, 80, 90, 95, 98, 99, 100]
    static let lightTones = [99, 98, 95, 90, 85, 80, 75, 70, 60, 50, 40, 30, 20, 10, 05, 01]
    static let darkTones  = [05, 06, 08, 10, 15, 20, 30, 40, 50, 60, 70, 80, 90, 95, 98, 99]
    static var tonesCount: Int { tones(light: false).count }
    
    static func tones(light: Bool) -> [Int] {
        light ? lightTones : darkTones
    }
}

struct ColorPaletteParams: Codable, RawRepresentable {
    var colorSkipCount = 1
    var colorSkipScheme: AppColorScheme = .dark
    // HCT
    var hctDarkColorsHueOffset = 0.02
    var hctLightChromaFactor = 1.0
    var hctDarkChromaFactor = 0.75
    var hctLightToneFactor = 1.0
    var hctDarkToneFactor = 0.95
    // HSB
    var hsbDarkColorsHueOffset = 0.01
    var hsbLightSaturationFactor = 2.52
    var hsbDarkSaturationFactor = 2.0
    var hsbLightBrightnessFactor = 1.5
    var hsbDarkBrightnessFactor = 1.5
    // RGB
    var rgbDarkColorsHueOffset = 0.02
    var rgbBlendIntensityFactor = 0.55
    var rgbLightSaturationFactor = 0.01
    var rgbDarkSaturationFactor = -0.01
    var rgbLightBrightnessFactor = 0.05
    var rgbDarkBrightnessFactor = -0.05
    
    init() {}
    
    // Codable
    
    enum CodingKeys: CodingKey {
        case colorSkipCount
        case colorSkipScheme
        case hctDarkColorsHueOffset
        case hctLightChromaFactor
        case hctDarkChromaFactor
        case hctLightToneFactor
        case hctDarkToneFactor
        case hsbDarkColorsHueOffset
        case hsbLightSaturationFactor
        case hsbDarkSaturationFactor
        case hsbLightBrightnessFactor
        case hsbDarkBrightnessFactor
        case rgbDarkColorsHueOffset
        case rgbBlendIntensityFactor
        case rgbLightSaturationFactor
        case rgbDarkSaturationFactor
        case rgbLightBrightnessFactor
        case rgbDarkBrightnessFactor
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.colorSkipCount = try container.decode(Int.self, forKey: .colorSkipCount)
        self.colorSkipScheme = try container.decode(AppColorScheme.self, forKey: .colorSkipScheme)
        self.hctDarkColorsHueOffset = try container.decode(Double.self, forKey: .hctDarkColorsHueOffset)
        self.hctLightChromaFactor = try container.decode(Double.self, forKey: .hctLightChromaFactor)
        self.hctDarkChromaFactor = try container.decode(Double.self, forKey: .hctDarkChromaFactor)
        self.hctLightToneFactor = try container.decode(Double.self, forKey: .hctLightToneFactor)
        self.hctDarkToneFactor = try container.decode(Double.self, forKey: .hctDarkToneFactor)
        self.hsbDarkColorsHueOffset = try container.decode(Double.self, forKey: .hsbDarkColorsHueOffset)
        self.hsbLightSaturationFactor = try container.decode(Double.self, forKey: .hsbLightSaturationFactor)
        self.hsbDarkSaturationFactor = try container.decode(Double.self, forKey: .hsbDarkSaturationFactor)
        self.hsbLightBrightnessFactor = try container.decode(Double.self, forKey: .hsbLightBrightnessFactor)
        self.hsbDarkBrightnessFactor = try container.decode(Double.self, forKey: .hsbDarkBrightnessFactor)
        self.rgbDarkColorsHueOffset = try container.decode(Double.self, forKey: .rgbDarkColorsHueOffset)
        self.rgbBlendIntensityFactor = try container.decode(Double.self, forKey: .rgbBlendIntensityFactor)
        self.rgbLightSaturationFactor = try container.decode(Double.self, forKey: .rgbLightSaturationFactor)
        self.rgbDarkSaturationFactor = try container.decode(Double.self, forKey: .rgbDarkSaturationFactor)
        self.rgbLightBrightnessFactor = try container.decode(Double.self, forKey: .rgbLightBrightnessFactor)
        self.rgbDarkBrightnessFactor = try container.decode(Double.self, forKey: .rgbDarkBrightnessFactor)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(colorSkipCount, forKey: .colorSkipCount)
        try container.encode(colorSkipScheme, forKey: .colorSkipScheme)
        try container.encode(hctDarkColorsHueOffset, forKey: .hctDarkColorsHueOffset)
        try container.encode(hctLightChromaFactor, forKey: .hctLightChromaFactor)
        try container.encode(hctDarkChromaFactor, forKey: .hctDarkChromaFactor)
        try container.encode(hctLightToneFactor, forKey: .hctLightToneFactor)
        try container.encode(hctDarkToneFactor, forKey: .hctDarkToneFactor)
        try container.encode(hsbDarkColorsHueOffset, forKey: .hsbDarkColorsHueOffset)
        try container.encode(hsbLightSaturationFactor, forKey: .hsbLightSaturationFactor)
        try container.encode(hsbDarkSaturationFactor, forKey: .hsbDarkSaturationFactor)
        try container.encode(hsbLightBrightnessFactor, forKey: .hsbLightBrightnessFactor)
        try container.encode(hsbDarkBrightnessFactor, forKey: .hsbDarkBrightnessFactor)
        try container.encode(rgbDarkColorsHueOffset, forKey: .rgbDarkColorsHueOffset)
        try container.encode(rgbBlendIntensityFactor, forKey: .rgbBlendIntensityFactor)
        try container.encode(rgbLightSaturationFactor, forKey: .rgbLightSaturationFactor)
        try container.encode(rgbDarkSaturationFactor, forKey: .rgbDarkSaturationFactor)
        try container.encode(rgbLightBrightnessFactor, forKey: .rgbLightBrightnessFactor)
        try container.encode(rgbDarkBrightnessFactor, forKey: .rgbDarkBrightnessFactor)
    }
    
    // RawRepresentable
    
    var rawValue: String {
        guard let data = try? JSONEncoder().encode(self),
              let result = String(data: data, encoding: .utf8) else {
            return ""
        }
        return result
    }
    
    init?(rawValue: String) {
        guard let data = rawValue.data(using: .utf8),
              let result = try? JSONDecoder().decode(Self.self, from: data) else {
            return nil
        }
        self = result
    }
}

#Preview {
    @Previewable @State var colorPalette: ColorPalette? = ColorPalette.makeSample()
    ColorPalettePreview(colorPalette: colorPalette)
}
