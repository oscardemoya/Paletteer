//
//  ColorPair.swift
//  Paletteer
//
//  Created by Oscar De Moya on 28/04/24.
//

import SwiftUI

struct ColorPair: Identifiable {
    var id: String = UUID().uuidString
    var light: Color
    var dark: Color
}
