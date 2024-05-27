//
//  CodableColor.swift
//  Paletteer
//
//  Created by Oscar De Moya on 27/05/24.
//

import SwiftUI

extension Color: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let hex = try container.decode(String.self)
        self.init(hex: hex)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(hexRGBA)
    }
}
