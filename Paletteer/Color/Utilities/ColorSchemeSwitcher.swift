//
//  ColorSchemeSwitcher.swift
//  Paletteer
//
//  Created by Oscar De Moya on 28/04/24.
//

import SwiftUI

struct ColorSchemeSwitcher {
    @AppStorage(key(.colorScheme)) var selectedAppearance: AppColorScheme = .system
    var userInterfaceStyle: ColorScheme? = .dark
    static var shared = ColorSchemeSwitcher()
    
    func overrideDisplayMode() {
#if os(macOS)
        switch selectedAppearance {
        case .system:
            NSApplication.shared.appearance = NSAppearance()
        case .light:
            NSApplication.shared.appearance = NSAppearance(named: .aqua)
        case .dark:
            NSApplication.shared.appearance = NSAppearance(named: .darkAqua)
        }
#else
        var userInterfaceStyle: UIUserInterfaceStyle
        switch selectedAppearance {
        case .system:
            userInterfaceStyle = .unspecified
        case .light:
            userInterfaceStyle = .light
        case .dark:
            userInterfaceStyle = .dark
        }
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        let window = windowScene?.windows.first
        window?.overrideUserInterfaceStyle = userInterfaceStyle
#endif
    }
}
