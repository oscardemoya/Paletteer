//
//  ColorPaletteSettingsView.swift
//  Paletteer
//
//  Created by Oscar De Moya on 22/04/24.
//

import SwiftUI

struct ColorPaletteSettingsView: View {
    @AppStorage(key(.colorScheme)) var selectedAppearance: AppColorScheme = .system
    @AppStorage(key(.colorPalette)) var colorPalette = [ColorConfig]()
    @State private var path = NavigationPath()
    @State private var colorClipboard = ColorClipboard()
    @State private var isAdding = false
    @State private var newColor = ColorConfig(colorModel: .rgb(.blue), colorName: "")
    @State private var isEditing = false
    @State private var exisitingColor = ColorConfig(colorModel: .rgb(.blue), colorName: "")
    @State private var isConfiguring = false
    var columns = [GridItem(.adaptive(minimum: 200), spacing: 12)]
    
    var defaultColorPalette: [ColorConfig] {[
        ColorConfig(colorModel: .rgb(Color(hex: "#689FD4")), groupName: "Brand", colorName: "Primary"),
        ColorConfig(colorModel: .rgb(Color(hex: "#A091D7")), groupName: "Brand", colorName: "Secondary"),
        ColorConfig(colorModel: .rgb(Color(hex: "#E79161")), groupName: "Brand", colorName: "Tertiary"),
        ColorConfig(colorModel: .rgb(Color(hex: "#6EA97A")), groupName: "Semantic", colorName: "Success"),
        ColorConfig(colorModel: .rgb(Color(hex: "#CEBC5A")), groupName: "Semantic", colorName: "Warning"),
        ColorConfig(colorModel: .rgb(Color(hex: "#D97F75")), groupName: "Semantic", colorName: "Error"),
        ColorConfig(colorModel: .rgb(Color(hex: "#A9A8AC")), groupName: "Neutral", colorName: "Background",
                    lightColorScale: .lightening, rangeWidth: .wide),
        ColorConfig(colorModel: .rgb(Color(hex: "#525354")), groupName: "Neutral", colorName: "Foreground",
                    lightColorScale: .lightening, darkColorScale: .darkening, rangeWidth: .wide)
    ]}
    
    var body: some View {
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
#if !os(macOS)
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        isConfiguring = true
                    } label: {
                        Image(systemName: "gear")
                    }
                }
#endif
            }
        }
        .onAppear {
            ColorSchemeSwitcher.shared.overrideDisplayMode()
        }
        .sheet(isPresented: $isConfiguring) {
            SettingsPane()
        }
    }
        
    @ViewBuilder var addButton: some View {
        Button {
            newColor = ColorConfig(colorModel: .rgb(colorPalette.last?.color ?? .blue.muted), colorName: "")
            isAdding = true
        } label: {
            Label("Add Color", systemImage: "plus.circle.fill")
                .font(.title3)
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
            Text("Generate")
                .font(.title3)
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
                colorPalette = defaultColorPalette
            }
            .buttonBorderShape(.capsule)
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    func copyColorPaletteConfig() {
        String.pasteboardString = colorPalette.map(\.colorDescription).joined(separator: "\n")
    }
}

#Preview {
    ColorPaletteSettingsView()
}
