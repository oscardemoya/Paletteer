//
//  ColorConfig.swift
//  Paletteer
//
//  Created by Oscar De Moya on 28/04/24.
//

import SwiftUI

struct ColorConfig: Codable, RawRepresentable, Identifiable, Hashable, Equatable {
    var id: String = UUID().uuidString
    var colorModel: ColorModel
    var colorName: String
    var groupName: String = ""
    var lightConfig = SchemeConfig(scale: .darkening, skipDirection: .backward)
    var darkConfig = SchemeConfig(scale: .lightening, skipDirection: .forward)
    
    var color: Color { colorModel.color }
    var hexColor: String { colorModel.color.hexRGB }
    var hctColor: Hct? { colorModel.hctColor }
    
    static let colorRegex = /((?<groupName>\w+)\/)?(?<colorName>\w+)\s*: #(?<hexString>[a-f0-9]{6})\s*(L{(?<lightConfig>\S*)?})?\s*(D{(?<darkConfig>\S*)?})?/
        .ignoresCase()
        .dotMatchesNewlines()
    
    init(
        id: String = UUID().uuidString,
        colorModel: ColorModel,
        colorName: String,
        groupName: String = "",
        lightConfig: SchemeConfig = SchemeConfig(scale: .darkening, skipDirection: .backward),
        darkConfig: SchemeConfig = SchemeConfig(scale: .lightening, skipDirection: .forward)
    ) {
        self.id = id
        self.colorModel = colorModel
        self.colorName = colorName
        self.groupName = groupName
        self.lightConfig = lightConfig
        self.darkConfig = darkConfig
    }
    
    init?(from representation: String) {
        let config = representation.matches(of: ColorConfig.colorRegex).compactMap { match -> ColorConfig? in
            let groupName = String(match.output.groupName ?? "")
            let colorName = String(match.output.colorName)
            let hexString = String(match.output.hexString)
            let lightConfig = String(match.output.lightConfig ?? "")
            let darkConfig = String(match.output.darkConfig ?? "")
            return ColorConfig(
                colorModel: .rgb(Color(hex: hexString)),
                colorName: colorName,
                groupName: groupName,
                lightConfig: SchemeConfig(description: lightConfig, defaultScale: .darkening, defaultSkip: .backward),
                darkConfig: SchemeConfig(description: darkConfig, defaultScale: .lightening, defaultSkip: .forward)
            )
        }.first
        guard let config else { return nil }
        self = config
    }
    
    mutating func update(with other: Self) {
        self.colorModel = other.colorModel
        self.colorName = other.colorName
        self.groupName = other.groupName
        self.lightConfig.update(with: other.lightConfig)
        self.darkConfig.update(with: other.darkConfig)
    }
    
    func hash(into hasher: inout Hasher) {
        var hasher = hasher
        hasher.combine(id)
        hasher.combine(colorModel)
        hasher.combine(colorName)
        hasher.combine(groupName)
        hasher.combine(lightConfig)
        hasher.combine(darkConfig)
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        guard lhs.id == rhs.id else { return false }
        guard lhs.colorModel == rhs.colorModel else { return false }
        guard lhs.colorName == rhs.colorName else { return false }
        guard lhs.groupName == rhs.groupName else { return false }
        guard lhs.lightConfig == rhs.lightConfig else { return false }
        guard lhs.darkConfig == rhs.darkConfig else { return false }
        return true
    }
    
    var colorPath: String {
        var components = [String]()
        if !groupName.isEmpty {
            components.append(groupName)
        }
        components.append(colorName)
        return components.joined(separator: "/")
    }
    
    var description: String {
        var components = [String]()
        components.append("\(colorPath): \(color.hexRGB.uppercased())")
        if let description = lightConfig.description(defaultScale: .darkening, defaultSkip: .backward) {
            components.append("L{\(description)}")
        }
        if let description = darkConfig.description(defaultScale: .lightening, defaultSkip: .forward) {
            components.append("D{\(description)}")
        }
        return components.joined(separator: " ")
    }

    var rawValue: String {
        guard let data = try? JSONEncoder().encode(self),
              let result = String(data: data, encoding: .utf8) else {
            return ""
        }
        return result
    }
    
