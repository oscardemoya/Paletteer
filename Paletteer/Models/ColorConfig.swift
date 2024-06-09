//
//  ColorConfig.swift
//  Paletteer
//
//  Created by Oscar De Moya on 28/04/24.
//

import SwiftUI

struct ColorConfig: Codable, RawRepresentable, Identifiable, Hashable {
    var id: String = UUID().uuidString
    var colorModel: ColorModel
    var colorName: String
    var groupName: String = ""
    var lightColorScale: ColorScale = .darkening
    var darkColorScale: ColorScale = .lightening
    var colorRange: ColorRange = .whole
    
    var color: Color { colorModel.color }
    var hexColor: String { colorModel.color.hexRGB }
    var hctColor: Hct? { colorModel.hctColor }
    
    init(
        id: String = UUID().uuidString,
        colorModel: ColorModel,
        colorName: String,
        groupName: String = "",
        lightColorScale: ColorScale = .darkening,
        darkColorScale: ColorScale = .lightening,
        colorRange: ColorRange = .whole
    ) {
        self.id = id
        self.colorModel = colorModel
        self.colorName = colorName
        self.groupName = groupName
        self.lightColorScale = lightColorScale
        self.darkColorScale = darkColorScale
        self.colorRange = colorRange
    }
    
    mutating func update(with other: Self) {
        self.colorModel = other.colorModel
        self.colorName = other.colorName
        self.groupName = other.groupName
        self.lightColorScale = other.lightColorScale
        self.darkColorScale = other.darkColorScale
        self.colorRange = other.colorRange
    }
    
    func hash(into hasher: inout Hasher) {
        var hasher = hasher
        hasher.combine(id)
        hasher.combine(colorModel)
        hasher.combine(colorName)
        hasher.combine(groupName)
        hasher.combine(lightColorScale)
        hasher.combine(darkColorScale)
        hasher.combine(colorRange)
    }
    
    var colorDescription: String {
        "\(!groupName.isEmpty ? groupName + "/" : "")" +
        "\(colorName): \(color.hexRGB.uppercased())"
//        +
//        "\(lightColorScale.isLightening ? "": "")" +
//        "\(darkColorScale.isDarkening ? "": "")" +
//        "\(!rangeWidth.isWhole ? "[\()]": "")"
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
            lightColorScale: result.lightColorScale,
            darkColorScale: result.darkColorScale,
            colorRange: result.colorRange
        )
    }

    enum CodingKeys: String, CodingKey {
        case id
        case colorModel
        case groupName
        case colorName
        case lightColorScale
        case darkColorScale
        case colorRange
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        colorModel = try container.decode(ColorModel.self, forKey: .colorModel)
        colorName = try container.decode(String.self, forKey: .colorName)
        groupName = try container.decode(String.self, forKey: .groupName)
        lightColorScale = try container.decode(ColorScale.self, forKey: .lightColorScale)
        darkColorScale = try container.decode(ColorScale.self, forKey: .darkColorScale)
        colorRange = try container.decode(ColorRange.self, forKey: .colorRange)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(colorModel, forKey: .colorModel)
        try container.encode(colorName, forKey: .colorName)
        try container.encode(groupName, forKey: .groupName)
        try container.encode(lightColorScale, forKey: .lightColorScale)
        try container.encode(darkColorScale, forKey: .darkColorScale)
        try container.encode(colorRange, forKey: .colorRange)
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
        ColorConfig(colorModel: .rgb(Color(hex: "#A9A8AC")), colorName: "Background", groupName: "Neutral",
                    lightColorScale: .lightening, colorRange: .firstQuarter),
        ColorConfig(colorModel: .rgb(Color(hex: "#525354")), colorName: "Foreground", groupName: "Neutral",
                    lightColorScale: .lightening, darkColorScale: .darkening)
    ]}
}
