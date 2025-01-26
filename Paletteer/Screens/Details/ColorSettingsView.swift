//
//  ColorSettingsView.swift
//  Paletteer
//
//  Created by Oscar De Moya on 26/06/24.
//

import SwiftUI

struct ColorSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage(key(.colorPaletteParams)) var params = ColorPaletteParams()
    @State private var showDestructiveConfirmation: Bool = false
    @State private var destructiveButtonTitle: LocalizedStringKey = ""
    @State private var destructiveButtonText: LocalizedStringKey = ""
    @State private var destructiveAction: Action = {}
    
    var body: some View {
        Form {
            Section {
                HStack {
                    integerTextField(value: $params.colorSkipCount)
                    Picker("", selection: $params.colorSkipScheme) {
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
                    decimalTextField(value: $params.hctDarkColorsHueOffset)
                }
                HStack {
                    Text("Light Chroma Factor")
                    decimalTextField(value: $params.hctLightChromaFactor)
                }
                HStack {
                    Text("Dark Chroma Factor")
                    decimalTextField(value: $params.hctDarkChromaFactor)
                }
                HStack {
                    Text("Light Tone Factor")
                    decimalTextField(value: $params.hctLightToneFactor)
                }
                HStack {
                    Text("Dark Tone Factor")
                    decimalTextField(value: $params.hctDarkToneFactor)
                }
            } header: {
                Text("HCT")
                    .font(.headline)
            }
            Section {
                HStack {
                    Text("Dark Colors Hue Offset")
                    decimalTextField(value: $params.hsbDarkColorsHueOffset)
                }
                HStack {
                    Text("Light Saturation Factor")
                    decimalTextField(value: $params.hsbLightSaturationFactor)
                }
                HStack {
                    Text("Dark Saturation Factor")
                    decimalTextField(value: $params.hsbDarkSaturationFactor)
                }
                HStack {
                    Text("Light Brightness Factor")
                    decimalTextField(value: $params.hsbLightBrightnessFactor)
                }
                HStack {
                    Text("Dark Brightness Factor")
                    decimalTextField(value: $params.hsbDarkBrightnessFactor)
                }
            } header: {
                Text("HSB")
                    .font(.headline)
            }
            Section {
                HStack {
                    Text("Dark Colors Hue Offset")
                    decimalTextField(value: $params.rgbDarkColorsHueOffset)
                }
                HStack {
                    Text("Light Saturation Factor")
                    decimalTextField(value: $params.rgbLightSaturationFactor)
                }
                HStack {
                    Text("Dark Saturation Factor")
                    decimalTextField(value: $params.rgbDarkSaturationFactor)
                }
                HStack {
                    Text("Light Brightness Factor")
                    decimalTextField(value: $params.rgbLightBrightnessFactor)
                }
                HStack {
                    Text("Dark Brightness Factor")
                    decimalTextField(value: $params.rgbDarkBrightnessFactor)
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
#if os(macOS) || targetEnvironment(macCatalyst)
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
#if !os(macOS) && !targetEnvironment(macCatalyst)
        Spacer()
#endif
        Stepper("\(value.wrappedValue)", value: value, in: 0...(ColorPaletteConstants.tonesCount - 1))
    }
    
    @ViewBuilder
    func decimalTextField<V>(value: Binding<V>) -> some View {
#if !os(macOS) && !targetEnvironment(macCatalyst)
        Spacer()
#endif
        TextField("", value: value, formatter: NumberFormatter.decimal)
            .multilineTextAlignment(.center)
            .frame(width: 80)
            .textFieldStyle(RoundedBorderTextFieldStyle())
#if !os(macOS) && !targetEnvironment(macCatalyst)
            .keyboardType(.decimalPad)
            .scrollDismissesKeyboard(.interactively)
#endif
    }
    
    func resetColorSettings() {
        params = ColorPaletteParams()
    }
}

#Preview {
    ColorSettingsView()
        .fixedSize()
}
