//
//  ColorString.swift
//  Paletteer
//
//  Created by Oscar De Moya on 27/05/24.
//

import SwiftUI

extension String {
    
    var color: ColorModel? {
        if let color = color(fromHCTString: self) { return .hct(color) }
        if let color = color(fromHexString: self) { return .rgb(color) }
        return nil
    }
    
    func color(fromHCTString string: String) -> Hct? {
        let bodyRegex = /H(?<hue>\d+)\s* C(?<chroma>\d+)\s* T(?<tone>\d+)/.ignoresCase().dotMatchesNewlines()
        return string.matches(of: bodyRegex).compactMap { match -> Hct? in
            guard let hue = Double(match.output.hue) else { return nil }
            guard let chroma = Double(match.output.chroma) else { return nil }
            guard let tone = Double(match.output.tone) else { return nil }
            return Hct.from(hue, chroma, tone)
        }.first
    }
    
    func color(fromHexString string: String) -> Color? {
        let bodyRegex = /#(?<hexString>[a-f0-9]{6})/.ignoresCase().dotMatchesNewlines()
        return string.matches(of: bodyRegex).compactMap { match -> Color? in
            let hexString = String(match.output.hexString)
            return Color(hex: hexString)
        }.first
    }
    
}
