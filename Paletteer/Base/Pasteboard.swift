//
//  Pasteboard.swift
//  Paleteer
//
//  Created by Oscar De Moya on 25/05/24.
//

import Foundation

#if canImport(UIKit)
import UIKit
#endif
#if canImport(AppKit)
import AppKit
#endif

public extension String {
    static var pasteboardString: String? {
        get {
#if os(macOS)
            NSPasteboard.general.string(forType: .string)
#else
            UIPasteboard.general.string
#endif
        }
        set {
#if os(macOS)
            if let newValue {
                NSPasteboard.general.setString(newValue, forType: .string)
            } else {
                NSPasteboard.general.clearContents()
            }
#else
            UIPasteboard.general.string = newValue
#endif
        }
    }
}
