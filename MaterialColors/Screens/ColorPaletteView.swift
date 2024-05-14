//
//  ColorPaletteView.swift
//  MaterialColors
//
//  Created by Oscar De Moya on 27/04/24.
//

import SwiftUI

struct ColorPaletteView: View {
    var colorList: [ColorGroup]
    var fileURL = FileManager.default.fileURL(fileName: "Colors.xcassets")
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @State private var theme: Theme = .dual
    @State private var isMaterial: Bool = true
    @State private var backupFileURL: URL?
    @State private var isShowingShareView: Bool = false
    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""

    var body: some View {
        ZStack(alignment: .center) {
            VStack(spacing: 0) {
                Group {
                    Picker("Theme", selection: $theme) {
                        ForEach(Theme.allCases) {
                            Text($0.title)
                        }
                    }
                    .pickerStyle(.segmented)
                    Toggle(isOn: $isMaterial) {
                        Text("Use Material Color Space")
                    }
                }
                .padding()
                Divider()
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
                Divider()
                if let fileURL {
                    ShareLink(item: fileURL) {
                        Text("Export")
                            .font(.headline)
                            .fontWeight(.medium)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .tint(.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .padding()
                }
            }
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .padding()
            }
        }
        .onAppear {
            if let existingFileURL = fileURL, FileManager.default.fileExists(atPath: existingFileURL.path) {
                FileManager.default.removeDirectory(atURL: existingFileURL)
            }
        }
        .onChange(of: theme) { _, newValue in
            ColorSchemeSwitcher.shared.selectedAppearance = newValue
        }
        .onChange(of: isMaterial) { _, _ in
            if let existingFileURL = fileURL, FileManager.default.fileExists(atPath: existingFileURL.path) {
                FileManager.default.removeDirectory(atURL: existingFileURL)
            }
            colorList.forEach { group in
                saveFile(for: group)
            }
        }
    }
    
    private func saveFile(for group: ColorGroup) {
        saveEmptyFiles(groupPath: group.groupName)
        shades(for: group).enumerated().forEach { index, tuple in
            let lightCode: String
            if isMaterial {
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
                    ForEach(colorPairs.prefix(Int(ColorPalette.shadesCount(isMaterial: isMaterial) / 2)),
                            id: \.light.self) { color in
                        rectangle(colorPair: color)
                    }
                }
                HStack {
                    ForEach(colorPairs.suffix(Int(ColorPalette.shadesCount(isMaterial: isMaterial) / 2)),
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
            .fill(theme.color(for: colorPair))
            .overlay(
                Triangle()
                    .fill(theme == .dual ? colorPair.dark : .clear)
            )
            .frame(maxWidth: .infinity)
            .aspectRatio(1, contentMode: .fill)
            .cornerRadius(8)
            .onTapGesture {
                let hexColor = theme.color(for: colorPair).hexRGB.uppercased()
                UIPasteboard.general.string = hexColor
                alertTitle = hexColor
                alertMessage = "Copied to the clipboard."
                showAlert = true
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text(alertTitle), message: Text(alertMessage))
            }
    }
    
    private func shades(for group: ColorGroup) -> [ColorPair] {
        (0..<ColorPalette.shadesCount(isMaterial: isMaterial)).compactMap { index in
            if isMaterial {
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
            let adjustedColor = originalColor.adjust(saturation: 0.01, brightness: -0.015)
            let baseColor = group.narrow && config.light ? adjustedColor : originalColor
            let adjustedVariance = group.narrow && !light ? 0.65 : 1.0
            let opacities = ColorPalette.overlayOpacities(narrow: group.narrow)
            let sortedOpacities = group.narrow && light ? opacities.reversed() : opacities
            let opacity = Double(sortedOpacities[config.index]) / (100.0 / adjustedVariance)
            let overlay = ColorPalette.overlay(for: config.index, light: light, narrow: group.narrow)
            if opacity == 1 {
                color = config.light ? baseColor : baseColor.adjust(hue: 0.03, saturation: -0.02, brightness: -0.05)
            } else {
                let blend = Color.blend(color1: baseColor, intensity1: opacity,
                                        color2: overlay, intensity2: (1 / adjustedVariance) - opacity)
                color = config.light ? blend : blend.adjust(hue: 0.03, saturation: -0.02, brightness: -0.05)
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

#Preview {
    ColorPaletteView(colorList: [])
}
