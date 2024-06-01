//
//  ColorConfig.swift
//  Paletteer
//
//  Created by Oscar De Moya on 28/04/24.
//

import SwiftUI

struct ColorConfig: Codable, Identifiable, Hashable {
    var id: String = UUID().uuidString
    var color: Color
    var groupName: String = ""
    var colorName: String
    var reversed: Bool = false
    var narrow: Bool = false
    
    var hexColor: String { color.hexRGB }
    
    func hash(into hasher: inout Hasher) {
        var hasher = hasher
        hasher.combine(hexColor)
        hasher.combine(groupName)
        hasher.combine(colorName)
        hasher.combine(reversed)
        hasher.combine(narrow)
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
    
    enum CodingKeys: String, CodingKey {
        case id
        case color
        case groupName
        case colorName
        case reversed
        case narrow
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        color = try container.decode(Color.self, forKey: .color)
        groupName = try container.decode(String.self, forKey: .groupName)
        colorName = try container.decode(String.self, forKey: .colorName)
        reversed = try container.decode(Bool.self, forKey: .reversed)
        narrow = try container.decode(Bool.self, forKey: .narrow)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(color, forKey: .color)
        try container.encode(groupName, forKey: .groupName)
        try container.encode(colorName, forKey: .colorName)
        try container.encode(reversed, forKey: .reversed)
        try container.encode(narrow, forKey: .narrow)
    }
}
