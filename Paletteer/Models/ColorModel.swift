//
//  ColorModel.swift
//  Paletteer
//
//  Created by Oscar De Moya on 2/06/24.
//

import SwiftUI

enum ColorModel: Identifiable, Hashable {
    var id: String { rawValue }
    
    case hct(_ value: Hct)
    case hsb(_ value: HSBA)
    case rgb(_ value: Color)
    
    var color: Color {
        switch self {
        case .hct(let hct):
            Color(hctColor: hct)
        case .hsb(let hsba):
            Color(hsba: hsba)
        case .rgb(let color):
            color
        }
    }
    
    var hctColor: Hct? {
        switch self {
        case .hct(let hct): hct
        case .hsb(let hsba): Color(hsba: hsba).hct
        case .rgb(let color): color.hct
        }
    }
}

extension ColorModel: RawRepresentable {
    var rawValue: String {
        guard let data = try? JSONEncoder().encode(self),
              let result = String(data: data, encoding: .utf8) else {
            return ""
        }
        return result
    }
    
    init?(rawValue: String) {
        guard let data = rawValue.data(using: .utf8),
              let result = try? JSONDecoder().decode(ColorModel.self, from: data) else {
            return nil
        }
        self = result
    }
}

extension ColorModel: Codable {
    enum CodingKeys: String, CodingKey {
        case type
        case associatedValue
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        switch type {
        case "hct":
            let color = try container.decode(Hct.self, forKey: .associatedValue)
            self = .hct(color)
        case "hsb":
            let color = try container.decode(HSBA.self, forKey: .associatedValue)
            self = .hsb(color)
        case "rgb":
            let color = try container.decode(Color.self, forKey: .associatedValue)
            self = .rgb(color)
        default:
            throw DecodingError.dataCorruptedError(forKey: .type, in: container, debugDescription: "Invalid type")
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .hct(let color):
            try container.encode("hct", forKey: .type)
            try container.encode(color, forKey: .associatedValue)
        case .hsb(let color):
            try container.encode("hsb", forKey: .type)
            try container.encode(color, forKey: .associatedValue)
        case .rgb(let color):
            try container.encode("rgb", forKey: .type)
            try container.encode(color, forKey: .associatedValue)
        }
    }
}
