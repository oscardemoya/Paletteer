//
//  SettingsPane.swift
//  Paletteer
//
//  Created by Oscar De Moya on 1/06/24.
//

import SwiftUI

struct SettingsPane: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage(key(.colorPalette)) var colorPalette = [ColorConfig]()
    @AppStorage(key(.showCopyIcons)) var showCopyIcons: Bool = true
    @AppStorage(key(.useColorInClipboard)) var useColorInClipboard: Bool = true
    @AppStorage(key(.hctLightChromaFactor)) var hctLightChromaFactor = ColorPaletteParams.hctLightChromaFactor
    @AppStorage(key(.hctDarkChromaFactor)) var hctDarkChromaFactor = ColorPaletteParams.hctDarkChromaFactor
    @AppStorage(key(.hsbDarkColorsHueOffset)) var hsbDarkColorsHueOffset = ColorPaletteParams.hsbDarkColorsHueOffset
    @AppStorage(key(.hsbLightSaturationFactor)) var hsbLightSaturationFactor = ColorPaletteParams.hsbLightSaturationFactor
    @AppStorage(key(.hsbDarkSaturationFactor)) var hsbDarkSaturationFactor = ColorPaletteParams.hsbDarkSaturationFactor
    @AppStorage(key(.hsbLightBrightnessFactor)) var hsbLightBrightnessFactor = ColorPaletteParams.hsbLightBrightnessFactor
    @AppStorage(key(.hsbDarkBrightnessFactor)) var hsbDarkBrightnessFactor = ColorPaletteParams.hsbDarkBrightnessFactor
    @AppStorage(key(.rgbDarkSaturationFactor)) var rgbDarkSaturationFactor = ColorPaletteParams.rgbDarkSaturationFactor
    @AppStorage(key(.rgbDarkBrightnessFactor)) var rgbDarkBrightnessFactor = ColorPaletteParams.rgbDarkBrightnessFactor
    @State private var colorClipboard = ColorClipboard()
    @State private var showDestructiveConfirmation: Bool = false
    @State private var destructiveButtonTitle: LocalizedStringKey = ""
    @State private var destructiveButtonText: LocalizedStringKey = ""
    @State private var destructiveAction: Action = {}

    var body: some View {
        settingsContainer
            .confirmationDialog(destructiveButtonTitle, isPresented: $showDestructiveConfirmation, titleVisibility: .visible) {
                Button(destructiveButtonText, role: .destructive, action: destructiveAction)
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This action cannot be undone.")
            }
    }
    
    @ViewBuilder
    var settingsContainer: some View {
#if os(macOS)
        TabView {
            Group {
                generalSettingsView
                    .tabItem {
                        Label("General", systemImage: "gear")
                    }
                colorSettingsView
                    .tabItem {
                        Label("Colors", systemImage: "paintpalette")
                    }
            }
            .padding()
        }
        .padding()
        .frame(width: 500)
#else
        NavigationStack {
            Form {
                NavigationLink("General", destination: generalSettingsView)
                NavigationLink("Colors", destination: colorSettingsView)
            }
            .navigationTitle("Settings")
        }
#endif
    }
    
    @ViewBuilder
    var generalSettingsView: some View {
        Form {
            Section("New Colors") {
                Toggle("Show Copy Icons", isOn: $showCopyIcons)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(4)
                Toggle("Use Color in Clipboard", isOn: $useColorInClipboard)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(4)

            }
            Section("Danger Zone") {
                Button {
                    destructiveButtonTitle = "Delete Color?"
                    destructiveButtonText = "Delete"
                    destructiveAction =  {
                        DispatchQueue.main.async {
                            dismiss()
                            colorPalette.removeAll()
                            colorClipboard.removeAll()
                        }
                    }
                    showDestructiveConfirmation = true
                } label: {
                    Text("Delete All Colors")
                        .frame(maxWidth: .infinity)
                }
                .tint(.destructiveBackground)
            }
        }
        .navigationTitle("General")
    }
    
    @ViewBuilder
    var colorSettingsView: some View {
        Form {
            Section("HCT") {
                HStack {
                    Text("Light Chroma Factor")
                    numericTextField(value: $hctLightChromaFactor)
                }
                HStack {
                    Text("Dark Chroma Factor")
                    numericTextField(value: $hctDarkChromaFactor)
                }
            }
            Section("HSB") {
                HStack {
                    Text("Dark Colors Hue Offset")
                    numericTextField(value: $hsbDarkColorsHueOffset)
                }
                HStack {
                    Text("Light Saturation Factor")
                    numericTextField(value: $hsbLightSaturationFactor)
                }
                HStack {
                    Text("Dark Saturation Factor")
                    numericTextField(value: $hsbDarkSaturationFactor)
                }
                HStack {
                    Text("Light Brightness Factor")
                    numericTextField(value: $hsbLightBrightnessFactor)
                }
                HStack {
                    Text("Dark Brightness Factor")
                    numericTextField(value: $hsbDarkBrightnessFactor)
                }
            }
            Section("RGB") {
                HStack {
                    Text("Dark Saturation Factor")
                    numericTextField(value: $rgbDarkSaturationFactor)
                }
                HStack {
                    Text("Dark Brightness Factor")
                    numericTextField(value: $rgbDarkBrightnessFactor)
                }
            }
            Section {
                Button {
                    destructiveButtonTitle = "Reset Color Settings?"
                    destructiveButtonText = "Reset"
                    destructiveAction = {
                        DispatchQueue.main.async {
                            dismiss()
                            resetColorSettings()
                        }
                    }
                    showDestructiveConfirmation = true
                } label: {
                    Text("Reset Color Settings")
                        .frame(maxWidth: .infinity)
                }
                .tint(.destructiveBackground)
            }
        }
        .navigationTitle("Color Generation")
    }
    
    @ViewBuilder
    func numericTextField<V>(value: Binding<V>) -> some View {
#if !os(macOS)
        Spacer()
#endif
        TextField("", value: value, formatter: NumberFormatter.decimal)
            .multilineTextAlignment(.center)
            .frame(width: 80)
            .textFieldStyle(RoundedBorderTextFieldStyle())
#if !os(macOS)
            .keyboardType(.decimalPad)
            .scrollDismissesKeyboard(.interactively)
#endif
    }
    
    func resetColorSettings() {
        hctLightChromaFactor = ColorPaletteParams.hctLightChromaFactor
        hctDarkChromaFactor = ColorPaletteParams.hctDarkChromaFactor
        hsbDarkColorsHueOffset = ColorPaletteParams.hsbDarkColorsHueOffset
        hsbLightSaturationFactor = ColorPaletteParams.hsbLightSaturationFactor
        hsbDarkSaturationFactor = ColorPaletteParams.hsbDarkSaturationFactor
        hsbLightBrightnessFactor = ColorPaletteParams.hsbLightBrightnessFactor
        hsbDarkBrightnessFactor = ColorPaletteParams.hsbDarkBrightnessFactor
        rgbDarkSaturationFactor = ColorPaletteParams.rgbDarkSaturationFactor
        rgbDarkBrightnessFactor = ColorPaletteParams.rgbDarkBrightnessFactor
    }
}

#Preview {
    SettingsPane()
}
