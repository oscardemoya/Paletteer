//
//  ColorSpace.swift
//  MaterialColors
//
//  Created by Oscar De Moya on 28/04/24.
//

import SwiftUI

enum ColorSpace: String, CaseIterable, Identifiable {
    case hct
    case rgb
    
    var id: Self { self }
    
    var title: String {
        rawValue.uppercased()
    }
}
