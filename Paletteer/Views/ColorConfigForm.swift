//
//  ColorConfigForm.swift
//  Paletteer
//
//  Created by Oscar De Moya on 1/06/24.
//

import SwiftUI

struct ColorConfigForm: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Binding var colorPalette: ColorPalette?
    @Binding var colorConfig: ColorConfig
    @Binding var colorClipboard: ColorClipboard
    var isEditing: Bool
    var onSave: Action
    
    @State private var lightRangeWidth: ColorRangeWidth = .whole
    @State private var darkRangeWidth: ColorRangeWidth = .whole
    @State private var sheetHeight: CGFloat = .zero
    @State private var closeButtonSize: CGSize = .zero
    
    var body: some View {
        colorConfigForm
            .background(.secondaryBackground)
            .onAppear {
                lightRangeWidth = colorConfig.lightConfig.range.width
                darkRangeWidth = colorConfig.darkConfig.range.width
            }
    }
    
    @ViewBuilder
    var colorConfigForm: some View {
#if os(macOS) || targetEnvironment(macCatalyst)
        colorConfigFormContent
            .fixedSize()
#else
        ScrollView {
            colorConfigFormContent
                .readSize { size in
                    sheetHeight = size.height
                }
                .presentationDetents([.height(sheetHeight)])
                .presentationDragIndicator(.hidden)
        }
#endif
    }
    
    @ViewBuilder
    var colorConfigFormContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center) {
                Spacer()
                    .frame(width: closeButtonSize.width, height: closeButtonSize.height)
                Spacer()
                Text(colorConfig.colorName.isEmpty ? "Color Name" : colorConfig.colorName)
                    .font(.title3)
                    .fontWeight(.bold)
                    .fontDesign(.rounded)
                    .foregroundStyle(colorConfig.colorName.isEmpty ? .foreground700 : .foreground300)
                Spacer()
                CircularButton(size: .large) {
                    dismiss()
                }
                .readSize { size in
                    closeButtonSize = size
                }
            }
            Divider()
            VStack(spacing: 12) {
                CustomColorPicker(colorConfig: $colorConfig, colorClipboard: $colorClipboard, isEditing: true)
                    .buttonStyle(.custom(backgroundColor: .secondaryInputBackground,
                                         foregroundColor: .secondaryActionForeground))
                TextField("Group Name (Optional)", text: $colorConfig.groupName)
                    .textFieldStyle(.plain)
                    .rounded(backgroundColor: .secondaryInputBackground)
                Group {
                    VStack {
                        Text("Light")
                        Grid {
                            GridRow {
                                Text("Color Scale")
                                    .padding(.horizontal, 4)
                                    .gridColumnAlignment(.leading)
                                Picker("", selection: $colorConfig.lightConfig.scale) {
                                    ForEach(ColorScale.allCases) { item in
                                        Text(item.name).tag(item)
                                    }
                                }
                                .gridCellColumns(2)
                            }
                            GridRow {
                                Text("Color Range")
                                    .padding(.horizontal, 4)
                                    .gridColumnAlignment(.leading)
                                Picker("", selection: $lightRangeWidth.onChange({ colorConfig.lightConfig.range = $0.defaultRange })) {
                                    ForEach(ColorRangeWidth.allCases) { item in
                                        Text(item.name).tag(item)
                                    }
                                }
                                Picker("", selection: $colorConfig.lightConfig.range) {
                                    ForEach(lightRangeWidth.ranges) { item in
                                        Text(item.name).tag(item)
                                    }
                                }
                            }
                            GridRow {
                                Text("Saturation")
                                    .padding(.horizontal, 4)
                                    .gridColumnAlignment(.leading)
                                Picker("", selection: $colorConfig.lightConfig.saturationLevel) {
                                    ForEach(ColorAdjustmentLevel.allCases) { item in
                                        Text(item.name).tag(item)
                                    }
                                }
                                .gridCellColumns(2)
                            }
                            GridRow {
                                Text("Brightness")
                                    .padding(.horizontal, 4)
                                    .gridColumnAlignment(.leading)
                                Picker("", selection: $colorConfig.lightConfig.brightnessLevel) {
                                    ForEach(ColorAdjustmentLevel.allCases) { item in
                                        Text(item.name).tag(item)
                                    }
                                }
                                .gridCellColumns(2)
                            }
                            GridRow {
                                Text("Skip Direction")
                                Picker("", selection: $colorConfig.lightConfig.skipDirection) {
                                    ForEach(SkipDirection.allCases) { item in
                                        Text(item.name).tag(item)
                                    }
                                }
                                .gridCellColumns(2)
                            }
                        }
                    }
                    VStack {
                        Text("Dark")
                        Grid {
                            GridRow {
                                Text("Color Scale")
                                    .padding(.horizontal, 4)
                                    .gridColumnAlignment(.leading)
                                Picker("", selection: $colorConfig.darkConfig.scale) {
                                    ForEach(ColorScale.allCases) { item in
                                        Text(item.name).tag(item)
                                    }
                                }
                                .gridCellColumns(2)
                            }
                            GridRow {
                                Text("Color Range")
                                    .padding(.horizontal, 4)
                                    .gridColumnAlignment(.leading)
                                Picker("", selection: $darkRangeWidth.onChange({ colorConfig.darkConfig.range = $0.defaultRange })) {
                                    ForEach(ColorRangeWidth.allCases) { item in
                                        Text(item.name).tag(item)
                                    }
                                }
                                Picker("", selection: $colorConfig.darkConfig.range) {
                                    ForEach(darkRangeWidth.ranges) { item in
                                        Text(item.name).tag(item)
                                    }
                                }
                            }
                            GridRow {
                                Text("Saturation")
                                    .padding(.horizontal, 4)
                                    .gridColumnAlignment(.leading)
                                Picker("", selection: $colorConfig.darkConfig.saturationLevel) {
                                    ForEach(ColorAdjustmentLevel.allCases) { item in
                                        Text(item.name).tag(item)
                                    }
                                }
                                .gridCellColumns(2)
                            }
                            GridRow {
                                Text("Brightness")
                                    .padding(.horizontal, 4)
                                    .gridColumnAlignment(.leading)
                                Picker("", selection: $colorConfig.darkConfig.brightnessLevel) {
                                    ForEach(ColorAdjustmentLevel.allCases) { item in
                                        Text(item.name).tag(item)
                                    }
                                }
                                .gridCellColumns(2)
                            }
                            GridRow {
                                Text("Skip Direction")
                                Picker("", selection: $colorConfig.darkConfig.skipDirection) {
                                    ForEach(SkipDirection.allCases) { item in
                                        Text(item.name).tag(item)
                                    }
                                }
                                .gridCellColumns(2)
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .foregroundColor(.foreground050)
                .rounded(backgroundColor: .secondaryInputBackground, padding: 12)
                Button {
                    dismiss()
                    if let colorPalette {
                        var configs = colorPalette.configs
                        if !isEditing {
                            configs.append(colorConfig)
                        } else if let index = colorPalette.configs.firstIndex(where: { $0.id == colorConfig.id }) {
                            configs[index].update(with: colorConfig)
                        }
                        colorPalette.setConfigs(configs)
                        modelContext.insert(colorPalette)
                        try? modelContext.save()
                    }
                    onSave()
                } label: {
                    Text(isEditing ? "Save Changes" : "Add Color")
                        .font(.title3)
                        .fontWeight(.medium)
                        .fontDesign(.rounded)
                        .frame(maxWidth: .infinity)
                }
                .disabled(colorConfig.colorName.isEmpty)
                .buttonStyle(.custom(backgroundColor: .primaryActionBackground.opacity(colorConfig.colorName.isEmpty ? 0.25 : 1),
                                     foregroundColor: .primaryActionForeground,
                                     cornerRadius: 16))
            }
            .frame(minWidth: 300)
            .padding(12)
        }
    }
}

#Preview {
    @Previewable @State var colorPalette: ColorPalette? = ColorPalette.makeSample()
    @Previewable @State var newColor = ColorConfig(colorModel: .rgb(.blue.muted), colorName: "")
    @Previewable @State var colorClipboard = ColorClipboard()
    ColorConfigForm(colorPalette: $colorPalette, colorConfig: $newColor, colorClipboard: $colorClipboard, isEditing: true) {}
}
