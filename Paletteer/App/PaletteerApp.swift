//
//  PaletteerApp.swift
//  Paletteer
//
//  Created by Oscar De Moya on 22/04/24.
//

import SwiftUI
import SwiftData

@main
struct PaletteerApp: App {    
    var body: some Scene {
        WindowGroup {
            ColorPaletteSettingsView()
            // HomeView()
        }
        .modelContainer(ModelContainer.shared)
#if os(macOS) || targetEnvironment(macCatalyst)
        Settings {
            SettingsPane()
        }
#endif
    }
}
