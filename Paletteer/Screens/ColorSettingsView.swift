//
//  ColorSettingsView.swift
//  Paletteer
//
//  Created by Oscar De Moya on 26/06/24.
//

import SwiftUI

struct ColorSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage(key(.colorSkipCount)) var colorSkipCount = ColorPaletteParams.colorSkipCount
    @AppStorage(key(.colorSkipScheme)) var colorSkipScheme = ColorPaletteParams.colorSkipScheme
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
    @State private var showDestructiveConfirmation: Bool = false
    @State private var destructiveButtonTitle: LocalizedStringKey = ""
    @State private var destructiveButtonText: LocalizedStringKey = ""
    @State private var destructiveAction: Action = {}
    
    var body: some View {
        Form {
            Section {
                HStack {
                    integerTextField(value: $colorSkipCount)
                    Picker("", selection: $colorSkipScheme) {
                        ForEach(AppColorScheme.schemes, id: \.self) { item in
                            Text(item.name).tag(item)
                        }
                    }
                    .frame(width: 80)
                }
            } header: {
                Text("Color Skip")
                    .font(.headline)
            }
            Section {
                HStack {
                    Text("Dark Colors Hue Offset")
                    decimalTextField(value: $hctDarkColorsHueOffset)
                }
                HStack {
                    Text("Light Chroma Factor")
                    decimalTextField(value: $hctLightChromaFactor)
                }
                HStack {
                    Text("Dark Chroma Factor")
                    decimalTextField(value: $hctDarkChromaFactor)
                }
                HStack {
                    Text("Light Tone Factor")
                    decimalTextField(value: $hctLightToneFactor)
                }
                HStack {
                    Text("Dark Tone Factor")
                    decimalTextField(value: $hctDarkToneFactor)
                }
            } header: {
                Text("HCT")
                    .font(.headline)
            }
            Section {
                HStack {
                    Text("Dark Colors Hue Offset")
                    decimalTextField(value: $hsbDarkColorsHueOffset)
                }
                HStack {
                    Text("Light Saturation Factor")
                    decimalTextField(value: $hsbLightSaturationFactor)
                }
                HStack {
                    Text("Dark Saturation Factor")
                    decimalTextField(value: $hsbDarkSaturationFactor)
                }
                HStack {
                    Text("Light Brightness Factor")
                    decimalTextField(value: $hsbLightBrightnessFactor)
                }
                HStack {
                    Text("Dark Brightness Factor")
                    decimalTextField(value: $hsbDarkBrightnessFactor)
                }
            } header: {
                Text("HSB")
                    .font(.headline)
            }
            Section {
                HStack {
                    Text("Dark Colors Hue Offset")
                    decimalTextField(value: $rgbDarkColorsHueOffset)
                }
                HStack {
                    Text("Light Saturation Factor")
                    decimalTextField(value: $rgbLightSaturationFactor)
                }
                HStack {
                    Text("Dark Saturation Factor")
                    decimalTextField(value: $rgbDarkSaturationFactor)
                }
                HStack {
                    Text("Light Brightness Factor")
                    decimalTextField(value: $rgbLightBrightnessFactor)
                }
                HStack {
                    Text("Dark Brightness Factor")
                    decimalTextField(value: $rgbDarkBrightnessFactor)
                }
            } header: {
                Text("RGB")
                    .font(.headline)
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
                    Text("Reset")
                        .frame(maxWidth: .infinity)
                }
                .tint(.destructiveBackground)
            }
        }
#if os(macOS)
        .padding()
#endif
        .fixedSize(horizontal: true, vertical: false)
        .navigationTitle("Color Generation")
        .confirmationDialog(destructiveButtonTitle, isPresented: $showDestructiveConfirmation, titleVisibility: .visible) {
            Button(destructiveButtonText, role: .destructive, action: destructiveAction)
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This action cannot be undone.")
        }
    }
    
    @ViewBuilder
    func integerTextField(value: Binding<Int>) -> some View {
#if !os(macOS)
        Spacer()
#endif
        Stepper("\(value.wrappedValue)", value: value, in: 0...(ColorPalette.tonesCount - 1))
    }
    
    @ViewBuilder
    func decimalTextField<V>(value: Binding<V>) -> some View {
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
        rgbLightSaturationFactor = ColorPaletteParams.rgbLightSaturationFactor
        rgbDarkSaturationFactor = ColorPaletteParams.rgbDarkSaturationFactor
        rgbLightBrightnessFactor = ColorPaletteParams.rgbLightBrightnessFactor
        rgbDarkBrightnessFactor = ColorPaletteParams.rgbDarkBrightnessFactor
    }
}

#Preview {
    ColorSettingsView()
        .fixedSize()
}
