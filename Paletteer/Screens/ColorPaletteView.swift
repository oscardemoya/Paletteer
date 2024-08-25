//
//  ColorPaletteView.swift
//  Paletteer
//
//  Created by Oscar De Moya on 27/04/24.
//

import SwiftUI

struct ColorPaletteView: View {
    static var fileName = "Colors.xcassets"
    static var defaultColorConfig = ColorConfig(colorModel: .rgb(Color(hex: "#689FD4")), colorName: "")
    var fileURL = FileManager.default.fileURL(fileName: Self.fileName)
    let fileManagerDelegate = CopyFileManagerDelegate()
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @AppStorage(key(.colorPalette)) var colorPalette = [ColorConfig]()
    @AppStorage(key(.colorScheme)) var selectedAppearance: AppColorScheme = .system
    @AppStorage(key(.colorSkipCount)) var colorSkipCount = ColorPaletteParams.colorSkipCount
    @AppStorage(key(.hctDarkColorsHueOffset)) var hctDarkColorsHueOffset = ColorPaletteParams.hctDarkColorsHueOffset
    @AppStorage(key(.hctLightChromaFactor)) var hctLightChromaFactor = ColorPaletteParams.hctLightChromaFactor
    @AppStorage(key(.hctDarkChromaFactor)) var hctDarkChromaFactor = ColorPaletteParams.hctDarkChromaFactor
    @AppStorage(key(.hctLightToneFactor)) var hctLightToneFactor = ColorPaletteParams.hctLightToneFactor
    @AppStorage(key(.hctDarkToneFactor)) var hctDarkToneFactor = ColorPaletteParams.hctDarkToneFactor
    @AppStorage(key(.hsbDarkColorsHueOffset)) var hsbDarkColorsHueOffset = ColorPaletteParams.hsbDarkColorsHueOffset
    @AppStorage(key(.hsbLightSaturationFactor)) var hsbLightSaturationFactor = ColorPaletteParams.hsbLightSaturationFactor
    @AppStorage(key(.hsbDarkSaturationFactor)) var hsbDarkSaturationFactor = ColorPaletteParams.hsbDarkSaturationFactor
    @AppStorage(key(.hsbLightBrightnessFactor)) var hsbLightBrightnessFactor = ColorPaletteParams.hsbLightBrightnessFactor
    @AppStorage(key(.hsbDarkBrightnessFactor)) var hsbDarkBrightnessFactor = ColorPaletteParams.hsbDarkBrightnessFactor
    @AppStorage(key(.rgbDarkColorsHueOffset)) var rgbDarkColorsHueOffset = ColorPaletteParams.rgbDarkColorsHueOffset
    @AppStorage(key(.rgbLightSaturationFactor)) var rgbLightSaturationFactor = ColorPaletteParams.rgbLightSaturationFactor
    @AppStorage(key(.rgbDarkSaturationFactor)) var rgbDarkSaturationFactor = ColorPaletteParams.rgbDarkSaturationFactor
    @AppStorage(key(.rgbLightBrightnessFactor)) var rgbLightBrightnessFactor = ColorPaletteParams.rgbLightBrightnessFactor
    @AppStorage(key(.rgbDarkBrightnessFactor)) var rgbDarkBrightnessFactor = ColorPaletteParams.rgbDarkBrightnessFactor
    @State var colorSpace: ColorSpace = .hct
    @State private var backupFileURL: URL?
    @State private var assetsFileURL: URL?
    @State private var isShowingShareView: Bool = false
    @State private var showAlert = false
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""
    @State private var isEditing = false
    @State private var exisitingColor = defaultColorConfig
    @State private var colorClipboard = ColorClipboard()
    
