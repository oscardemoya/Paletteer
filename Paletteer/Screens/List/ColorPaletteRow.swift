//
//  ColorPaletteRow.swift
//  Paletteer
//
//  Created by Oscar De Moya on 1/18/25.
//

import SwiftUI

struct ColorPaletteRow: View {
    var colorPalette: ColorPalette
    
    @AppStorage(key(.colorPaletteParams)) var params = ColorPaletteParams()
    
    @State var colors: [[Color]] = []
    
    var body: some View {
        VStack(alignment: .center) {
            Text(colorPalette.name)
            ZStack {
                ColorWheelView(colors: colors)
                if colorPalette.configs.isEmpty {
                    Text("Empty")
                        .foregroundStyle(.secondaryForeground)
                }
            }
        }
        .onAppear {
            updateColors()
        }
        .onChange(of: colorPalette) { _, newValue in
            updateColors()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(8)
        .contentShape(.rect)
    }
    
    func updateColors() {
        colorPalette.updateConfigs()
        colors = colorPalette.colorWheel(for: .light, with: params)
    }
}

#Preview {
    @Previewable var colorPalette = ColorPalette()
    ColorPaletteRow(colorPalette: colorPalette)
}
