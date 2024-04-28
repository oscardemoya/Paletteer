//
//  IntFormatting.swift
//  MaterialColors
//
//  Created by Oscar De Moya on 28/04/24.
//

import Foundation

extension Int {
    var hexStringWithPrefix: String {
        String(format: "0x%02X", self)
    }
}
