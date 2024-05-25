//
//  HCTColor.swift
//  Paletteer
//
//  Created by Oscar De Moya on 28/04/24.
//

import SwiftUI

extension Color {
    init(hctColor: Hct) {
        self.init(argb: hctColor.toInt())
    }
}

extension Hct {
    var label: String {
        return "H\(Int(hue)) C\(Int(chroma)) T\(Int(tone))"
    }
}
