//
//  ColorConfig.swift
//  Paletteer
//
//  Created by Oscar De Moya on 28/04/24.
//

import SwiftUI

struct ColorConfig: Identifiable, Hashable {
    var id: String = UUID().uuidString
    var colorModel: ColorModel
    var groupName: String = ""
    var colorName: String
    var lightColorScale: ColorScale = .darkening
    var darkColorScale: ColorScale = .lightening
    var rangeWidth: ColorRangeWidth = .full
    
    var color: Color { colorModel.color }
    var hexColor: String { colorModel.color.hexRGB }
    var hctColor: Hct? { colorModel.hctColor }
    
    func hash(into hasher: inout Hasher) {
        var hasher = hasher
        hasher.combine(id)
        hasher.combine(colorModel)
        hasher.combine(groupName)
        hasher.combine(colorName)
        hasher.combine(lightColorScale)
        hasher.combine(darkColorScale)
        hasher.combine(rangeWidth)
    }
}

extension ColorConfig: RawRepresentable {
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
        self = result
    }
}

extension ColorConfig: Codable {
    enum CodingKeys: String, CodingKey {
        case id
        case colorModel
        case groupName
        case colorName
        case lightColorScale
        case darkColorScale
        case rangeWidth
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        colorModel = try container.decode(ColorModel.self, forKey: .colorModel)
        groupName = try container.decode(String.self, forKey: .groupName)
        colorName = try container.decode(String.self, forKey: .colorName)
        lightColorScale = try container.decode(ColorScale.self, forKey: .lightColorScale)
        darkColorScale = try container.decode(ColorScale.self, forKey: .darkColorScale)
        rangeWidth = try container.decode(ColorRangeWidth.self, forKey: .rangeWidth)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(colorModel, forKey: .colorModel)
        try container.encode(groupName, forKey: .groupName)
        try container.encode(colorName, forKey: .colorName)
        try container.encode(lightColorScale, forKey: .lightColorScale)
        try container.encode(darkColorScale, forKey: .darkColorScale)
        try container.encode(rangeWidth, forKey: .rangeWidth)
    }
}