    init?(rawValue: String) {
        guard let data = rawValue.data(using: .utf8),
              let result = try? JSONDecoder().decode(ColorConfig.self, from: data) else {
            return nil
        }
        self.init(
            id: result.id,
            colorModel: result.colorModel,
            colorName: result.colorName,
            groupName: result.groupName,
            lightConfig: result.lightConfig,
            darkConfig: result.darkConfig
        )
    }
    
    func label(for colorSpace: ColorSpace) -> String {
        switch colorSpace {
        case .hct: color.hct?.label ?? ""
        case .hsb: color.hsba?.label ?? ""
        case .rgb: color.hexRGB
        }
    }

    enum CodingKeys: String, CodingKey {
        case id
        case colorModel
        case groupName
        case colorName
        case lightConfig
        case darkConfig
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        colorModel = try container.decode(ColorModel.self, forKey: .colorModel)
        colorName = try container.decode(String.self, forKey: .colorName)
        groupName = try container.decode(String.self, forKey: .groupName)
        lightConfig = try container.decode(SchemeConfig.self, forKey: .lightConfig)
        darkConfig = try container.decode(SchemeConfig.self, forKey: .darkConfig)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(colorModel, forKey: .colorModel)
        try container.encode(colorName, forKey: .colorName)
        try container.encode(groupName, forKey: .groupName)
        try container.encode(lightConfig, forKey: .lightConfig)
        try container.encode(darkConfig, forKey: .darkConfig)
    }
    
    func shades(params: ColorPaletteParams, colorSpace: ColorSpace) -> [ColorPair] {
        let group = self
        let colorCount = ColorPaletteConstants.shadesCount - params.colorSkipCount
        return (0..<colorCount).compactMap { index in
            switch colorSpace {
            case .hct:
                guard let hctColor = group.color.hct else { return nil }
                return .hct(hctColor)
            case .hsb:
                guard let hsbColor = group.color.hsba else { return nil }
                return .hsb(hsbColor)
            case .rgb:
                return .rgb(group.color)
            }
        }.enumerated().map { (index: Int, color: ColorModel) in
            let lightSkip = group.lightConfig.skipDirection.isForward ? params.colorSkipCount : 0
            let darkSkip = group.darkConfig.skipDirection.isForward ? params.colorSkipCount : 0

            // Light Color
            let lightIndex = group.lightConfig.scale.isDarkening ? index + lightSkip : colorCount - index + lightSkip - 1
            let lightConfig = ColorConversion(color: color, index: lightIndex, light: true)
            let lightColor = generateColor(for: group, with: params, for: lightConfig)

            // Dark Color
            let darkIndex = group.darkConfig.scale.isLightening ? index + darkSkip : colorCount - index + darkSkip - 1
            let darkConfig = ColorConversion(color: color, index: darkIndex, light: false)
            let darkColor = generateColor(for: group, with: params, for: darkConfig)

            // Color Pair
            let index = index + (params.colorSkipScheme == .light ? params.colorSkipCount : 0)
            let toneCode = ColorPaletteConstants.toneNames[index]
            let toneName = String(format: "%03d", toneCode * 10)
            return ColorPair(name: group.colorName, toneCode: toneName, light: lightColor.color, dark: darkColor.color)
        }
    }
    
