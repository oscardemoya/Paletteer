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
    @AppStorage(key(.hctLightChromaFactor)) var hctLightChromaFactor = ColorPaletteParams.hctLightChromaFactor
    @AppStorage(key(.hctDarkChromaFactor)) var hctDarkChromaFactor = ColorPaletteParams.hctDarkChromaFactor
    @AppStorage(key(.hsbDarkColorsHueOffset)) var hsbDarkColorsHueOffset = ColorPaletteParams.hsbDarkColorsHueOffset
    @AppStorage(key(.hsbLightSaturationFactor)) var hsbLightSaturationFactor = ColorPaletteParams.hsbLightSaturationFactor
    @AppStorage(key(.hsbDarkSaturationFactor)) var hsbDarkSaturationFactor = ColorPaletteParams.hsbDarkSaturationFactor
    @AppStorage(key(.hsbLightBrightnessFactor)) var hsbLightBrightnessFactor = ColorPaletteParams.hsbLightBrightnessFactor
    @AppStorage(key(.hsbDarkBrightnessFactor)) var hsbDarkBrightnessFactor = ColorPaletteParams.hsbDarkBrightnessFactor
    @AppStorage(key(.rgbDarkSaturationFactor)) var rgbDarkSaturationFactor = ColorPaletteParams.rgbDarkSaturationFactor
    @AppStorage(key(.rgbDarkBrightnessFactor)) var rgbDarkBrightnessFactor = ColorPaletteParams.rgbDarkBrightnessFactor
    @State var colorSpace: ColorSpace = .hct
    @State private var backupFileURL: URL?
    @State private var assetsFileURL: URL?
    @State private var isShowingShareView: Bool = false
    @State private var showAlert = false
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""

    var body: some View {
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
#if os(macOS)
        .aspectRatio(14/CGFloat(colorList.count), contentMode: .fit)
#else
        .background(.primaryBackground)
#endif
        .onAppear {
            ColorSchemeSwitcher.shared.overrideDisplayMode()
        }
        .onAppear {
            generateColorShades()
        }
        .onChange(of: colorSpace) { _, _ in
            generateColorShades()
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text(alertTitle), message: Text(alertMessage))
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
    
    private func generateColorShades() {
        if let existingFileURL = fileURL, FileManager.default.fileExists(atPath: existingFileURL.path) {
            FileManager.default.removeDirectory(atURL: existingFileURL)
        }
        colorList.forEach { config in
            createFile(for: config, colorPairs: shades(for: config))
        }
    }
    
    private func createFile(for config: ColorConfig, colorPairs: [ColorPair]) {
        if !config.groupName.isEmpty {
            saveEmptyFiles(to: config.groupName)
        }
        colorPairs.enumerated().forEach { index, color in
            let lightCode: String
            if colorSpace == .rgb {
                let overlayTone = ColorPalette.overlayTones[index]
                lightCode = String(format: "%03d", overlayTone * 10)
            } else {
                let lightTone = ColorPalette.tones(light: false)[index]
                lightCode = String(format: "%03d", lightTone * 10)
            }
            let colorName = "\(config.colorName.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))-\(lightCode)"
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
    
    private func rectangleStack(colorPairs: [ColorPair]) -> some View {
        VStack(spacing: 8) {
            if horizontalSizeClass == .compact {
                HStack(spacing: 8) {
                    ForEach(colorPairs.prefix(Int(ColorPalette.shadesCount(isMaterial: colorSpace == .hct) / 2))) { color in
                        rectangle(colorPair: color)
                    }
                }
                HStack {
                    ForEach(colorPairs.suffix(Int(ColorPalette.shadesCount(isMaterial: colorSpace == .hct) / 2))) { color in
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
            return ColorPair(light: lightColor.color, dark: darkColor.color)
        }
    }
    
    private func generateColor(for group: ColorConfig, using config: ColorConversion) -> (color: Color, argb: Int) {
        var color: Color
        var argb: Int
        let tones = ColorPalette.tones(light: config.light)
        let tone = Double(tones[config.index])
        let transformedTone = transformedTone(tone, group: group, config: config)
        let normalizedTone = min(max(transformedTone / 100, 0), 1)
        switch config.color {
        case .hct(let hctColor):
            hctColor.tone = transformedTone
            hctColor.chroma = hctColor.chroma * (config.light ? hctLightChromaFactor : hctDarkChromaFactor)
            color = Color(hctColor: hctColor)
            argb = hctColor.toInt()
        case .hsb(let hsbColor):
            var baseColor = hsbColor
            baseColor.hue += (config.light ? 0 : hsbDarkColorsHueOffset)
            let saturationFactor = (config.light ? hsbLightSaturationFactor : hsbDarkSaturationFactor)
            baseColor.saturation *= saturationFactor * normalizedTone.logaritmic(M_E * group.colorRange.width.value)
            let brightnessFactor = (config.light ? hsbLightBrightnessFactor : hsbDarkBrightnessFactor) * hsbColor.saturation.mapped(to: 0.25...1)
            baseColor.brightness = (1 - normalizedTone).logaritmic(M_E * brightnessFactor)
            color = Color(hsba: baseColor)
            argb = color.rgbInt ?? 0
        case .rgb(let rgbColor):
            let opacity = (normalizedTone < 0.5 ? normalizedTone : 1 - normalizedTone) * 2
            let overlay = ColorPalette.overlay(light: normalizedTone > 0.5)
            let blend = Color.blend(color1: rgbColor, intensity1: opacity, color2: overlay, intensity2: 1 - opacity)
            color = config.light ? blend : blend.adjust(saturation: rgbDarkSaturationFactor, brightness: rgbDarkBrightnessFactor)
            argb = color.rgbInt ?? 0
        }
        return (color: color, argb: argb)
    }
    
    private func transformedTone(_ tone: Double, group: ColorConfig, config: ColorConversion) -> CGFloat {
        if group.colorRange.width.isWhole {
            return tone
        } else {
            let startPercent = group.colorRange.startPercent
            let rangeWidthPercent = group.colorRange.width.percent
            let rangeWidth = group.colorRange.width.value
            return (config.light ? startPercent : 100 - rangeWidthPercent - startPercent) + (tone * rangeWidth)
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
    ColorPaletteView(colorList: .sample, colorSpace: .rgb)
}
