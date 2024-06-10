//
//  ColorString.swift
//  Paletteer
//
//  Created by Oscar De Moya on 27/05/24.
//

import SwiftUI

extension String {
    
    var color: ColorModel? {
        if let color = self.hct { return .hct(color) }
        if let color = color(fromHexString: self) { return .rgb(color) }
        return nil
    }
    
    var hct: Hct? {
        let bodyRegex = /H(?<hue>\d+)\s* C(?<chroma>\d+)\s* T(?<tone>\d+)/.ignoresCase().dotMatchesNewlines()
        return self.matches(of: bodyRegex).compactMap { match -> Hct? in
            guard let hue = Double(match.output.hue) else { return nil }
            guard let chroma = Double(match.output.chroma) else { return nil }
            guard let tone = Double(match.output.tone) else { return nil }
            return Hct.from(hue, chroma, tone)
        }.first
    }
    
    var hsba: HSBA? {
        let bodyRegex = /H(?<hue>\d+)\s* S(?<saturation>\d+)\s* B(?<brightness>\d+)/.ignoresCase().dotMatchesNewlines()
        return self.matches(of: bodyRegex).compactMap { match -> HSBA? in
            guard let hue = Double(match.output.hue) else { return nil }
            guard let saturation = Double(match.output.saturation) else { return nil }
            guard let brightness = Double(match.output.brightness) else { return nil }
            return HSBA(hue: hue, saturation: saturation, brightness: brightness)
        }.first
    }
    
//    func rgba(fromHSBString string: String) -> RGBA? {
//        let bodyRegex = /R(?<red>\d+)\s* G(?<green>\d+)\s* B(?<blue>\d+)/.ignoresCase().dotMatchesNewlines()
//        return string.matches(of: bodyRegex).compactMap { match -> HSBA? in
//            guard let red = Double(match.output.red) else { return nil }
//            guard let green = Double(match.output.green) else { return nil }
//            guard let blue = Double(match.output.blue) else { return nil }
//            return HSBA(hue: hue, saturation: saturation, brightness: brightness)
//        }.first
//    }
    
    func color(fromHexString string: String) -> Color? {
        let bodyRegex = /#(?<hexString>[a-f0-9]{6})/.ignoresCase().dotMatchesNewlines()
        return string.matches(of: bodyRegex).compactMap { match -> Color? in
            let hexString = String(match.output.hexString)
            return Color(hex: hexString)
        }.first
    }
    
}