    private func generateColor(for group: ColorConfig, with params: ColorPaletteParams, for config: ColorConversion) -> (color: Color, argb: Int) {
        var color: Color
        var argb: Int
        let tones = ColorPaletteConstants.tones(light: config.light)
        let tone = Double(tones[config.index])
        let transformedTone = transformedTone(tone, group: group, config: config)
        let normalizedTone = min(max(transformedTone / 100, 0), 1)
        switch config.color {
        case .hct(let hctColor):
            hctColor.hue += (config.light ? 0 : params.hctDarkColorsHueOffset)
            hctColor.chroma *= (config.light ? params.hctLightChromaFactor : params.hctDarkChromaFactor)
            hctColor.tone = transformedTone * (config.light ? params.hctLightToneFactor : params.hctDarkToneFactor)
            color = Color(hctColor: hctColor)
            argb = hctColor.toInt()
        case .hsb(let hsbColor):
            var baseColor = hsbColor
            let schemeConfig = (config.light ? group.lightConfig : group.darkConfig)
            baseColor.hue += (config.light ? 0 : params.hsbDarkColorsHueOffset)
            let saturationFactor = (config.light ? params.hsbLightSaturationFactor : params.hsbDarkSaturationFactor)
            let saturationLevel = schemeConfig.saturationLevel.multiplier
            baseColor.saturation *= saturationFactor * normalizedTone.logaritmic(M_E * saturationFactor) * saturationLevel
            var brightnessLevel = schemeConfig.brightnessLevel.multiplier
            brightnessLevel = config.light ? 1 / brightnessLevel : brightnessLevel
            let brightnessFactor = (config.light ? 1 / params.hsbLightBrightnessFactor : params.hsbDarkBrightnessFactor) * brightnessLevel
            baseColor.brightness = normalizedTone.skewed(towards: config.light ? 1 : 0, alpha: brightnessFactor)
            color = Color(hsba: baseColor)
            argb = color.rgbInt ?? 0
        case .rgb(let rgbColor):
            let adjustedValue = normalizedTone.skewed(towards: 0, alpha: 0.75)
            let opacity = (adjustedValue < 0.5 ? adjustedValue : 1 - adjustedValue) * 2
            let overlay = ColorPaletteConstants.overlay(light: adjustedValue > 0.5)
            let blend = Color.blend(color1: rgbColor, intensity1: opacity, color2: overlay, intensity2: (1 - opacity))
            let saturationFactor = config.light ? params.rgbLightSaturationFactor : params.rgbDarkSaturationFactor
            let brightnessFactor = config.light ? params.rgbLightBrightnessFactor : params.rgbDarkBrightnessFactor
            let hueOffset = (config.light ? 0 : params.hctDarkColorsHueOffset)
            let hsbColor = rgbColor.hsba ?? .black
            let saturation = hsbColor.saturation * saturationFactor
            let brightness = hsbColor.brightness * brightnessFactor
            color = blend.adjust(hue: hueOffset, saturation: saturation, brightness: brightness)
            argb = color.rgbInt ?? 0
        }
        return (color: color, argb: argb)
    }
    
    private func transformedTone(_ tone: Double, group: ColorConfig, config: ColorConversion) -> CGFloat {
        let range = (config.light ? group.lightConfig : group.darkConfig).range
        let startPercent = range.startPercent
        let rangeWidthPercent = range.width.percent
        let rangeWidth = range.width.value
        return (config.light ? startPercent : 100 - rangeWidthPercent - startPercent) + (tone * rangeWidth)
    }
}

extension [ColorConfig] {
    static var sample: Self {[
        ColorConfig(colorModel: .rgb(Color(hex: "#689FD4")), colorName: "Primary", groupName: "Brand"),
        ColorConfig(colorModel: .rgb(Color(hex: "#A091D7")), colorName: "Secondary", groupName: "Brand"),
        ColorConfig(colorModel: .rgb(Color(hex: "#E79161")), colorName: "Tertiary", groupName: "Brand"),
        ColorConfig(colorModel: .rgb(Color(hex: "#6EA97A")), colorName: "Success", groupName: "Semantic"),
        ColorConfig(colorModel: .rgb(Color(hex: "#D9C764")), colorName: "Warning", groupName: "Semantic"),
        ColorConfig(colorModel: .rgb(Color(hex: "#DF706F")), colorName: "Error", groupName: "Semantic"),
        ColorConfig(colorModel: .rgb(Color(hex: "#C3C7CB")), colorName: "Background", groupName: "Neutral",
                    lightConfig: SchemeConfig(scale: .lightening, range: .lastQuarter)),
        ColorConfig(colorModel: .rgb(Color(hex: "#525354")), colorName: "Foreground", groupName: "Neutral",
                    lightConfig: SchemeConfig(scale: .lightening),
                    darkConfig: SchemeConfig(scale: .darkening))
    ]}
    
    var representation: String {
        map(\.description).joined(separator: "\n")
    }
}
