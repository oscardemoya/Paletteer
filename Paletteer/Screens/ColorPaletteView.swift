//
//  ColorPaletteView.swift
//  Paletteer
//
//  Created by Oscar De Moya on 27/04/24.
//

import SwiftUI

struct ColorPaletteView: View {
    static var fileName = "Colors.xcassets"
    var colorList: [ColorConfig]
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
                    ForEach(colorList) { colorConfig in
                        rectangleStack(colorPairs: shades(for: colorConfig))
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
            saveFiles()
        }
        .onChange(of: colorSpace) { _, _ in
            saveFiles()
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
    
    private func saveFiles() {
        if let existingFileURL = fileURL, FileManager.default.fileExists(atPath: existingFileURL.path) {
            FileManager.default.removeDirectory(atURL: existingFileURL)
        }
        colorList.forEach { group in
            saveFile(for: group)
        }
    }
    
    private func saveFile(for config: ColorConfig) {
        if !config.groupName.isEmpty {
            saveEmptyFiles(to: config.groupName)
        }
        shades(for: config).enumerated().forEach { index, tuple in
            let lightCode: String
            if colorSpace == .hct {
                let lightTone = ColorPalette.tones(light: false)[index]
                lightCode = String(format: "%03d", lightTone * 10)
            } else {
                let overlayTone = ColorPalette.overlayTones[index]
                lightCode = String(format: "%03d", overlayTone * 10)
            }
            let colorName = "\(config.colorName.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))-\(lightCode)"
            var pathComponents = [String]()
            if !config.groupName.isEmpty {
                pathComponents.append(config.groupName.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))
            }
            pathComponents.append(config.colorName)
            let path = pathComponents.joined(separator: "/")
            let lightArgb = tuple.light.rgbInt ?? 0
            let darkArgb = tuple.dark.rgbInt ?? 0
            saveFile(to: path, colorName: colorName, lightArgb: lightArgb, darkArgb: darkArgb)
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
    
    private func shades(for group: ColorConfig) -> [ColorPair] {
        let colorCount = ColorPalette.shadesCount(isMaterial: colorSpace == .hct)
        return (0..<colorCount).compactMap { index in
            switch colorSpace {
            case .hct:
                guard let hctColor = group.color.hct else { return nil }
                return .hct(hctColor)
            case .hsb:
                guard let hsbColor = group.color.hsba else { return nil }
                return .hsb(hsbColor)
            case .rgb:
                return .rgb(group.color)
            }
        }.enumerated().map { (index: Int, color: ColorModel) in
            let lightIndex = group.lightColorScale.isDarkening ? index : colorCount - index - 1
            let lightConfig = ColorConversion(color: color, index: lightIndex, light: true)
            let darkIndex = group.darkColorScale.isLightening ? index : colorCount - index - 1
            let darkConfig = ColorConversion(color: color, index: darkIndex, light: false)
            let lightColor = generateColor(for: group, using: lightConfig)
            let darkColor = generateColor(for: group, using: darkConfig)
            return (light: lightColor.color, dark: darkColor.color)
        }
    }
    
    private func generateColor(for group: ColorConfig, using config: ColorConversion) -> (color: Color, argb: Int) {
        var color: Color
        var argb: Int
        switch config.color {
        case .hct(let hctColor):
            let tones = ColorPalette.tones(light: config.light)
            let tone = Double(tones[config.index])
            switch group.rangeWidth {
            case .full:
                hctColor.tone = tone
            case .wide:
                hctColor.tone = (config.light ? 25 : 0) + (tone * 3.0 / 4.0)
            case .half:
                hctColor.tone = (config.light ? 50 : 0) + (tone / 2.0)
            case .narrow:
                hctColor.tone = (config.light ? 75 : 0) + (tone / 4.0)
            }
            hctColor.chroma = hctColor.chroma * (config.light ? 1 : 0.75)
            color = Color(hctColor: hctColor)
            argb = hctColor.toInt()
        case .hsb(let hsbColor):
            var baseColor = hsbColor
            if !group.rangeWidth.isFull {
                baseColor.saturation = config.light ? hsbColor.saturation + 0.01 : 0
                baseColor.brightness = baseBrightness(group: group, config: config)
            }
            let opacities = ColorPalette.overlayOpacities(light: config.light, full: group.rangeWidth.isFull)
            let opacity = Double(opacities[config.index].opacity) / 100.0
            if opacities[config.index].light {
                baseColor.saturation = hsbColor.saturation * opacity
                baseColor.brightness = hsbColor.brightness + (((1 - hsbColor.brightness)) * (1 - opacity))
            } else {
                baseColor.brightness = hsbColor.brightness * opacity
            }
            color = Color(hsba: baseColor)
            argb = color.rgbInt ?? 0
        case .rgb(let rgbColor):
            var baseColor = rgbColor
            if !group.rangeWidth.isFull, let originalValues = rgbColor.hsba {
                let brightness: CGFloat = baseBrightness(group: group, config: config)
                baseColor = rgbColor.replace(saturation: config.light ? originalValues.saturation + 0.01 : 0,
                                             brightness: brightness)
            }
            let opacities = ColorPalette.overlayOpacities(light: config.light, full: group.rangeWidth.isFull)
            let opacity = Double(opacities[config.index].opacity) / 100.0
            if opacity == 1 {
                color = config.light ? baseColor : baseColor.adjust(hue: 0.03, saturation: -0.02, brightness: -0.05)
            } else {
                let overlay = ColorPalette.overlay(light: opacities[config.index].light)
                let blend = Color.blend(color1: baseColor, intensity1: opacity,
                                        color2: overlay, intensity2: 1 - opacity)
                color = config.light ? blend : blend.adjust(hue: 0.045, saturation: 0.01, brightness: -0.05)
            }
            argb = color.rgbInt ?? 0
        }
        return (color: color, argb: argb)
    }
    
    private func baseBrightness(group: ColorConfig, config: ColorConversion) -> CGFloat {
        switch group.rangeWidth {
        case .full: 1.0
        case .wide: config.light ? 0.25 : 0.75
        case .half: 0.5
        case .narrow: config.light ? 0.75 : 0.25
        }
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
            "{{dr}}" : darkRed.hexStringWithPrefix,
            "{{dg}}" : darkGreen.hexStringWithPrefix,
            "{{db}}" : darkBlue.hexStringWithPrefix,
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
    ColorPaletteView(colorList: [])
}
