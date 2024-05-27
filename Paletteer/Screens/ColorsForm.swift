//
//  ColorsForm.swift
//  Paletteer
//
//  Created by Oscar De Moya on 22/04/24.
//

import SwiftUI

struct ColorsForm: View {
    @State var path = NavigationPath()
    
    @AppStorage(key(.colorScheme)) var selectedAppearance: AppColorScheme = .system
    @AppStorage(key(.primaryColor)) var primaryColor: Color = .blue
    @AppStorage(key(.secondaryColor)) var secondaryColor: Color = .purple
    @AppStorage(key(.tertiaryColor)) var tertiaryColor: Color = .orange
    @AppStorage(key(.successColor)) var successColor: Color = .green
    @AppStorage(key(.warningColor)) var warningColor: Color = .yellow
    @AppStorage(key(.destructiveColor)) var destructiveColor: Color = .red
    @AppStorage(key(.backgroundColor)) var backgroundColor: Color = .gray
    @AppStorage(key(.foregroundColor)) var foregroundColor: Color = .gray
    var columns = [GridItem(.adaptive(minimum: 200), spacing: 12)]
    
    var colorList: [ColorGroup] {[
        ColorGroup(color: primaryColor, groupName: "Brand", colorName: "Primary"),
        ColorGroup(color: secondaryColor, groupName: "Brand", colorName: "Secondary"),
        ColorGroup(color: tertiaryColor, groupName: "Brand", colorName: "Tertiary"),
        ColorGroup(color: successColor, groupName: "Semantic", colorName: "Success"),
        ColorGroup(color: warningColor, groupName: "Semantic", colorName: "Warning"),
        ColorGroup(color: destructiveColor, groupName: "Semantic", colorName: "Danger"),
        ColorGroup(color: backgroundColor, groupName: "Neutral", colorName: "Background", narrow: true),
        ColorGroup(color: foregroundColor, groupName: "Neutral", colorName: "Foreground", reversed: true)
    ]}
    
    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 0) {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 8) {
                        CustomColorPicker(title: "Primary", selectedColor: $primaryColor)
                        CustomColorPicker(title: "Secondary", selectedColor: $secondaryColor)
                        CustomColorPicker(title: "Tertiary", selectedColor: $tertiaryColor)
                        CustomColorPicker(title: "Success", selectedColor: $successColor)
                        CustomColorPicker(title: "Warning", selectedColor: $warningColor)
                        CustomColorPicker(title: "Danger", selectedColor: $destructiveColor)
                        CustomColorPicker(title: "Background", selectedColor: $backgroundColor)
                        CustomColorPicker(title: "Foreground", selectedColor: $foregroundColor)
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
                        .font(.title3)
                        .fontWeight(.medium)
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.primaryActionForeground)
                }
                .buttonStyle(.custom(backgroundColor: .primaryActionBackground, cornerRadius: 16))
                .padding()
            }
            .navigationTitle("Paletteer")
#if !os(macOS)
            .navigationBarTitleDisplayMode(.inline)
#endif
            .navigationDestination(for: [ColorGroup].self) { colorList in
                ColorPaletteView(colorList: colorList)
            }
            .background(.primaryBackground)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        selectedAppearance.toggle()
                        ColorSchemeSwitcher.shared.overrideDisplayMode()
                    } label: {
                        Image(systemName: selectedAppearance.iconName)
                    }
                }
#if !os(macOS)
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        
                    } label: {
                        Image(systemName: "gear")
                    }
                }
#endif
            }
        }
        .onAppear {
            ColorSchemeSwitcher.shared.overrideDisplayMode()
        }
    }
}

#Preview {
    ColorsForm()
}
