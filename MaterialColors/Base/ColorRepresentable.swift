//
//  ColorRepresentable.swift
//  MaterialColors
//
//  Created by Oscar De Moya on 28/04/24.
//

import Foundation
import SwiftUI
import UIKit

typealias RGBA = (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat)

extension Color: RawRepresentable {
    public init?(rawValue: String) {
        guard let data = Data(base64Encoded: rawValue) else {
            return nil
        }
        do {
            guard let color = try NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: data) else {
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
            let data = try NSKeyedArchiver.archivedData(withRootObject: UIColor(self), requiringSecureCoding: false) as Data
            return data.base64EncodedString()
        } catch {
            return ""
        }
    }
    
    var uiColor: UIColor { .init(self) }
    
    var rgba: RGBA? {
        var (r, g, b, a): RGBA = (0, 0, 0, 0)
        return uiColor.getRed(&r, green: &g, blue: &b, alpha: &a) ? (r, g, b, a) : nil
    }
    
    var hexRGB: String {
        guard let (red, green, blue, _) = rgba else { return "" }
        return String(format: "#%02x%02x%02x",
                      Int(red * 255),
                      Int(green * 255),
                      Int(blue * 255))
    }
    
    var hexaRGBA: String {
        guard let (red, green, blue, alpha) = rgba else { return "" }
        return String(format: "#%02x%02x%02x%02x",
                      Int(red * 255),
                      Int(green * 255),
                      Int(blue * 255),
                      Int(alpha * 255))
    }
    
    var hct: Hct? {
        guard let rgba else { return nil }
        let argb = ColorUtils.argbFromRgb(Int(rgba.red * 255), Int(rgba.green * 255), Int(rgba.blue * 255))
        return Hct(argb)
    }
}
