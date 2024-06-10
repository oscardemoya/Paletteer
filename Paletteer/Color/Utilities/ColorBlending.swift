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
        
        guard let rgba1 = color1.rgba else { return color2 }
        guard let rgba2 = color2.rgba else { return color1 }

        return Color(red: normalisedIntensity1 * rgba1.red + normalisedIntensity2 * rgba2.red,
                     green: normalisedIntensity1 * rgba1.green + normalisedIntensity2 * rgba2.green,
                     blue: normalisedIntensity1 * rgba1.blue + normalisedIntensity2 * rgba2.blue,
                     opacity: normalisedIntensity1 * rgba1.alpha + normalisedIntensity2 * rgba2.alpha)
    }
}
