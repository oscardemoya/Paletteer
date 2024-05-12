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
                if let backupFileURL {
                    ShareLink(item: backupFileURL) {
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
            if let existingFileURL = fileURL {
                FileManager.default.removeDirectory(atURL: existingFileURL)
                backupFileURL = fileURL
            }
        }
        .onChange(of: theme) { _, newValue in
            ColorSchemeSwitcher.shared.selectedAppearance = newValue
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
    }
    
    private func shades(for group: ColorGroup) -> [ColorPair] {
        return (0..<ColorPalette.shadesCount(isMaterial: isMaterial)).compactMap { index in
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
            let lightCode: String
            if isMaterial {
                let lightTone = ColorPalette.tones(light: false)[index]
                lightCode = String(format: "%03d", lightTone * 10)
            } else {
                lightCode = String(format: "%03d", index * 10)
            }
            let colorName = "\(group.colorName)-\(lightCode)"
            saveFile(groupPath: "\(group.groupName)/\(group.colorName)", colorName: colorName,
                     lightArgb: lightColor.argb, darkArgb: darkColor.argb)
            return (light: lightColor.color, dark: darkColor.color)
        }
    }
    
    private func generateColor(for group: ColorGroup, using config: ColorConversion) -> (color: Color, argb: Int)  {
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
        case .rgb(let baseColor):
            let opacity = Double(ColorPalette.overlayOpacities[config.index]) / 100.0
            let light = group.reversed ? !config.light : config.light
            let overlay = ColorPalette.overlay(for: config.index, light: light)
            color = Color.blend(color1: baseColor, intensity1: opacity, color2: overlay, intensity2: 1 - opacity)
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
}

#Preview {
    ColorPaletteView(colorList: [])
}
