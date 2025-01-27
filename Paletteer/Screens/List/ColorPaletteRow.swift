//
//  ColorPaletteRow.swift
//  Paletteer
//
//  Created by Oscar De Moya on 1/18/25.
//

import SwiftUI

struct ColorPaletteRow: View {
    @AppStorage(key(.colorPaletteParams)) var params = ColorPaletteParams()
    @Environment(\.modelContext) private var modelContext
    var colorPalette: ColorPalette
    @Binding var selectedPalette: ColorPalette?
    @State var isEditingName: Bool = false
    @State var name: String = ""
    @State var colors: [[Color]] = []
    
    var body: some View {
        VStack(alignment: .center) {
            if isEditingName {
                VStack {
                    TextField("Palette Name", text: $name)
                        .textFieldStyle(.plain)
                        .rounded(backgroundColor: .primaryInputBackground)
                    HStack {
                        cancelButton
                        saveNameButton
                    }
                }
                .padding(.vertical, 8)
            } else {
                HStack {
                    Spacer()
                    Text(colorPalette.name)
                        .font(.headline)
                        .foregroundColor(isSelected ? .primaryForeground : .secondaryForeground)
                    editNameButton
                    Spacer()
                }
            }
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
            name = colorPalette.name
            updateColors()
        }
        .onChange(of: colorPalette) { oldValue, newValue in
            if oldValue.configs != newValue.configs {
                updateColors()
            }
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
    
    @ViewBuilder var editNameButton: some View {
        Button {
            isEditingName = true
        } label: {
            Image(systemName: "pencil")
                .foregroundColor(.secondaryForeground)
        }
        .buttonStyle(
            .custom(
                backgroundColor: .primaryActionBackground.opacity(0.15),
                foregroundColor: .secondaryActionForeground,
                cornerRadius: 8,
                horizontalPadding: 8,
                verticalPadding: 8
            )
        )
    }
    
    @ViewBuilder var saveNameButton: some View {
        Button {
            colorPalette.name = name
            modelContext.insert(colorPalette)
            try? modelContext.save()
            isEditingName = false
        } label: {
            Text("Save")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(
            .custom(
                backgroundColor: .primaryActionBackground,
                foregroundColor: .primaryActionForeground
            )
        )
    }
    
    @ViewBuilder var cancelButton: some View {
        Button {
            isEditingName = false
        } label: {
            Text("Cancel")
                .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity)
        .buttonStyle(
            .custom(
                backgroundColor: .secondaryActionBackground,
                foregroundColor: .secondaryActionForeground,
                cornerRadius: 16
            )
        )
    }
}

#Preview {
    @Previewable @State var colorPalette = ColorPalette()
    @Previewable @State var selectedPalette: ColorPalette? = nil
    ColorPaletteRow(colorPalette: colorPalette, selectedPalette: $selectedPalette)
}
