//
//  ColorString.swift
//  Paletteer
//
//  Created by Oscar De Moya on 27/05/24.
//

import SwiftUI

extension String {
    
    var color: Color? {
        if let color = color(fromHCTString: self) { return color }
        if let color = color(fromHexString: self) { return color }
        return nil
    }
    
    func color(fromHCTString string: String) -> Color? {
        let bodyRegex = /H(?<hue>\d+)\s* C(?<chroma>\d+)\s* T(?<tone>\d+)/.ignoresCase().dotMatchesNewlines()
        return string.matches(of: bodyRegex).compactMap { match -> Color? in
            guard let hue = Double(match.output.hue) else { return nil }
            guard let chroma = Double(match.output.chroma) else { return nil }
            guard let tone = Double(match.output.tone) else { return nil }
            let hct = Hct.from(hue, chroma, tone)
            return Color(hctColor: hct)
        }.first
    }
    
    func color(fromHexString string: String) -> Color? {
        let bodyRegex = /#?(?<hexString>[a-f0-9]{6})/.ignoresCase().dotMatchesNewlines()
        return string.matches(of: bodyRegex).compactMap { match -> Color? in
            let hexString = String(match.output.hexString)
            return Color(hex: hexString)
        }.first
    }
    
}
