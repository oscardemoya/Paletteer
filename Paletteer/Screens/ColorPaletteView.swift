//
//  ColorPaletteView.swift
//  Paletteer
//
//  Created by Oscar De Moya on 27/04/24.
//

import SwiftUI

struct ColorPaletteView: View {
    static var fileName = "Colors.xcassets"
    var colorList: [ColorGroup]
    var fileURL = FileManager.default.fileURL(fileName: Self.fileName)
    let fileManagerDelegate = CopyFileManagerDelegate()
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @AppStorage(key(.colorScheme)) var selectedAppearance: AppColorScheme = .system
    @State private var colorSpace: ColorSpace = .hct
    @State private var backupFileURL: URL?
    @State private var assetsFileURL: URL?
    @State private var isShowingShareView: Bool = false
    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""

    var body: some View {
        ZStack(alignment: .center) {
            VStack(spacing: 0) {
                ScrollView {
                    ForEach(colorList) { colorGroup in
                        rectangleStack(colorPairs: shades(for: colorGroup))
                    }
                    .scrollTargetLayout()
                }
                .scrollTargetBehavior(.viewAligned)
                .contentMargins(8, for: .scrollContent)
                .listRowInsets(EdgeInsets())
                Spacer(minLength: 0)
            }
            .background(.primaryBackground)
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
#if os(macOS)
                        Button {
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
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .padding()
            }
        }
#if os(macOS)
        .aspectRatio(14/8, contentMode: .fit)
#endif
        .onAppear {
            ColorSchemeSwitcher.shared.overrideDisplayMode()
        }
        .onAppear {
            if let existingFileURL = fileURL, FileManager.default.fileExists(atPath: existingFileURL.path) {
                FileManager.default.removeDirectory(atURL: existingFileURL)
            }
        }
        .onChange(of: colorSpace == .hct) { _, _ in
            if let existingFileURL = fileURL, FileManager.default.fileExists(atPath: existingFileURL.path) {
                FileManager.default.removeDirectory(atURL: existingFileURL)
            }
            colorList.forEach { group in
                saveFile(for: group)
            }
        }
    }
    
#if os(macOS)
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
    
    private func saveFile(for group: ColorGroup) {
        saveEmptyFiles(groupPath: group.groupName)
        shades(for: group).enumerated().forEach { index, tuple in
            let lightCode: String
            if colorSpace == .hct {
                let lightTone = ColorPalette.tones(light: false)[index]
                lightCode = String(format: "%03d", lightTone * 10)
            } else {
                let overlayTone = ColorPalette.overlayTones[index]
                lightCode = String(format: "%03d", overlayTone * 10)
            }
            let colorName = "\(group.colorName)-\(lightCode)"
            saveFile(groupPath: "\(group.groupName)/\(group.colorName)", colorName: colorName,
                     lightArgb: tuple.light.rgbInt ?? 0, darkArgb: tuple.dark.rgbInt ?? 0)
        }
    }
    
    private func rectangleStack(colorPairs: [ColorPair]) -> some View {
        VStack(spacing: 8) {
            if horizontalSizeClass == .compact {
                HStack(spacing: 8) {
                    ForEach(colorPairs.prefix(Int(ColorPalette.shadesCount(isMaterial: colorSpace == .hct) / 2)),
                            id: \.light.self) { color in
                        rectangle(colorPair: color)
                    }
                }
                HStack {
                    ForEach(colorPairs.suffix(Int(ColorPalette.shadesCount(isMaterial: colorSpace == .hct) / 2)),
                            id: \.light.self) { color in
                        rectangle(colorPair: color)
                    }
                }
            } else {
                HStack(spacing: 8) {
                    ForEach(colorPairs, id: \.light.self) { color in
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
            )
            .frame(maxWidth: .infinity)
            .aspectRatio(1, contentMode: .fill)
            .cornerRadius(8)
            .onTapGesture {
                let hexColor = selectedAppearance.color(for: colorPair).hexRGB.uppercased()
                String.pasteboardString = hexColor
                alertTitle = hexColor
                alertMessage = "Copied to the clipboard."
                showAlert = true
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text(alertTitle), message: Text(alertMessage))
            }
    }
    
    private func shades(for group: ColorGroup) -> [ColorPair] {
        (0..<ColorPalette.shadesCount(isMaterial: colorSpace == .hct)).compactMap { index in
            if colorSpace == .hct {
                guard let hctColor = group.color.hct else { return nil }
                return .hct(hctColor)
            } else {
                return .rgb(group.color)
            }
        }.enumerated().map { (index: Int, color: ColorMode) in
            let lightConfig = ColorConversion(color: color, index: index, light: true)
            let darkConfig = ColorConversion(color: color, index: index, light: false)
            let lightColor = generateColor(for: group, using: lightConfig)
            let darkColor = generateColor(for: group, using: darkConfig)
            return (light: lightColor.color, dark: darkColor.color)
        }
    }
    
    private func generateColor(for group: ColorGroup, using config: ColorConversion) -> (color: Color, argb: Int) {
        var color: Color
        var argb: Int
        switch config.color {
        case .hct(let hctColor):
            let tones = ColorPalette.tones(light: config.light)
            let orderedTones = group.reversed ? tones.reversed() : tones
            hctColor.tone = Double(orderedTones[config.index])
            hctColor.chroma = hctColor.chroma * (config.light ? 1 : 0.75)
            color = Color(hctColor: hctColor)
            argb = hctColor.toInt()
        case .rgb(let originalColor):
            let light = group.reversed ? !config.light : config.light
            var baseColor = originalColor
            if group.narrow, let originalValues = originalColor.hsba {
                baseColor = originalColor.replace(saturation: config.light ? originalValues.saturation + 0.01 : 0,
                                                  brightness: config.light ? 0.85 : 0.15)
            }
            let opacities: [(light: Bool?, opacity: Int)] = ColorPalette.overlayOpacities(light: light, narrow: group.narrow)
            let opacity = Double(opacities[config.index].opacity) / 100.0
            let overlay = ColorPalette.overlay(light: opacities[config.index].light)
            if opacity == 1 {
                color = config.light ? baseColor : baseColor.adjust(hue: 0.03, saturation: -0.02, brightness: -0.05)
            } else {
                let blend = Color.blend(color1: baseColor, intensity1: opacity,
                                        color2: overlay, intensity2: 1 - opacity)
                color = config.light ? blend : blend.adjust(hue: 0.045, saturation: 0.01, brightness: -0.05)
            }
            argb = color.rgbInt ?? 0
        }
        return (color: color, argb: argb)
    }
    
    private func saveFile(groupPath: String, colorName: String, lightArgb: Int, darkArgb: Int) {
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
            "{{dr}}" : darkRed.hexStringWithPrefix,
            "{{dg}}" : darkGreen.hexStringWithPrefix,
            "{{db}}" : darkBlue.hexStringWithPrefix,
        ]
        let fileContent = String(forResource: "ColorContentsTemplate", ofType: "json", parameters: parameters)
        fileContent?.write(to: "Colors.xcassets/Colors/\(groupPath)/\(colorName).colorset/Contents.json")
    }
    
    private func saveEmptyFiles(groupPath: String) {
        let emptyContent = String(forResource: "Contents", ofType: "json")
        emptyContent?.write(to: "Colors.xcassets/Colors/\(groupPath)/Contents.json")
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
    ColorPaletteView(colorList: [])
}
