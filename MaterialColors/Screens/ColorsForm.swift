//
//  ColorsForm.swift
//  MaterialColors
//
//  Created by Oscar De Moya on 22/04/24.
//

import SwiftUI

struct ColorsForm: View {
    @State var path = NavigationPath()
    
    @AppStorage(key(.primaryColor)) var primaryColor: Color = .blue
    @AppStorage(key(.secondaryColor)) var secondaryColor: Color = .purple
    @AppStorage(key(.tertiaryColor)) var tertiaryColor: Color = .orange
    @AppStorage(key(.successColor)) var successColor: Color = .green
    @AppStorage(key(.warningColor)) var warningColor: Color = .yellow
    @AppStorage(key(.destructiveColor)) var destructiveColor: Color = .red
    @AppStorage(key(.backgroundColor)) var backgroundColor: Color = .gray
    @AppStorage(key(.foregroundColor)) var foregroundColor: Color = .gray
    
    var colorList: [ColorConfig] {[
        ColorConfig(hexColor: primaryColor.hexString, groupName: "Brand", colorName: "Primary"),
        ColorConfig(hexColor: secondaryColor.hexString, groupName: "Brand", colorName: "Secondary"),
        ColorConfig(hexColor: tertiaryColor.hexString, groupName: "Brand", colorName: "Tertiary"),
        ColorConfig(hexColor: successColor.hexString, groupName: "Semantic", colorName: "Success"),
        ColorConfig(hexColor: warningColor.hexString, groupName: "Semantic", colorName: "Warning"),
        ColorConfig(hexColor: destructiveColor.hexString, groupName: "Semantic", colorName: "Destructive"),
        ColorConfig(hexColor: backgroundColor.hexString, groupName: "Neutral", colorName: "Background"),
        ColorConfig(hexColor: foregroundColor.hexString, groupName: "Neutral", colorName: "Foreground", reversed: true)
    ]}
    
    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 0) {
                ScrollView {
                    VStack {
                        ColorPicker("Primary", selection: $primaryColor, supportsOpacity: false).rounded()
                        ColorPicker("Secondary", selection: $secondaryColor, supportsOpacity: false).rounded()
                        ColorPicker("Tertiary", selection: $tertiaryColor, supportsOpacity: false).rounded()
                        ColorPicker("Success", selection: $successColor, supportsOpacity: false).rounded()
                        ColorPicker("Warning", selection: $warningColor, supportsOpacity: false).rounded()
                        ColorPicker("Destructive", selection: $destructiveColor, supportsOpacity: false).rounded()
                        ColorPicker("Background", selection: $backgroundColor, supportsOpacity: false).rounded()
                        ColorPicker("Foreground", selection: $foregroundColor, supportsOpacity: false).rounded()
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                }
                Spacer(minLength: 0)
                Divider()
                Button {
                    path.append(colorList)
                } label: {
                    Text("Generate")
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
            .navigationTitle("Color Generator")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: [ColorConfig].self) { colorList in
                ColorPaletteView(colorList: colorList)
            }
        }
    }
}

#Preview {
    ColorsForm()
}
