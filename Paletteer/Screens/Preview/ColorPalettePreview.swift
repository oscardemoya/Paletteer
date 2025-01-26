//
//  ColorPalettePreview.swift
//  Paletteer
//
//  Created by Oscar De Moya on 27/04/24.
//

import SwiftUI

struct ColorPalettePreview: View {
    @State var colorPalette: ColorPalette?
    
    static var fileName = "Colors.xcassets"
    static var defaultColorConfig = ColorConfig(colorModel: .rgb(Color(hex: "#689FD4")), colorName: "")
    var fileURL = FileManager.default.fileURL(fileName: Self.fileName)
    let fileManagerDelegate = CopyFileManagerDelegate()
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.horizontalSizeClass) var horizontalSizeClass

    @AppStorage(key(.colorScheme)) var selectedAppearance: AppColorScheme = .system
    @AppStorage(key(.colorPaletteParams)) var params = ColorPaletteParams()
    
    @State private var colorConfigs = [ColorConfig]()
    @State private var colorSpace: ColorSpace = .hct
    @State private var backupFileURL: URL? = nil
    @State private var assetsFileURL: URL? = nil
    @State private var isShowingShareView: Bool = false
    @State private var showAlert = false
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""
    @State private var isEditing = false
    @State private var existingColor = defaultColorConfig
    @State private var colorClipboard = ColorClipboard()
    @State private var showSortButtons = false
    @State private var showColorInfo = true
    
    var body: some View {
        colorGrid
            .toolbarRole(.editor)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Picker("Color Space", selection: $colorSpace) {
                        ForEach(ColorSpace.allCases) {
                            Text($0.title)
                        }
                    }
                    .pickerStyle(.segmented)
                    .fixedSize()
                }
                ToolbarItem(placement: .cancellationAction) {
#if os(macOS) || targetEnvironment(macCatalyst)
                    Button {
                        showSortButtons.toggle()
                    } label: {
                        Image(systemName: showSortButtons ? "arrow.up.arrow.down.square.fill" : "arrow.up.arrow.down.square")
                    }
#else
                    Button {
                        showColorInfo.toggle()
                    } label: {
                        Image(systemName: showColorInfo ? "info.square.fill" : "info.square")
                    }
#endif
                }
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        selectedAppearance.toggle()
                        ColorSchemeSwitcher.shared.overrideDisplayMode()
                    } label: {
                        Image(systemName: selectedAppearance.iconName)
                    }
                }
                if let fileURL {
                    ToolbarItem(placement: .primaryAction) {
#if os(macOS) || targetEnvironment(macCatalyst)
                        Button {
                            generateColorShades()
                            exportFile(at: fileURL)
                        } label: {
                            Image(systemName: "square.and.arrow.down")
                        }
#else
                        ShareLink(item: fileURL) {
                            Image(systemName: "square.and.arrow.up")
                        }
#endif
                    }
                }
            }
#if !os(macOS) && !targetEnvironment(macCatalyst)
            .background(.primaryBackground)
#endif
            .onAppear {
                colorConfigs = colorPalette?.configs ?? []
                ColorSchemeSwitcher.shared.overrideDisplayMode()
            }
            .onAppear(perform: generateColorShades)
            .onChange(of: colorSpace) { _, _ in
                generateColorShades()
            }
            .sheet(isPresented: $isEditing, onDismiss: generateColorShades) {
                ColorConfigForm(colorPalette: $colorPalette, colorConfig: $existingColor, colorClipboard: $colorClipboard, isEditing: true) {
                    colorConfigs = colorPalette?.configs ?? []
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text(alertTitle), message: Text(alertMessage))
            }
    }
    
    @ViewBuilder var colorGrid: some View {
        VStack(spacing: 0) {
            contentView
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            Spacer(minLength: 0)
        }
    }
    
#if os(macOS) || targetEnvironment(macCatalyst)
    @ViewBuilder var contentView: some View {
        ScrollView {
            Grid {
                ForEach(colorConfigs) { colorConfig in
                    GridRow {
                        titleView(colorConfig: colorConfig)
                            .gridCellAnchor(.leading)
                        rectangleStack(colorPairs: colorConfig.shades(params: params, colorSpace: colorSpace))
                    }
                }
            }
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.viewAligned)
        .contentMargins(8, for: .scrollContent)
    }
