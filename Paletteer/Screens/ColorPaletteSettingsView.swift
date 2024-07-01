//
//  ColorPaletteSettingsView.swift
//  Paletteer
//
//  Created by Oscar De Moya on 22/04/24.
//

import SwiftUI

struct ColorPaletteSettingsView: View {
    static var defaultColorConfig = ColorConfig(colorModel: .rgb(Color(hex: "#689FD4")), colorName: "")
    @AppStorage(key(.colorScheme)) var selectedAppearance: AppColorScheme = .system
    @AppStorage(key(.colorPalette)) var colorPalette = [ColorConfig]()
    @AppStorage(key(.useColorInClipboard)) var useColorInClipboard: Bool = true
    @State private var path = NavigationPath()
    @State private var colorClipboard = ColorClipboard()
    @State private var isAdding = false
    @State private var newColor = defaultColorConfig
    @State private var isEditing = false
    @State private var exisitingColor = defaultColorConfig
    @State private var isConfiguring = false
    @State private var showAlert = false
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""
    var columns = [GridItem(.adaptive(minimum: 200), spacing: 12)]
    
    var body: some View {
        viewContainer
            .onAppear {
                ColorSchemeSwitcher.shared.overrideDisplayMode()
            }
#if os(macOS)
            .pasteDestination(for: String.self) { strings in
                pasteColorPaletteConfig(strings: strings)
            }
#endif
    }
    
    @ViewBuilder var viewContainer: some View {
#if os(macOS)
        NavigationSplitView {
            VStack {
                ColorSettingsView()
                Spacer()
            }
        } detail: {
            navigationStack
        }
#else
        navigationStack
#endif
    }
    
    @ViewBuilder var navigationStack: some View {
        NavigationStack(path: $path) {
            Group {
                if colorPalette.isEmpty {
                    emptyStateView
                } else {
                    colorPaletteView
                }
            }
            .background(.primaryBackground)
            .navigationTitle("Paletteer")
#if !os(macOS)
            .navigationBarTitleDisplayMode(.inline)
#endif
            .navigationDestination(for: [ColorConfig].self) { colorList in
                ColorPaletteView(colorList: colorList)
            }
            .sheet(isPresented: $isAdding) {
                ColorConfigForm(colorConfig: $newColor, colorClipboard: $colorClipboard, isEditing: false)
            }
            .sheet(isPresented: $isEditing) {
                ColorConfigForm(colorConfig: $exisitingColor, colorClipboard: $colorClipboard, isEditing: true)
            }
            .toolbar {
#if !os(macOS)
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        isConfiguring = true
                    } label: {
                        Image(systemName: "gear")
                    }
                }
#endif
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        selectedAppearance.toggle()
                        ColorSchemeSwitcher.shared.overrideDisplayMode()
                    } label: {
                        Image(systemName: selectedAppearance.iconName)
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        copyColorPaletteConfig()
                    } label: {
                        Image(systemName: "square.on.square")
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        pasteColorPaletteConfig()
                    } label: {
                        Image(systemName: "doc.on.clipboard")
                    }
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text(alertTitle), message: Text(alertMessage))
            }
            .sheet(isPresented: $isConfiguring) {
                SettingsPane()
            }
        }
    }
        
    @ViewBuilder var addButton: some View {
        Button {
            if useColorInClipboard, let text = String.pasteboardString, let colorInClipboard = text.color {
                newColor = ColorConfig(colorModel: colorInClipboard, colorName: "")
            } else {
                newColor = Self.defaultColorConfig
            }
            isAdding = true
        } label: {
            Label("Add Color", systemImage: "plus.circle.fill")
                .font(.headline)
                .fontWeight(.medium)
                .fontDesign(.rounded)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.custom(backgroundColor: .secondaryActionBackground,
                             foregroundColor: .secondaryActionForeground,
                             cornerRadius: 16))
    }
    
    @ViewBuilder var generateButton: some View {
        Button {
            path.append(colorPalette)
        } label: {
            Label("Generate", systemImage: "swatchpalette")
                .font(.headline)
                .fontWeight(.medium)
                .fontDesign(.rounded)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.custom(backgroundColor: .primaryActionBackground,
                             foregroundColor: .primaryActionForeground,
                             cornerRadius: 16))
    }
    
    @ViewBuilder var colorPaletteView: some View {
        VStack(spacing: 0) {
            
            ScrollView {
                LazyVGrid(columns: columns, spacing: 8) {
                    ForEach($colorPalette) { $colorConfig in
                        CustomColorPicker(colorConfig: $colorConfig, colorClipboard: $colorClipboard, isEditing: false) {
                            colorPalette.removeAll { colorConfig.id == $0.id }
                        } onEdit: {
                            exisitingColor = colorConfig
                            isEditing = true
                        }
                        .buttonStyle(.custom(backgroundColor: .primaryInputBackground,
                                             foregroundColor: .primaryActionForeground))
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
            }
            Spacer(minLength: 0)
            Divider()
            HStack(spacing: 12) {
                addButton
                generateButton
            }
            .padding()
        }
    }
    
    @ViewBuilder var emptyStateView: some View {
        ContentUnavailableView {
            Label("Empty Color Palette", systemImage: "paintpalette")
        } description: {
            Text("Please add colors using the plus button")
        } actions: {
            Button("Add Sample Palette") {
                colorPalette = .sample
            }
            .buttonBorderShape(.capsule)
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    func copyColorPaletteConfig() {
        String.pasteboardString = colorPalette.map(\.description).joined(separator: "\n")
        alertTitle = "Color Palette"
        alertMessage = "Copied to the clipboard."
        showAlert = true
    }
    
    func pasteColorPaletteConfig() {
        guard let string = String.pasteboardString else { return }
        pasteColorPaletteConfig(strings: [string])
    }
    
    func pasteColorPaletteConfig(strings: [String]) {
        guard let string = strings.first else { return }
        let colorRegex = /((?<groupName>\w+)\/)?(?<colorName>\w+)\s*: #(?<hexString>[a-f0-9]{6})\s*(L{(?<lightConfig>\S*)?})?\s*(D{(?<darkConfig>\S*)?})?/
            .ignoresCase()
            .dotMatchesNewlines()
        colorPalette = string.split(separator: "\n").compactMap { line in
            line.matches(of: colorRegex).compactMap { match -> ColorConfig? in
                let groupName = String(match.output.groupName ?? "")
                let colorName = String(match.output.colorName)
                let hexString = String(match.output.hexString)
                let lightConfig = String(match.output.lightConfig ?? "")
                let darkConfig = String(match.output.darkConfig ?? "")
                return ColorConfig(
                    colorModel: .rgb(Color(hex: hexString)),
                    colorName: colorName,
                    groupName: groupName,
                    lightConfig: SchemeConfig(description: lightConfig, defaultScale: .darkening),
                    darkConfig: SchemeConfig(description: darkConfig, defaultScale: .lightening)
                )
            }.first
        }
    }
}

#Preview {
    ColorPaletteSettingsView()
}
