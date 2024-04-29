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
        ColorConfig(hexColor: primaryColor.hexRGB, groupName: "Brand", colorName: "Primary"),
        ColorConfig(hexColor: secondaryColor.hexRGB, groupName: "Brand", colorName: "Secondary"),
        ColorConfig(hexColor: tertiaryColor.hexRGB, groupName: "Brand", colorName: "Tertiary"),
        ColorConfig(hexColor: successColor.hexRGB, groupName: "Semantic", colorName: "Success"),
        ColorConfig(hexColor: warningColor.hexRGB, groupName: "Semantic", colorName: "Warning"),
        ColorConfig(hexColor: destructiveColor.hexRGB, groupName: "Semantic", colorName: "Destructive"),
        ColorConfig(hexColor: backgroundColor.hexRGB, groupName: "Neutral", colorName: "Background"),
        ColorConfig(hexColor: foregroundColor.hexRGB, groupName: "Neutral", colorName: "Foreground", reversed: true)
    ]}
    
    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 0) {
                ScrollView {
                    VStack {
                        HCTColorPicker(title: "Primary", color: $primaryColor).rounded()
                        HCTColorPicker(title: "Secondary", color: $secondaryColor).rounded()
                        HCTColorPicker(title: "Tertiary", color: $tertiaryColor).rounded()
                        HCTColorPicker(title: "Success", color: $successColor).rounded()
                        HCTColorPicker(title: "Warning", color: $warningColor).rounded()
                        HCTColorPicker(title: "Destructive", color: $destructiveColor).rounded()
                        HCTColorPicker(title: "Background", color: $backgroundColor).rounded()
                        HCTColorPicker(title: "Foreground", color: $foregroundColor).rounded()
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
