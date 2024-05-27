//
//  ColorAdjustment.swift
//  Paletteer
//
//  Created by Oscar De Moya on 12/05/24.
//

import SwiftUI

extension Color {
    func adjust(hue: CGFloat = 0, saturation: CGFloat = 0, brightness: CGFloat = 0, opacity: CGFloat = 1) -> Color {
        let color = CrossPlatformColor(self)
        guard let hsba = color.hsba else {
            return self
        }
        return Color(hue: max(min(hsba.hue + hue, 1), 0),
                     saturation: max(min(hsba.saturation + saturation, 1), 0),
                     brightness: max(min(hsba.brightness + brightness, 1), 0),
                     opacity: max(min(hsba.alpha + opacity, 1), 0))
    }
    
    func replace(hue: CGFloat? = nil, saturation: CGFloat? = nil, brightness: CGFloat? = nil, opacity: CGFloat? = nil) -> Color {
        let color = CrossPlatformColor(self)
        guard let hsba = color.hsba else {
            return self
        }
        var new = hsba
        if let hue { new.hue = hue }
        if let saturation { new.saturation = saturation }
        if let brightness { new.brightness = brightness }
        if let opacity { new.alpha = opacity }
        return Color(hue: new.hue, saturation: new.saturation, brightness: new.brightness, opacity: new.alpha)
    }
}
