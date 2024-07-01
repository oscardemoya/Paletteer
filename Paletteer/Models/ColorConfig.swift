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
    var lightConfig = SchemeConfig(scale: .darkening)
    var darkConfig = SchemeConfig(scale: .lightening)
    
    var color: Color { colorModel.color }
    var hexColor: String { colorModel.color.hexRGB }
    var hctColor: Hct? { colorModel.hctColor }
    
    init(
        id: String = UUID().uuidString,
        colorModel: ColorModel,
        colorName: String,
        groupName: String = "",
        lightConfig: SchemeConfig = SchemeConfig(scale: .darkening),
        darkConfig: SchemeConfig = SchemeConfig(scale: .lightening)
    ) {
        self.id = id
        self.colorModel = colorModel
        self.colorName = colorName
        self.groupName = groupName
        self.lightConfig = lightConfig
        self.darkConfig = darkConfig
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
        if let description = lightConfig.description(defaultScale: .darkening) {
            components.append("L{\(description)}")
        }
        if let description = darkConfig.description(defaultScale: .lightening) {
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
}
