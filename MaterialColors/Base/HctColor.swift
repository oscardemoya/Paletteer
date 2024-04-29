//
//  HctColor.swift
//  MaterialColors
//
//  Created by Oscar De Moya on 28/04/24.
//

import SwiftUI

extension Color {
    init(hctColor: Hct) {
        let argb = hctColor.toInt()
        let red = ColorUtils.redFromArgb(argb)
        let green = ColorUtils.greenFromArgb(argb)
        let blue = ColorUtils.blueFromArgb(argb)
        self.init(.sRGB, red: Double(red) / 255.0, green: Double(green) / 255.0, blue: Double(blue) / 255.0)
    }
}

extension Hct {
    var label: String {
        return "H\(Int(hue)) C\(Int(chroma)) T\(Int(tone))"
    }
}
