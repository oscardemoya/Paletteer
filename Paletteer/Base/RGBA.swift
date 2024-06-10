//
//  RGBA.swift
//  Paletteer
//
//  Created by Oscar De Moya on 9/06/24.
//

import Foundation

struct RGBA: Codable, RawRepresentable {
    var red: CGFloat
    var green: CGFloat
    var blue: CGFloat
    var alpha: CGFloat
    
    static var black = RGBA(red: 0, green: 0, blue: 0)
    
    var label: String { rawValue }
    
    var rawValue: String {
        if alpha != 1.0 {
            "H\(Int(round(red * 255))) S\(Int(round(green * 255))) B\(Int(round(blue * 255))) A\(Int(round(alpha * 255)))"
        } else {
            "H\(Int(round(red * 255))) S\(Int(round(green * 255))) B\(Int(round(blue * 255)))"
        }
    }

    init?(rawValue: String) {
        self = rawValue.rgba
    }
    
    init(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat = 1.0) {
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }
}
