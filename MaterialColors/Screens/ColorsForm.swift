//
//  ColorsForm.swift
//  MaterialColors
//
//  Created by Oscar De Moya on 22/04/24.
//

import SwiftUI

struct ColorsForm: View {
    @State var path = NavigationPath()
    
    @AppStorage(key(.primaryColor)) var primaryColor: String = ""
    @AppStorage(key(.secondaryColor)) var secondaryColor: String = ""
    @AppStorage(key(.tertiaryColor)) var tertiaryColor: String = ""
    @AppStorage(key(.successColor)) var successColor: String = ""
    @AppStorage(key(.warningColor)) var warningColor: String = ""
    @AppStorage(key(.destructiveColor)) var destructiveColor: String = ""
    @AppStorage(key(.backgroundColor)) var backgroundColor: String = ""
    @AppStorage(key(.foregroundColor)) var foregroundColor: String = ""
    
    var colorList: [ColorConfig] {[
        ColorConfig(hexColor: primaryColor, groupName: "Brand", colorName: "Primary"),
        ColorConfig(hexColor: secondaryColor, groupName: "Brand", colorName: "Secondary"),
        ColorConfig(hexColor: tertiaryColor, groupName: "Brand", colorName: "Tertiary"),
        ColorConfig(hexColor: successColor, groupName: "Semantic", colorName: "Success"),
        ColorConfig(hexColor: warningColor, groupName: "Semantic", colorName: "Warning"),
        ColorConfig(hexColor: destructiveColor, groupName: "Semantic", colorName: "Destructive"),
        ColorConfig(hexColor: backgroundColor, groupName: "Neutral", colorName: "Background"),
        ColorConfig(hexColor: foregroundColor, groupName: "Neutral", colorName: "Foreground", reversed: true)
    ]}
    
    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 0) {
                ScrollView {
                    VStack {
                        TextField("Primary", text: $primaryColor).rounded()
                        TextField("Secondary", text: $secondaryColor).rounded()
                        TextField("Tertiary", text: $tertiaryColor).rounded()
                        TextField("Success", text: $successColor).rounded()
                        TextField("Warning", text: $warningColor).rounded()
                        TextField("Destructive", text: $destructiveColor).rounded()
                        TextField("Background", text: $backgroundColor).rounded()
                        TextField("Foreground", text: $foregroundColor).rounded()
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
