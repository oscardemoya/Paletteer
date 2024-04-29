//
//  ColorPaletteView.swift
//  MaterialColors
//
//  Created by Oscar De Moya on 27/04/24.
//

import SwiftUI

struct ColorPaletteView: View {
    var colorList: [ColorConfig]
    var fileURL = FileManager.default.fileURL(fileName: "Colors.xcassets")
    
    @Environment(\.colorScheme) var colorScheme
    @State var theme: Theme = .dual
    @State var backupFileURL: URL?
    @State var isShowingShareView: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            Picker("Theme", selection: $theme) {
                ForEach(Theme.allCases) {
                    Text($0.title)
                }
            }
            .pickerStyle(.segmented)
            .padding()
            Divider()
            ScrollView {
                ForEach(colorList) { colorConfig in
                    rectangleStack(colorPairs: shades(fromConfig: colorConfig))
                }
                .padding()
            }
            Spacer(minLength: 0)
            Divider()
            Button {
                backupFileURL = fileURL
            } label: {
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
        .onAppear {
            if let existingFileURL = fileURL {
                FileManager.default.removeDirectory(atURL: existingFileURL)
            }
        }
        .onChange(of: theme) { _, newValue in
            ColorSchemeSwitcher.shared.selectedAppearance = newValue
        }
        .onChange(of: backupFileURL) { _, newValue in
            isShowingShareView = newValue != nil
        }
        .sheet(isPresented: $isShowingShareView) {
            backupFileURL = nil
        } content: {
            if let backupFileURL {
                ActivityViewController(activityItems: [backupFileURL])
            }
        }
    }
    
    private func rectangleStack(colorPairs: [ColorPair]) -> some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                ForEach(colorPairs.prefix(Int(ColorPalette.tones.count / 2)), id: \.light.self) { color in
                    rectangle(colorPair: color)
                }
            }
            HStack {
                ForEach(colorPairs.suffix(Int(ColorPalette.tones.count / 2)), id: \.light.self) { color in
                    rectangle(colorPair: color)
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
    
    private func shades(fromConfig config: ColorConfig) -> [ColorPair] {
        guard let argb = StringUtils.argbFromHex(config.hexColor) else { return [] }
        return (0..<ColorPalette.tones.count).map { index in
            let hctColor = Hct(argb)
            let lightConfig = HCTConfig(hctColor: hctColor, index: index, light: true)
            let lightColor = color(from: lightConfig, colorConfig: config)
            let darkConfig = HCTConfig(hctColor: hctColor, index: index, light: false)
            let darkColor = color(from: darkConfig, colorConfig: config)
            let lightTone = ColorPalette.tones[index]
            let lightCode = String(format: "%03d", lightTone * 10)
            let lightHex = StringUtils.hexFromArgb(lightColor.argb)
            let darkHex = StringUtils.hexFromArgb(darkColor.argb)
            let colorName = "\(config.colorName)-\(lightCode)"
            saveFile(groupPath: "\(config.groupName)/\(config.colorName)", colorName: colorName,
                     lightArgb: lightColor.argb, darkArgb: darkColor.argb)
            return (light: lightColor.color, dark: darkColor.color)
        }
    }
    
    private func color(from hctConfig: HCTConfig, colorConfig: ColorConfig) -> (color: Color, argb: Int)  {
        let tones = ColorPalette.tones(light: hctConfig.light)
        let orderedDones = colorConfig.reversed ? tones.reversed() : tones
        hctConfig.hctColor.tone = Double(orderedDones[hctConfig.index])
        hctConfig.hctColor.chroma = hctConfig.hctColor.chroma * (hctConfig.light ? 1 : 0.75)
        let argb = hctConfig.hctColor.toInt()
        let color = Color(hctColor: hctConfig.hctColor)
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
