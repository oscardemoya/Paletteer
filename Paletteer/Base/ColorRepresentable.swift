//
//  ColorRepresentable.swift
//  Paletteer
//
//  Created by Oscar De Moya on 28/04/24.
//

import Foundation
import SwiftUI

typealias RGBA = (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat)
typealias HSBA = (hue: CGFloat, saturation: CGFloat, brightness: CGFloat, alpha: CGFloat)

extension Color: RawRepresentable {
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

    public var rawValue: String {
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: CrossPlatformColor(self), requiringSecureCoding: false) as Data
            return data.base64EncodedString()
        } catch {
            return ""
        }
    }
    
    init?(hex: String) {
        guard let argb = StringUtils.argbFromHex(hex) else { return nil }
        self.init(argb: argb)
    }
    
    init(argb: Int) {
        self.init(
            .sRGB,
            red: Double((argb >> 16) & 0xFF) / 255,
            green: Double((argb >> 08) & 0xFF) / 255,
            blue: Double((argb >> 00) & 0xFF) / 255
        )
    }
    
    var uiColor: CrossPlatformColor { .init(self) }
    var rgba: RGBA? { uiColor.rgba }
    var hsba: HSBA? { uiColor.hsba }
    
    var hexRGB: String {
        guard let (red, green, blue, _) = rgba else { return "" }
        return String(format: "#%02x%02x%02x",
                      Int(red * 255),
                      Int(green * 255),
                      Int(blue * 255))
    }
    
    var hexRGBA: String {
        guard let (red, green, blue, alpha) = rgba else { return "" }
        return String(format: "#%02x%02x%02x%02x",
                      Int(red * 255),
                      Int(green * 255),
                      Int(blue * 255),
                      Int(alpha * 255))
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
        var (r, g, b, a): RGBA = (0, 0, 0, 0)
#if os(macOS)
        guard let rgbColor = self.usingColorSpace(NSColorSpace.deviceRGB) else { return nil }
#else
        let rgbColor = self
#endif
        rgbColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        return (r, g, b, a)
    }
    
    var hsba: HSBA? {
        var (h, s, b, a): RGBA = (0, 0, 0, 0)
#if os(macOS)
        guard let rgbColor = self.usingColorSpace(NSColorSpace.deviceRGB) else { return nil }
#else
        let rgbColor = self
#endif
        rgbColor.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        return (h, s, b, a)
    }
}