    var body: some View {
        colorGrid
            .frame(minWidth: CGFloat(ColorPalette.shadesCount) * 44)
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
#if !os(macOS)
            .background(.primaryBackground)
#endif
            .onAppear {
                ColorSchemeSwitcher.shared.overrideDisplayMode()
            }
            .onAppear(perform: generateColorShades)
            .onChange(of: colorSpace) { _, _ in
                generateColorShades()
            }
            .sheet(isPresented: $isEditing, onDismiss: generateColorShades) {
                ColorConfigForm(colorConfig: $exisitingColor, colorClipboard: $colorClipboard, isEditing: true)
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text(alertTitle), message: Text(alertMessage))
            }
    }
    
    @ViewBuilder var colorGrid: some View {
        VStack(spacing: 0) {
            ScrollView {
                ForEach(colorPalette) { colorConfig in
                    Text(colorConfig.colorName)
                        .font(.subheadline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(.foreground300)
                        .padding(.top, 4)
                        .onTapGesture {
                            isEditing = true
                            exisitingColor = colorConfig
                        }
                    rectangleStack(colorPairs: shades(for: colorConfig))
                }
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.viewAligned)
            .contentMargins(8, for: .scrollContent)
            .listRowInsets(EdgeInsets())
            Spacer(minLength: 0)
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
        colorPalette.forEach { config in
            createFile(for: config, colorPairs: shades(for: config))
        }
    }
    
    private func createFile(for config: ColorConfig, colorPairs: [ColorPair]) {
        if !config.groupName.isEmpty {
            saveEmptyFiles(to: config.groupName)
        }
        colorPairs.enumerated().forEach { index, color in
            let toneCode = ColorPalette.toneNames[index + colorSkipCount]
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
    
    private func rectangleStack(colorPairs: [ColorPair]) -> some View {
        VStack(spacing: 8) {
            if horizontalSizeClass == .compact {
                HStack(spacing: 8) {
                    ForEach(colorPairs.prefix(Int(ColorPalette.shadesCount / 2))) { color in
                        rectangle(colorPair: color)
                    }
                }
                HStack {
                    ForEach(colorPairs.suffix(Int(ColorPalette.shadesCount / 2))) { color in
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
    
    private func shades(for group: ColorConfig) -> [ColorPair] {
        let colorCount = ColorPalette.shadesCount - colorSkipCount
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
            let lightSkip = group.skipDirection.isForward ? colorSkipCount : 0
            let darkSkip = group.skipDirection.isBackward ? colorSkipCount : 0

            // Light Color
            let lightIndex = group.lightConfig.scale.isDarkening ? index + lightSkip : colorCount - index + darkSkip - 1
            let lightConfig = ColorConversion(color: color, index: lightIndex, light: true)
            let lightColor = generateColor(for: group, using: lightConfig)

            // Dark Color
            let darkIndex = group.darkConfig.scale.isLightening ? index + darkSkip : colorCount - index + lightSkip - 1
            let darkConfig = ColorConversion(color: color, index: darkIndex, light: false)
            let darkColor = generateColor(for: group, using: darkConfig)

            // Color Pair
            let toneCode = ColorPalette.toneNames[index + colorSkipCount]
            let toneName = String(format: "%03d", toneCode * 10)
            return ColorPair(name: group.colorName, toneCode: toneName, light: lightColor.color, dark: darkColor.color)
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
            hctColor.hue += (config.light ? 0 : hctDarkColorsHueOffset)
            hctColor.chroma *= (config.light ? hctLightChromaFactor : hctDarkChromaFactor)
            hctColor.tone = transformedTone * (config.light ? hctLightToneFactor : hctDarkToneFactor)
            color = Color(hctColor: hctColor)
            argb = hctColor.toInt()
        case .hsb(let hsbColor):
            var baseColor = hsbColor
            let schemeConfig = (config.light ? group.lightConfig : group.darkConfig)
            baseColor.hue += (config.light ? 0 : hsbDarkColorsHueOffset)
            let saturationFactor = (config.light ? hsbLightSaturationFactor : hsbDarkSaturationFactor)
            let saturationLevel = schemeConfig.saturationLevel.multiplier
            baseColor.saturation *= saturationFactor * normalizedTone.logaritmic(M_E * saturationFactor) * saturationLevel
            var brightnessLevel = schemeConfig.brightnessLevel.multiplier
            brightnessLevel = config.light ? 1 / brightnessLevel : brightnessLevel
            let brightnessFactor = (config.light ? 1 / hsbLightBrightnessFactor : hsbDarkBrightnessFactor) * brightnessLevel
            baseColor.brightness = normalizedTone.skewed(towards: config.light ? 1 : 0, alpha: brightnessFactor)
            color = Color(hsba: baseColor)
            argb = color.rgbInt ?? 0
        case .rgb(let rgbColor):
            let adjustedValue = normalizedTone.skewed(towards: 0, alpha: 0.75)
            let opacity = (adjustedValue < 0.5 ? adjustedValue : 1 - adjustedValue) * 2
            let overlay = ColorPalette.overlay(light: adjustedValue > 0.5)
            let blend = Color.blend(color1: rgbColor, intensity1: opacity, color2: overlay, intensity2: (1 - opacity))
            let saturationFactor = config.light ? rgbLightSaturationFactor : rgbDarkSaturationFactor
            let brightnessFactor = config.light ? rgbLightBrightnessFactor : rgbDarkBrightnessFactor
            let hueOffset = (config.light ? 0 : hctDarkColorsHueOffset)
            let hsbColor = rgbColor.hsba ?? .black
            let saturation = hsbColor.saturation * saturationFactor
            let brightness = hsbColor.brightness * brightnessFactor
            color = blend.adjust(hue: hueOffset, saturation: saturation, brightness: brightness)
            argb = color.rgbInt ?? 0
        }
        return (color: color, argb: argb)
    }
    
    private func transformedTone(_ tone: Double, group: ColorConfig, config: ColorConversion) -> CGFloat {
        let range = (config.light ? group.lightConfig : group.darkConfig).range
        let startPercent = range.startPercent
        let rangeWidthPercent = range.width.percent
        let rangeWidth = range.width.value
        return (config.light ? startPercent : 100 - rangeWidthPercent - startPercent) + (tone * rangeWidth)
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
    ColorPaletteView(colorSpace: .hsb)
}
