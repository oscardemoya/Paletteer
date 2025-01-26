//
//  SchemeConfig.swift
//  Paletteer
//
//  Created by Oscar De Moya on 27/06/24.
//

import Foundation

struct SchemeConfig: Codable, RawRepresentable, Hashable {
    var scale: ColorScale = .lightening
    var range: ColorRange = .whole
    var saturationLevel: ColorAdjustmentLevel = .medium
    var brightnessLevel: ColorAdjustmentLevel = .medium
    var skipDirection: SkipDirection = .forward

    var isWholeLightening: Bool {
        guard range == .whole else { return false }
        return scale == .lightening
    }
    
    var isWholeDarkening: Bool {
        guard range == .whole else { return false }
        return scale == .darkening
    }
    
    init(
        scale: ColorScale = .darkening,
        range: ColorRange = .whole,
        saturationLevel: ColorAdjustmentLevel = .medium,
        brightnessLevel: ColorAdjustmentLevel = .medium,
        skipDirection: SkipDirection = .forward
    ) {
        self.scale = scale
        self.range = range
        self.saturationLevel = saturationLevel
        self.brightnessLevel = brightnessLevel
        self.skipDirection = skipDirection
    }
    
    init(description: String, defaultScale: ColorScale, defaultSkip: SkipDirection) {
        var scale: ColorScale = defaultScale
        var range: ColorRange = .whole
        var saturationLevel: ColorAdjustmentLevel = .medium
        var brightnessLevel: ColorAdjustmentLevel = .medium
        var skipDirection: SkipDirection = defaultSkip
        description.split(separator: ";").forEach { substring in
            let string = String(substring)
            let value = String(string.suffix(1))
            switch String(substring.prefix(1)) {
            case "<": scale = .lightening
            case ">": scale = .darkening
            case "[": range = ColorRange(percentDescription: string) ?? .whole
            case "S": saturationLevel = ColorAdjustmentLevel(symbol: value)
            case "B": brightnessLevel = ColorAdjustmentLevel(symbol: value)
            case "⏩︎": skipDirection = .forward
            case "⏪︎": skipDirection = .backward
            default: break
            }
        }
        self.init(scale: scale, range: range, saturationLevel: saturationLevel, brightnessLevel: brightnessLevel, skipDirection: skipDirection)
    }
    
    mutating func update(with other: Self) {
        self.scale = other.scale
        self.range = other.range
        self.saturationLevel = other.saturationLevel
        self.brightnessLevel = other.brightnessLevel
        self.skipDirection = other.skipDirection
    }
    
    func description(defaultScale: ColorScale, defaultSkip: SkipDirection) -> String? {
        var components = [String]()
        if scale != defaultScale {
            components.append(scale.symbol)
        }
        if !range.width.isWhole {
            components.append(range.percentDescription)
        }
        if brightnessLevel != .medium {
            components.append("B\(brightnessLevel.symbol)")
        }
        if saturationLevel != .medium {
            components.append("S\(saturationLevel.symbol)")
        }
        if skipDirection != defaultSkip {
            components.append(skipDirection.symbol)
        }
        guard !components.isEmpty else { return nil }
        return components.joined(separator: ";")
    }
    
    // Codable
    
    enum CodingKeys: String, CodingKey {
        case scale
        case range
        case saturationLevel
        case brightnessLevel
        case skipDirection
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        scale = try container.decode(ColorScale.self, forKey: .scale)
        range = try container.decode(ColorRange.self, forKey: .range)
        saturationLevel = try container.decode(ColorAdjustmentLevel.self, forKey: .saturationLevel)
        brightnessLevel = try container.decode(ColorAdjustmentLevel.self, forKey: .brightnessLevel)
        skipDirection = try container.decode(SkipDirection.self, forKey: .skipDirection)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(scale, forKey: .scale)
        try container.encode(range, forKey: .range)
        try container.encode(saturationLevel, forKey: .saturationLevel)
        try container.encode(brightnessLevel, forKey: .brightnessLevel)
        try container.encode(skipDirection, forKey: .skipDirection)
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
        self.init(
            scale: result.scale,
            range: result.range,
            saturationLevel: result.saturationLevel,
            brightnessLevel: result.brightnessLevel
        )
    }
    
    // Hashable
    
    func hash(into hasher: inout Hasher) {
        var hasher = hasher
        hasher.combine(scale)
        hasher.combine(range)
        hasher.combine(saturationLevel)
        hasher.combine(brightnessLevel)
        hasher.combine(skipDirection)
    }
}
