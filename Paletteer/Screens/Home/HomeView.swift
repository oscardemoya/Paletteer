//
//  HomeView.swift
//  Paletteer
//
//  Created by Oscar De Moya on 22/04/24.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    static var defaultColorConfig = ColorConfig(colorModel: .rgb(Color(hex: "#689FD4")), colorName: "")
    @Query private var items: [ColorPalette]
    @Environment(\.modelContext) var modelContext
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @AppStorage(key(.colorScheme)) var selectedAppearance: AppColorScheme = .system
    @AppStorage(key(.useColorInClipboard)) var useColorInClipboard: Bool = true
    @State private var path = NavigationPath()
    @State private var selectedPalette: ColorPalette?
    @State private var colorConfigs = [ColorConfig]()
    @State private var colorClipboard = ColorClipboard()
    @State private var isAdding = false
    @State private var newColor = defaultColorConfig
    @State private var isEditing = false
    @State private var editingColor = defaultColorConfig
    @State private var showAlert = false
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""
    var columns = [GridItem(.adaptive(minimum: 240), spacing: 12)]
    
    var body: some View {
        viewContainer
            .onAppear {
                if let selectedPalette {
                    colorConfigs = selectedPalette.configs
                }
                ColorSchemeSwitcher.shared.overrideDisplayMode()
            }
            .onChange(of: selectedPalette) { oldValue, newValue in
                if newValue != nil, !path.isEmpty {
                    path.removeLast()
                }
                colorConfigs = selectedPalette?.configs ?? []
            }
#if os(macOS) || targetEnvironment(macCatalyst)
            .pasteDestination(for: String.self) { strings in
                pasteColorPaletteConfig(strings: strings)
            }
#endif
    }
    
    @ViewBuilder var viewContainer: some View {
        if horizontalSizeClass == .compact {
            ColorPaletteListView(selectedPalette: $selectedPalette)
                .sheet(item: $selectedPalette) { item in
                    navigationStack
                        .presentationDragIndicator(.visible)
                }
        } else {
            NavigationSplitView {
                VStack {
                    ColorSettingsView()
                    Spacer()
                }
            } content: {
                ColorPaletteListView(selectedPalette: $selectedPalette)
            } detail: {
                navigationStack
            }
        }
    }
    
    @ViewBuilder var navigationStack: some View {
        NavigationStack(path: $path) {
            Group {
                if selectedPalette == nil {
                    emptySelectionView
                } else {
                    colorPaletteView
                }
            }
            .background(.primaryBackground)
            .navigationTitle(selectedPalette?.name ?? "Paletteer")
#if !os(macOS) && !targetEnvironment(macCatalyst)
            .navigationBarTitleDisplayMode(.inline)
#endif
            .navigationDestination(for: ColorPalette.self) { colorPalette in
                ColorPalettePreview(colorPalette: colorPalette)
            }
            .sheet(isPresented: $isAdding) {
                ColorConfigForm(colorPalette: $selectedPalette, colorConfig: $newColor, colorClipboard: $colorClipboard, isEditing: false, onDelete: nil) {
                    colorConfigs = selectedPalette?.configs ?? []
                }
            }
            .sheet(isPresented: $isEditing) {
                ColorConfigForm(colorPalette: $selectedPalette, colorConfig: $editingColor, colorClipboard: $colorClipboard, isEditing: true) {
                    colorConfigs.removeAll { editingColor.id == $0.id }
                    updateColorPalette()
                } onSave: {
                    colorConfigs = selectedPalette?.configs ?? []
                }
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
            updateColorPalette()
            if let selectedPalette {
                path.append(selectedPalette)
            }
        } label: {
            Label("Generate", systemImage: "swatchpalette")
                .font(.headline)
                .fontWeight(.medium)
                .fontDesign(.rounded)
                .frame(maxWidth: .infinity)
        }
        .disabled(colorConfigs.isEmpty)
        .buttonStyle(
            .custom(
                backgroundColor: .primaryActionBackground,
                foregroundColor: .primaryActionForeground,
                disabledBackgroundColor: .primaryActionBackground.opacity(0.5),
                disabledForegroundColor: .primaryActionForeground
            )
        )
    }
    
    @ViewBuilder var colorPaletteView: some View {
        VStack(spacing: 0) {
            if colorConfigs.isEmpty {
                emptyStateView
            } else {
                colorConfigList
            }
            Divider()
            HStack(spacing: 12) {
                addButton
                generateButton
            }
            .padding()
        }
    }
    
    @ViewBuilder var colorConfigList: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach($colorConfigs) { $colorConfig in
                    CustomColorPicker(colorConfig: $colorConfig, colorClipboard: $colorClipboard, isEditing: false) {
                        colorConfigs.removeAll { colorConfig.id == $0.id }
                        updateColorPalette()
                    } onEdit: {
                        editingColor = colorConfig
                        isEditing = true
                    } onDismiss: {
                        if let index = colorConfigs.firstIndex(where: { $0.id == colorConfig.id }) {
                            colorConfigs[index].update(with: colorConfig)
                        }
                        updateColorPalette()
                    }
                    .buttonStyle(
                        .custom(
                            backgroundColor: .primaryInputBackground,
                            foregroundColor: .primaryActionForeground
                        )
                    )
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    @ViewBuilder var emptySelectionView: some View {
        ContentUnavailableView(
            "No Selection",
            systemImage: "hand.tap.fill",
            description: Text("Please selected an item from the list.")
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.secondaryBackground)
    }
    
    @ViewBuilder var emptyStateView: some View {
        ContentUnavailableView {
            Label("Empty Color Palette", systemImage: "paintpalette")
        } description: {
            Text("Please add colors using the plus button")
        } actions: {
            Button("Add Sample Palette") {
                colorConfigs = .sample
                updateColorPalette()
            }
            .buttonBorderShape(.capsule)
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    func updateColorPalette() {
        guard let selectedPalette else { return }
        selectedPalette.setConfigs(colorConfigs)
        modelContext.insert(selectedPalette)
        try? modelContext.save()
    }
    
    func copyColorPaletteConfig() {
        String.pasteboardString = colorConfigs.map(\.description).joined(separator: "\n")
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
        colorConfigs = string.split(separator: "\n").compactMap { line in
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
                    lightConfig: SchemeConfig(description: lightConfig, defaultScale: .darkening, defaultSkip: .backward),
                    darkConfig: SchemeConfig(description: darkConfig, defaultScale: .lightening, defaultSkip: .forward)
                )
            }.first
        }
        updateColorPalette()
    }
}

#Preview {
    HomeView()
        .modelContainer(for: ColorPalette.self, inMemory: true)
}
