//
//  SettingsPane.swift
//  Paletteer
//
//  Created by Oscar De Moya on 1/06/24.
//

import SwiftUI

struct SettingsPane: View {
    var body: some View {
#if os(macOS) || targetEnvironment(macCatalyst)
        tabView
#else
        navigationStack
#endif
    }
    
    @ViewBuilder
    var tabView: some View {
        TabView {
            Group {
                GeneralSettingsView()
                    .tabItem {
                        Label("General", systemImage: "gear")
                    }
                ColorSettingsView()
                    .tabItem {
                        Label("Colors", systemImage: "paintpalette")
                    }
            }
            .padding()
        }
        .padding()
        .frame(width: 500)
    }
    
    @ViewBuilder
    var navigationStack: some View {
        NavigationStack {
            Form {
                NavigationLink("General", destination: GeneralSettingsView())
                NavigationLink("Colors", destination: ColorSettingsView())
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsPane()
}
