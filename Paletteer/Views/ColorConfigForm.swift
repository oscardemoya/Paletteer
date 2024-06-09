//
//  ColorConfigForm.swift
//  Paletteer
//
//  Created by Oscar De Moya on 1/06/24.
//

import SwiftUI

struct ColorConfigForm: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage(key(.colorPalette)) var colorPalette = [ColorConfig]()
    @Binding var colorConfig: ColorConfig
    @Binding var colorClipboard: ColorClipboard
    var isEditing: Bool
    @State private var colorRangeWidth: ColorRangeWidth = .whole
    @State private var sheetHeight: CGFloat = .zero
    @State private var closeButtonSize: CGSize = .zero
    
    var body: some View {
        colorConfigForm
            .background(.secondaryBackground)
            .onAppear {
                colorRangeWidth = colorConfig.colorRange.width
            }
    }
    
    @ViewBuilder
    var colorConfigForm: some View {
#if os(macOS)
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
                    HStack {
                        Text("Light Color Scale")
                            .padding(.horizontal, 4)
                        Spacer()
                        Picker("", selection: $colorConfig.lightColorScale) {
                            ForEach(ColorScale.allCases, id: \.self) { item in
                                Text(item.name).tag(item)
                            }
                        }
                    }
                    .frame(height: 30)
                    HStack {
                        Text("Dark Color Scale")
                            .padding(.horizontal, 4)
                        Spacer()
                        Picker("", selection: $colorConfig.darkColorScale) {
                            ForEach(ColorScale.allCases, id: \.self) { item in
                                Text(item.name).tag(item)
                            }
                        }
                    }
                    .frame(height: 30)
                    HStack {
                        Text("Color Range Width")
                            .padding(.horizontal, 4)
                        Spacer()
                        Picker("", selection: $colorRangeWidth.onChange({ colorConfig.colorRange = $0.defaultRange })) {
                            ForEach(ColorRangeWidth.allCases, id: \.self) { item in
                                Text(item.name).tag(item)
                            }
                        }
                    }
                    .frame(height: 30)
                    HStack {
                        Text("Color Range")
                            .padding(.horizontal, 4)
                        Spacer()
                        Picker("", selection: $colorConfig.colorRange) {
                            ForEach(colorRangeWidth.ranges, id: \.self) { item in
                                Text(item.name).tag(item)
                            }
                        }
                    }
                    .frame(height: 30)
                }
                .frame(maxWidth: .infinity)
                .foregroundColor(.foreground010)
                .rounded(backgroundColor: .secondaryInputBackground, padding: 12)
                Button {
                    dismiss()
                    if !isEditing {
                        colorPalette.append(colorConfig)
                    } else if let index = colorPalette.firstIndex(where: { $0.id == colorConfig.id }) {
                        colorPalette[index].update(with: colorConfig)
                    }
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
    @State var newColor = ColorConfig(colorModel: .rgb(.blue.muted), colorName: "")
    @State var colorClipboard = ColorClipboard()
    return ColorConfigForm(colorConfig: $newColor, colorClipboard: $colorClipboard, isEditing: true)
}
