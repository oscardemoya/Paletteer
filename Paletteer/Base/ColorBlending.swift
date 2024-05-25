//
//  ColorBlending.swift
//  Paletteer
//
//  Created by Oscar De Moya on 12/05/24.
//

import SwiftUI

public extension Color {
    static func blend(color1: Color, intensity1: CGFloat = 0.5, color2: Color, intensity2: CGFloat = 0.5) -> Color {
        let total = intensity1 + intensity2
        
        let normalisedIntensity1 = intensity1 / total
        let normalisedIntensity2 = intensity2 / total
        
        guard normalisedIntensity1 > 0 else { return color2 }
        guard normalisedIntensity2 > 0 else { return color1 }
        
        guard let (r1, g1, b1, a1) = color1.rgba else { return color2 }
        guard let (r2, g2, b2, a2) = color2.rgba else { return color1 }

        return Color(red: normalisedIntensity1 * r1 + normalisedIntensity2 * r2,
                     green: normalisedIntensity1 * g1 + normalisedIntensity2 * g2,
                     blue: normalisedIntensity1 * b1 + normalisedIntensity2 * b2,
                     opacity: normalisedIntensity1 * a1 + normalisedIntensity2 * a2)
    }
}