#else
    @ViewBuilder var contentView: some View {
        List {
            ForEach(colorConfigs) { colorConfig in
                VStack(spacing: 8) {
                    if showColorInfo {
                        HStack {
                            titleView(colorConfig: colorConfig)
                            Spacer()
                        }
                    }
                    rectangleStack(colorPairs: colorConfig.shades(params: params, colorSpace: colorSpace))
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
            }
            .onMove { from, to in
                colorConfigs.move(fromOffsets: from, toOffset: to)
            }
            .background(Color.clear)
            .listRowInsets(EdgeInsets())
            .listRowBackground(Color.clear)
        }
        .listStyle(.grouped)
        .listSectionSpacing(.custom(.zero))
        .contentMargins(.top, 0)
        .scrollContentBackground(.hidden)
    }
#endif
    
#if os(macOS) || targetEnvironment(macCatalyst)
    func exportFile(at fileURL: URL) {
        if let assetsFileURL = showSavePanel() {
            do {
                let fileManager = FileManager.default
                fileManager.delegate = fileManagerDelegate
                try fileManager.copyItem(at: fileURL, to: assetsFileURL)
            } catch {
                print("ERROR: \(error)")
            }
        }
    }
    
    func showSavePanel() -> URL? {
        let savePanel = NSSavePanel()
        savePanel.title = "Save Assets File"
        savePanel.nameFieldStringValue = Self.fileName
        savePanel.canCreateDirectories = true
        savePanel.isExtensionHidden = false
        savePanel.title = "Save your file"
        savePanel.message = "Choose a folder and a name to store the file."
        savePanel.nameFieldLabel = "Assets file name:"
        let response = savePanel.runModal()
        return response == .OK ? savePanel.url : nil
    }
#endif
    
    private func generateColorShades() {
        if let existingFileURL = fileURL, FileManager.default.fileExists(atPath: existingFileURL.path) {
            FileManager.default.removeDirectory(atURL: existingFileURL)
        }
        colorConfigs.forEach { colorConfig in
            createFile(for: colorConfig, colorPairs: colorConfig.shades(params: params, colorSpace: colorSpace))
        }
    }
    
    private func createFile(for config: ColorConfig, colorPairs: [ColorPair]) {
        if !config.groupName.isEmpty {
            saveEmptyFiles(to: config.groupName)
        }
        colorPairs.enumerated().forEach { index, color in
            let index = index + (params.colorSkipScheme == .light ? params.colorSkipCount : 0)
            let toneCode = ColorPaletteConstants.toneNames[index]
            let toneName = String(format: "%03d", toneCode * 10)
            let colorName = "\(config.colorName.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))-\(toneName)"
            var pathComponents = [String]()
            if !config.groupName.isEmpty {
                pathComponents.append(config.groupName.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))
            }
            pathComponents.append(config.colorName)
            let path = pathComponents.joined(separator: "/")
            let lightArgb = color.light.rgbInt ?? 0
            let darkArgb = color.dark.rgbInt ?? 0
            saveFile(to: path, colorName: colorName, lightArgb: lightArgb, darkArgb: darkArgb)
        }
    }
    
    private func titleView(colorConfig: ColorConfig) -> some View {
        HStack {
            if showSortButtons {
                Button {
                    if let index = colorConfigs.firstIndex(where: { $0.id == colorConfig.id }) {
                        withAnimation {
                            if index > 0 {
                                colorConfigs.swapAt(index, index - 1)
                            } else {
                                colorConfigs.swapAt(index, colorConfigs.count - 1)
                            }
                        }
                    }
                } label: {
                    Image(systemName: "chevron.up")
                        .font(.title3)
                        .padding(.vertical, 6)
                }
                .buttonStyle(.custom(backgroundColor: .secondaryActionBackground,
                                     foregroundColor: .secondaryActionForeground,
                                     cornerRadius: 8))
                Button {
                    if let index = colorConfigs.firstIndex(where: { $0.id == colorConfig.id }) {
                        withAnimation {
                            if index < colorConfigs.count - 1 {
                                colorConfigs.swapAt(index, index + 1)
                            } else {
                                colorConfigs.swapAt(index, 0)
                            }
                        }
                    }
                } label: {
                    Image(systemName: "chevron.down")
                        .font(.title3)
                        .padding(.vertical, 6)
                }
                .buttonStyle(.custom(backgroundColor: .secondaryActionBackground,
                                     foregroundColor: .secondaryActionForeground,
                                     cornerRadius: 8))
            }
            VStack(alignment: .leading) {
                Text(colorConfig.colorName)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.foreground300)
                Text(colorConfig.label(for: colorSpace).uppercased())
                    .font(.subheadline)
                    .foregroundColor(.foreground500)
                HStack(spacing: 4) {
                    Text("L").font(.callout)
                    Image(systemName: colorConfig.lightConfig.skipDirection.iconName)
                        .foregroundColor(.bright990)
                    Text("D").font(.callout)
                    Image(systemName: colorConfig.darkConfig.skipDirection.iconName)
                        .foregroundColor(.dark990)
                }
            }
            .padding(.top, 4)
            .onTapGesture {
                isEditing = true
                existingColor = colorConfig
            }
        }
    }
    
    private func rectangleStack(colorPairs: [ColorPair]) -> some View {
        VStack(spacing: 8) {
            if horizontalSizeClass == .compact {
                HStack(spacing: 8) {
                    ForEach(colorPairs.prefix(Int(ColorPaletteConstants.shadesCount / 2))) { color in
                        rectangle(colorPair: color)
                    }
                }
                HStack {
                    ForEach(colorPairs.suffix(Int(ColorPaletteConstants.shadesCount / 2))) { color in
                        rectangle(colorPair: color)
                    }
                }
            } else {
                HStack(spacing: 8) {
                    ForEach(colorPairs) { color in
                        rectangle(colorPair: color)
                    }
                }
            }
        }
    }
    
    private func rectangle(colorPair: ColorPair) -> some View {
        Rectangle()
            .fill(selectedAppearance.color(for: colorPair))
            .overlay(
                Triangle()
                    .fill(selectedAppearance == .system ? colorPair.dark : .clear)
                    .onTapGesture {
                        showColorCopiedAlert(colorPair: colorPair, for: .dark)
                    }
            )
            .overlay {
                VStack {
                    HStack {
                        Text(colorPair.toneCode)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundStyle((selectedAppearance == .dark ? colorPair.dark : colorPair.light).contrastingColor)
                            .padding(.top, 1)
                            .padding(.leading, 4)
                        Spacer()
                    }
                    Spacer()
                }
            }
            .frame(minWidth: 30)
            .frame(maxWidth: .infinity)
            .aspectRatio(1, contentMode: .fill)
            .cornerRadius(8)
            .onTapGesture {
                showColorCopiedAlert(colorPair: colorPair, for: selectedAppearance)
            }
    }
    
    private func showColorCopiedAlert(colorPair: ColorPair, for scheme: AppColorScheme = .system) {
        let hexColor = colorPair.color(for: scheme).hexRGB.uppercased()
        String.pasteboardString = hexColor
        alertTitle = "\(colorPair.name)-\(colorPair.toneCode) (\(scheme.name))"
        alertMessage = "Copied to the clipboard.\n\(hexColor)"
        showAlert = true
    }
    
    
    
    
    private func saveFile(to filePath: String, colorName: String, lightArgb: Int, darkArgb: Int) {
        let lightRed = ColorUtils.redFromArgb(lightArgb)
        let lightGreen = ColorUtils.greenFromArgb(lightArgb)
        let lightBlue = ColorUtils.blueFromArgb(lightArgb)
        let darkRed = ColorUtils.redFromArgb(darkArgb)
        let darkGreen = ColorUtils.greenFromArgb(darkArgb)
        let darkBlue = ColorUtils.blueFromArgb(darkArgb)
        let parameters: [String: String] = [
            "{{lr}}" : lightRed.hexStringWithPrefix,
            "{{lg}}" : lightGreen.hexStringWithPrefix,
            "{{lb}}" : lightBlue.hexStringWithPrefix,
            "{{la}}" : "1.000",
            "{{dr}}" : darkRed.hexStringWithPrefix,
            "{{dg}}" : darkGreen.hexStringWithPrefix,
            "{{db}}" : darkBlue.hexStringWithPrefix,
            "{{da}}" : "1.000",
        ]
        let fileContent = String(forResource: "ColorContentsTemplate", ofType: "json", parameters: parameters)
        fileContent?.write(to: "Colors.xcassets/Colors/\(filePath)/\(colorName).colorset/Contents.json")
    }
    
    private func saveEmptyFiles(to filePath: String) {
        let emptyContent = String(forResource: "Contents", ofType: "json")
        emptyContent?.write(to: "Colors.xcassets/Colors/\(filePath)/Contents.json")
        emptyContent?.write(to: "Colors.xcassets/Colors/Contents.json")
        emptyContent?.write(to: "Colors.xcassets/Contents.json")
    }
}

class CopyFileManagerDelegate: NSObject, FileManagerDelegate {
    func fileManager(_ fileManager: FileManager, shouldProceedAfterError error: any Error, copyingItemAt srcURL: URL, to dstURL: URL) -> Bool {
        true
    }
}

#Preview {
    @Previewable @State var colorPalette: ColorPalette? = ColorPalette.makeSample()
    ColorPalettePreview(colorPalette: colorPalette)
}
