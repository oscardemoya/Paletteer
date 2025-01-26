//
//  ColorRepresentable.swift
//  Paletteer
//
//  Created by Oscar De Moya on 28/04/24.
//

import Foundation
import SwiftUI

extension Color: RawRepresentable {
    public var rawValue: String {
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: CrossPlatformColor(self), requiringSecureCoding: false) as Data
            return data.base64EncodedString()
        } catch {
            return ""
        }
    }
    
    public init?(rawValue: String) {
        guard let data = Data(base64Encoded: rawValue) else {
            return nil
        }
        do {
            guard let color = try NSKeyedUnarchiver.unarchivedObject(ofClass: CrossPlatformColor.self, from: data) else {
                return nil
            }
            self = Color(color)
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }

    init(hex: String) {
        self.init(rgba: hex.rgba)
    }
    
    init(argb: Int) {
        self.init(
            .sRGB,
            red: Double((argb >> 16) & 0xFF) / 255,
            green: Double((argb >> 08) & 0xFF) / 255,
            blue: Double((argb >> 00) & 0xFF) / 255
        )
    }
    
    init(rgba: RGBA) {
        self.init(.sRGB,
                  red: min(max(rgba.red, 0), 1),
                  green: min(max(rgba.green, 0), 1),
                  blue: min(max(rgba.blue, 0), 1),
                  opacity: min(max(rgba.alpha, 0), 1)
        )
    }
    
    init(hsba: HSBA) {
        self.init(
            hue: min(max(hsba.hue, 0), 1),
            saturation: min(max(hsba.saturation, 0), 1),
            brightness: min(max(hsba.brightness, 0), 1),
            opacity: min(max(hsba.alpha, 0), 1)
        )
    }
    
    var uiColor: CrossPlatformColor { .init(self) }
    var rgba: RGBA? { uiColor.rgba }
    var hsba: HSBA? { uiColor.hsba }
    
    var hexRGB: String {
        guard let rgba = rgba else { return "" }
        return String(format: "#%02x%02x%02x",
                      Int(rgba.red * 255),
                      Int(rgba.green * 255),
                      Int(rgba.blue * 255))
    }
    
    var hexRGBA: String {
        guard let rgba = rgba else { return "" }
        return String(format: "#%02x%02x%02x%02x",
                      Int(rgba.red * 255),
                      Int(rgba.green * 255),
                      Int(rgba.blue * 255),
                      Int(rgba.alpha * 255))
    }
    
    var rgbInt: Int? {
        guard let rgba else { return nil }
        return ColorUtils.argbFromRgb(Int(rgba.red * 255), Int(rgba.green * 255), Int(rgba.blue * 255))
    }
    
    var hct: Hct? {
        guard let rgbInt else { return nil }
        return Hct(rgbInt)
    }
    
    var luminance: Double {
        guard let color = rgba else { return 0 }
        return 0.2126 * Double(color.red) + 0.7152 * Double(color.green) + 0.0722 * Double(color.blue)
    }
    
    var isLight: Bool { luminance > 0.4 }
    
    var contrastingColor: Color {
        return adjust(saturation: isLight ? 0.1 : -0.1, brightness: isLight ? -0.3 : 0.3)
    }
}

extension CrossPlatformColor {
    var rgba: RGBA? {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
#if os(macOS) || targetEnvironment(macCatalyst)
        guard let rgbColor = self.usingColorSpace(NSColorSpace.deviceRGB) else { return nil }
#else
        let rgbColor = self
#endif
        rgbColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return RGBA(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    var hsba: HSBA? {
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
#if os(macOS) || targetEnvironment(macCatalyst)
        guard let hsbColor = self.usingColorSpace(NSColorSpace.deviceRGB) else { return nil }
#else
        let hsbColor = self
#endif
        hsbColor.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        return HSBA(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
    }
}

extension String {
    var rgba: RGBA {
        var hexSanitized = self.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        
        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 1.0
        
        let length = hexSanitized.count
        
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        
        if length == 6 {
            r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
            g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
            b = CGFloat(rgb & 0x0000FF) / 255.0
        } else if length == 8 {
            r = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
            g = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
            b = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0
            a = CGFloat(rgb & 0x000000FF) / 255.0
        }
        
        return RGBA(red: r, green: g, blue: b, alpha: a)
    }
}
