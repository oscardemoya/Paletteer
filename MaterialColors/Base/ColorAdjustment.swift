//
//  ColorAdjustment.swift
//  MaterialColors
//
//  Created by Oscar De Moya on 12/05/24.
//

import SwiftUI

extension Color {
    func adjust(hue: CGFloat = 0, saturation: CGFloat = 0, brightness: CGFloat = 0, opacity: CGFloat = 1) -> Color {
        let color = UIColor(self)
        var currentHue: CGFloat = 0
        var currentSaturation: CGFloat = 0
        var currentBrigthness: CGFloat = 0
        var currentOpacity: CGFloat = 0
        guard color.getHue(&currentHue,
                           saturation: &currentSaturation,
                           brightness: &currentBrigthness,
                           alpha: &currentOpacity) else {
            return self
        }
        return Color(hue: currentHue + hue,
                     saturation: currentSaturation + saturation,
                     brightness: currentBrigthness + brightness,
                     opacity: currentOpacity + opacity)
    }
}
