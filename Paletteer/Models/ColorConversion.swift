//
//  ColorConversion.swift
//  Paletteer
//
//  Created by Oscar De Moya on 28/04/24.
//

import SwiftUI

struct ColorConversion {
    var color: ColorMode
    var index: Int
    var light: Bool
}

enum ColorMode {
    case hct(_ value: Hct)
    case rgb(_ value: Color)
}
