//
//  UserDefaults.swift
//  Paletteer
//
//  Created by Oscar De Moya on 28/04/24.
//

import SwiftUI

func key(_ key: UserDefaults.Key) -> String { key.rawValue }

extension UserDefaults {
    enum Key: String, CaseIterable {
        case colorScheme
        case clipboardColors
        case colorPalette
        case showCopyIcons
        case useColorInClipboard
        // Settings
        case colorPaletteParams
        case colorSkipCount
        case colorSkipScheme
        // HCT
        case hctDarkColorsHueOffset
        case hctLightChromaFactor
        case hctDarkChromaFactor
        case hctLightToneFactor
        case hctDarkToneFactor
        // HSB
        case hsbDarkColorsHueOffset
        case hsbLightSaturationFactor
        case hsbDarkSaturationFactor
        case hsbLightBrightnessFactor
        case hsbDarkBrightnessFactor
        // RBG
        case rgbDarkColorsHueOffset
        case rgbLightSaturationFactor
        case rgbDarkSaturationFactor
        case rgbLightBrightnessFactor
        case rgbDarkBrightnessFactor
    }
}

extension Array: RawRepresentable where Element: Codable {
    public var rawValue: String {
        guard let data = try? JSONEncoder().encode(self),
              let result = String(data: data, encoding: .utf8)
        else {
            return "[]"
        }
        return result
    }
    
    public init?(rawValue: String) {
        guard let data = rawValue.data(using: .utf8),
              let result = try? JSONDecoder().decode([Element].self, from: data)
        else {
            return nil
        }
        self = result
    }
}
