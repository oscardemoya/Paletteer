//
//  ColorPaletteRow.swift
//  Paletteer
//
//  Created by Oscar De Moya on 1/18/25.
//

import SwiftUI

struct ColorPaletteRow: View {
    @AppStorage(key(.colorPaletteParams)) var params = ColorPaletteParams()
    
    var colorPalette: ColorPalette
    @Binding var selectedPalette: ColorPalette?
    @State var colors: [[Color]] = []
    
    var body: some View {
        VStack(alignment: .center) {
            Text(colorPalette.name)
                .foregroundColor(isSelected ? .primaryForeground : .secondaryForeground)
            ZStack {
                ColorWheelView(colors: colors)
                if colorPalette.configs.isEmpty {
                    Text("Empty")
                        .foregroundStyle(.secondaryForeground)
                }
            }
        }
#if os(macOS) || targetEnvironment(macCatalyst)
        .padding(8)
        .background(
            Group {
                isSelected ? Color.primaryInputBackground : Color.clear
            }
            .cornerRadius(12, antialiased: true)
        )
#else
        .padding(24)
#endif
        .onAppear {
            updateColors()
        }
        .onChange(of: colorPalette.configs) { _, newValue in
            updateColors()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(.rect)
    }
    
    var isSelected: Bool {
        colorPalette.id == selectedPalette?.id
    }
    
    func updateColors() {
        colorPalette.updateConfigs()
        colors = colorPalette.colorWheel(for: .light, with: params)
    }
}

#Preview {
    @Previewable @State var colorPalette = ColorPalette()
    @Previewable @State var selectedPalette: ColorPalette? = nil
    ColorPaletteRow(colorPalette: colorPalette, selectedPalette: $selectedPalette)
}
