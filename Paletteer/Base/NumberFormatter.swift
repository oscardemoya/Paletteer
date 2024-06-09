//
//  NumberFormatter.swift
//  Paletteer
//
//  Created by Oscar De Moya on 8/06/24.
//

import Foundation

public extension NumberFormatter {
    static var decimal: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 0
        formatter.isLenient = true
        return formatter
    }()
}
