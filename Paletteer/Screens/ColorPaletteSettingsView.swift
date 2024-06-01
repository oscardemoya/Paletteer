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
    @State private var newColor = ColorConfig(color: .blue, colorName: "")
    @State private var isEditing = false
    @State private var exisitingColor = ColorConfig(color: .blue, colorName: "")
    var columns = [GridItem(.adaptive(minimum: 200), spacing: 12)]
    
    var defaultColorPalette: [ColorConfig] {[
        ColorConfig(color: .blue, groupName: "Brand", colorName: "Primary"),
        ColorConfig(color: .purple, groupName: "Brand", colorName: "Secondary"),
        ColorConfig(color: .orange, groupName: "Brand", colorName: "Tertiary"),
        ColorConfig(color: .green, groupName: "Semantic", colorName: "Success"),
        ColorConfig(color: .yellow, groupName: "Semantic", colorName: "Warning"),
        ColorConfig(color: .red, groupName: "Semantic", colorName: "Error"),
        ColorConfig(color: .gray, groupName: "Neutral", colorName: "Background", darkColorScale: .lightening, narrow: true),
        ColorConfig(color: .black, groupName: "Neutral", colorName: "Foreground", reversed: true)
    ]}
    
    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 0) {
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
                ColorConfigForm(colorConfig: $newColor, colorClipboard: $colorClipboard, isEditing: true)
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
                        newColor = ColorConfig(color: .blue, colorName: "")
                        isAdding = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .onAppear {
            ColorSchemeSwitcher.shared.overrideDisplayMode()
        }
    }
    
    @ViewBuilder var colorPaletteView: some View {
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
        .padding()
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
}

#Preview {
    ColorPaletteSettingsView()
}
