//
//  HSBA.swift
//  Paletteer
//
//  Created by Oscar De Moya on 9/06/24.
//

import Foundation

struct HSBA: Codable, RawRepresentable {
    var hue: CGFloat
    var saturation: CGFloat
    var brightness: CGFloat
    var alpha: CGFloat
    
    static var black = HSBA(hue: 0, saturation: 0, brightness: 0)
    
    var label: String { rawValue }
    
    var rawValue: String {
        if alpha != 1.0 {
            "H\(Int(round(hue * 255))) S\(Int(round(saturation * 255))) B\(Int(round(brightness * 255))) A\(Int(round(alpha * 255)))"
        } else {
            "H\(Int(round(hue * 255))) S\(Int(round(saturation * 255))) B\(Int(round(brightness * 255)))"
        }
    }

    init?(rawValue: String) {
        guard let hsba = rawValue.hsba else { return nil }
        self = hsba
    }
    
    init(hue: CGFloat, saturation: CGFloat, brightness: CGFloat, alpha: CGFloat = 1.0) {
        self.hue = hue
        self.saturation = saturation
        self.brightness = brightness
        self.alpha = alpha
    }
}
