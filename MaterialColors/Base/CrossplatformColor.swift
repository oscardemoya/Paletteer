//
//  CrossplatformColor.swift
//  MaterialColors
//
//  Created by Oscar De Moya on 12/05/24.
//

import SwiftUI

#if os(macOS)
    import AppKit
    /// NSColor on macOS
    public typealias CrossPlatformColor = NSColor
#else
    import UIKit
    /// UIColor when not on macOS
    public typealias CrossPlatformColor = UIColor
#endif

extension Color {
    var cgColor: CGColor { CrossPlatformColor(self).cgColor }
}
