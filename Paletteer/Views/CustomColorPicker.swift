//
//  CustomColorPicker.swift
//  Paletteer
//
//  Created by Oscar De Moya on 28/04/24.
//

import SwiftUI

struct CustomColorPicker: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage(key(.colorPalette)) var colorPalette = [ColorConfig]()
    @AppStorage(key(.showCopyIcons)) var showCopyIcons: Bool = true
    @Binding var colorConfig: ColorConfig
    @Binding var colorClipboard: ColorClipboard
    var isEditing: Bool
    var onDelete: Action?
    var onEdit: Action?
    @State private var recentColors: [Color] = []
    @State private var isEditingColor = false
    @State private var sheetHeight: CGFloat = .zero
    @State private var colorSpace: ColorSpace = .hct
    @State private var hueSliderValue = Self.hueRange.median
    @State private var chromaOrSaturationSliderValue = Self.chromaOrSaturationRange.median
    @State private var toneOrBrightnessSliderValue = Self.toneOrBrightnessRange.median
    @State private var closeButtonSize: CGSize = .zero
    @State private var showDeleteConfirmation: Bool = false
    
    static let hueRange: ClosedRange<Double> = 0...360
    static let chromaOrSaturationRange: ClosedRange<Double> = 0...120
    static let toneOrBrightnessRange: ClosedRange<Double> = 0...100
    
    let gridItems = [GridItem(.fixed(40))]
    
    var body: some View {
        Button { if !colorConfig.colorName.isEmpty { isEditingColor = true } } label: {
            HStack {
                VStack(spacing: 0) {
                    if isEditing {
                        TextField("Color Name", text: $colorConfig.colorName)
                            .textFieldStyle(.plain)
                    } else {
                        if !colorConfig.groupName.isEmpty {
                            Text(colorConfig.groupName)
                                .font(.subheadline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(.foreground500)
                        }
                        Text(colorConfig.colorName)
                            .foregroundColor(.foreground300)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .frame(maxWidth: .infinity)
                HStack(spacing: 8) {
                    Group {
                        if colorConfig.lightColorScale.isLightening {
                            Image(systemName: "square.2.layers.3d.fill")
                                .symbolRenderingMode(.palette)
                                .foregroundStyle(.foreground950, .foreground850)
                                .rounded(backgroundColor: .foreground800, padding: 6, cornerRadius: 8)
                        }
                        if colorConfig.darkColorScale.isDarkening {
                            Image(systemName: "square.2.layers.3d.fill")
                                .symbolRenderingMode(.palette)
                                .foregroundStyle(.foreground200, .foreground400)
                                .rounded(backgroundColor: .foreground500, padding: 6, cornerRadius: 8)
                        }
                        if colorConfig.narrow {
                            Image(systemName: "arrow.down.right.and.arrow.up.left")
                                .foregroundColor(.primaryInputBackground)
                                .rounded(backgroundColor: .foreground700, padding: 6, cornerRadius: 8)
                        }
                    }
                    .font(.body)
                }
                ZStack {
                    borderedRect(color: colorConfig.color)
                        .frame(width: 36, height: 36)
                        .onTapGesture {
                            isEditingColor = true
                        }
                }
            }
            .onTapGesture {
                if !colorConfig.colorName.isEmpty {
                    isEditingColor = true
                }
            }
            .onLongPressGesture {
                onEdit?()
            }
        }
        .sheet(isPresented: $isEditingColor) {
            colorPicker
        }
    }
    
    @ViewBuilder
    var colorPicker: some View {
        wrappedColorPicker
            .onAppear(perform: setColorValues)
            .onChange(of: isEditingColor) {
                if isEditingColor {
                    setColorValues()
                }
            }
            .onChange(of: colorSpace, setColorValues)
            .onChange(of: hueSliderValue, updateColor)
            .onChange(of: chromaOrSaturationSliderValue, updateColor)
            .onChange(of: toneOrBrightnessSliderValue, updateColor)
    }
    
    @ViewBuilder
    var wrappedColorPicker: some View {
#if os(macOS)
        colorPickerContent
            .fixedSize()
#else
        ScrollView {
            colorPickerContent
                .readSize { size in
                    sheetHeight = size.height
                }
                .presentationDetents([.height(sheetHeight)])
                .presentationDragIndicator(.hidden)
        }
#endif
    }
    
    @ViewBuilder
    var colorPickerContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center) {
                if onDelete != nil {
                    CircularButton(size: .large, systemName: "trash.circle.fill") {
                        showDeleteConfirmation = true
                    }
                } else {
                    Spacer()
                        .frame(width: closeButtonSize.width, height: closeButtonSize.height)
                }
                Spacer()
                Picker("", selection: $colorSpace) {
                    ForEach(ColorSpace.allCases) {
                        Text($0.title)
                    }
                }
                .pickerStyle(.segmented)
                .fixedSize()
                Spacer()
                CircularButton(size: .large) {
                    isEditingColor = false
                }
                .readSize { size in
                    closeButtonSize = size
                }
            }
            Divider()
            VStack(spacing: 16) {
                selectedColorView
                switch colorSpace {
                case .hct, .hsb:
                    hctSliders
                case .rgb:
                    ColorPicker(colorConfig.colorName, selection: $colorConfig.color, supportsOpacity: false)
                        .frame(maxWidth: .infinity)
                        .rounded()
                }
            }
            .padding(12)
            Divider()
            colorWheel
            if !colorClipboard.colors.isEmpty {
                colorClipoardGrid
            }
        }
        .confirmationDialog("Delete Color?", isPresented: $showDeleteConfirmation, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                DispatchQueue.main.async {
                    dismiss()
                    onDelete?()
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This action cannot be undone.")
        }
    }
    
    @ViewBuilder
    var pasteboardLookupButton: some View {
        pasteboardColor(color: .foreground900, icon: Image(systemName: "square.on.square.dashed"))
            .onTapGesture {
                colorClipboard.text = String.pasteboardString
            }
    }
    
    @ViewBuilder
    func pasteColorButton(color: Color, size: CGFloat = 32) -> some View {
        pasteboardColor(color: color, size: size)
            .onTapGesture {
                colorConfig.color = color
                setColorValues()
            }
    }
    
    @ViewBuilder
    func pasteboardColor(color: Color, icon: Image = Image(systemName: "doc.on.clipboard"), size: CGFloat = 32) -> some View {
        ZStack {
            rectangle(color: color)
            icon
                .resizable()
                .scaledToFit()
                .padding(size / 4)
                .symbolRenderingMode(.hierarchical)
                .foregroundColor(color.contrastingColor)
                
        }
        .frame(width: size, height: size)
    }
    
    var colorWheelColors: [Color] {
        guard let hct = colorConfig.color.hct else { return [] }
        return TemperatureCache(hct)
            .analogous(count: 12)
            .sorted(by: { $0.hue < $1.hue })
            .map { Color(hctColor: $0) }
    }
    
    func setColorValues() {
        switch colorSpace {
        case .hct:
            setHCTValues()
        case .hsb:
            setHSBValues()
        case .rgb:
            break
        }
    }
    
    func setHCTValues() {
        guard let hct = colorConfig.color.hct else {
            print("Error converting color to HCT.")
            return
        }
        withAnimation {
            hueSliderValue = hct.hue
            chromaOrSaturationSliderValue = hct.chroma
            toneOrBrightnessSliderValue = hct.tone
        }
    }
    
    func setHSBValues() {
        guard let hsba = colorConfig.color.hsba else {
            print("Error converting color to HSB.")
            return
        }
        withAnimation {
            hueSliderValue = hsba.hue * 360
            chromaOrSaturationSliderValue = hsba.saturation * 100
            toneOrBrightnessSliderValue = hsba.brightness * 100
        }
    }
    
    func updateColor() {
        switch colorSpace {
        case .hct:
            let hctColor = Hct.from(hueSliderValue, chromaOrSaturationSliderValue, toneOrBrightnessSliderValue)
            colorConfig.color = Color(hctColor: hctColor)
        case .hsb:
            let hue = hueSliderValue / 360
            let saturation = chromaOrSaturationSliderValue / 100
            let brightness = toneOrBrightnessSliderValue / 100
            colorConfig.color = Color(hue: hue, saturation: saturation, brightness: brightness)
        case .rgb:
            break
        }
        
    }
    
    @ViewBuilder
    var selectedColorView: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 8) {
                VStack(spacing: 0) {
                    if !colorConfig.groupName.isEmpty {
                        Text(colorConfig.groupName)
                            .font(.subheadline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundColor(.foreground500)
                    }
                    Text(colorConfig.colorName)
                        .font(.title3)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(.foreground300)
                }
                HStack(spacing: 12) {
                    rectangle(color: colorConfig.color)
                        .frame(width: 60, height: 60)
                    colorValues
                }
            }
            Spacer()
            colorFromTextClipboardView
        }
    }
    
    @ViewBuilder
    var colorFromTextClipboardView: some View {
        VStack(spacing: 0) {
            Group {
                if let text = colorClipboard.text, let color = text.color {
                    pasteColorButton(color: color)
                        .onLongPressGesture {
                            colorClipboard.text = nil
                        }
                } else {
                    pasteboardLookupButton
                }
            }
            .padding(.bottom, 4)
            Text("Clipboard")
                .textCase(.uppercase)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.foreground500)
            if let text = colorClipboard.text, text.color != nil {
                Text(text)
                    .font(.caption2)
                    .foregroundColor(.foreground700)
            }
        }
        .padding(12)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(
                    style: .init(
                        lineWidth: 2,
                        dash: [5, 3]
                    )
                )
                .foregroundColor(.foreground900)
        )
    }
    
    @ViewBuilder
    var hctSliders: some View {
        Grid(alignment: .leading) {
            hctSlider("Hue",
                      sliderValue: $hueSliderValue, in: Self.hueRange)
            hctSlider(colorSpace == .hct ? "Chroma" : "Saturation",
                      sliderValue: $chromaOrSaturationSliderValue, in: Self.chromaOrSaturationRange)
            hctSlider(colorSpace == .hct ? "Tone" : "Brightness",
                      sliderValue: $toneOrBrightnessSliderValue, in: Self.toneOrBrightnessRange)
        }
    }
    
    @ViewBuilder
    func hctSlider(_ titleKey: LocalizedStringKey,
                   sliderValue: Binding<Double>, in range: ClosedRange<Double>) -> some View {
        GridRow {
            Text(titleKey).frame(alignment: .leading)
            Slider(value: sliderValue, in: range)
            HStack {
                Spacer(minLength: 0)
                Stepper("\(Int(sliderValue.wrappedValue))", value: sliderValue, in: range)
                    .fixedSize()
            }
            .gridColumnAlignment(.trailing)
        }
    }
    
    @ViewBuilder
    var colorWheel: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Hues")
                    .textCase(.uppercase)
                    .font(.caption)
                    .fontWeight(.bold)
                Spacer()
                Button {
                    colorClipboard.replace(with: colorWheelColors.reversed())
                } label: {
                    HStack(alignment: .center) {
                        Text("Copy All")
                            .textCase(.uppercase)
                            .font(.caption)
                        if showCopyIcons {
                            Image(systemName: "square.on.square")
                                .symbolRenderingMode(.hierarchical)
                        }
                    }
                    .padding(2)
                }
            }
            .padding([.top, .horizontal], 12)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    LazyHGrid(rows: gridItems, spacing: 4)  {
                        ForEach(colorWheelColors, id: \.self) { color in
                            ZStack {
                                rectangle(color: color)
                                if showCopyIcons {
                                    Image(systemName: "square.on.square")
                                        .symbolRenderingMode(.hierarchical)
                                        .foregroundColor(color.contrastingColor)
                                }
                            }
                            .aspectRatio(1, contentMode: .fill)
                            .onTapGesture {
                                withAnimation {
                                    colorClipboard.add(color)
                                }
                            }
                        }
                    }
                }
                .fixedSize(horizontal: false, vertical: true)
            }
            .contentMargins(12)
        }
    }
    
    func rectangle(color: Color) -> some View {
        Rectangle()
            .fill(color)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
    
    func borderedRect(color: Color, strokeColor: Color = .clear) -> some View {
        rectangle(color: color)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(.primaryBackground, lineWidth: 2)
            )
    }
    
    @ViewBuilder
    var colorValues: some View {
        VStack(alignment: .leading) {
            colorValue("RGB", value: colorConfig.color.hexRGB)
            colorValue("HCT", value: colorConfig.color.hct?.label ?? "")
        }
    }
    
    @ViewBuilder
    func colorValue(_ titleKey: LocalizedStringKey, value: String) -> some View {
        HStack(spacing: 4) {
            Text(titleKey)
                .fontWeight(.bold)
            Button {
                colorClipboard.text = value.uppercased()
            } label: {
                HStack {
                    Text(value)
                        .textCase(.uppercase)
                    if showCopyIcons {
                        Image(systemName: "square.on.square")
                            .symbolRenderingMode(.hierarchical)
                    }
                }
                .padding(2)
            }
        }
    }
    
    @ViewBuilder
    var colorClipoardGrid: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Recent")
                    .textCase(.uppercase)
                    .font(.caption)
                    .fontWeight(.bold)
                Spacer()
                Button {
                    withAnimation {
                        colorClipboard.removeAll()
                    }
                } label: {
                    HStack(alignment: .center) {
                        Text("Clear")
                            .textCase(.uppercase)
                            .font(.caption)
                        if showCopyIcons {
                            Image(systemName: "trash")
                                .symbolRenderingMode(.hierarchical)
                        }
                    }
                    .padding(2)
                }
            }
            .padding([.top, .horizontal], 12)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    LazyHGrid(rows: gridItems, spacing: 4) {
                        ForEach(colorClipboard.colors.reversed(), id: \.self) { color in
                            pasteColorButton(color: color, size: 40)
                                .onLongPressGesture {
                                    withAnimation {
                                        colorClipboard.remove(color)
                                    }
                                }
                        }
                    }
                }
                .fixedSize(horizontal: false, vertical: true)
            }
            .contentMargins(12)
        }
    }
}

#Preview {
    @State var colorConfig = ColorConfig(color: .blue, groupName: "Brand", colorName: "Primary")
    @State var colorClipboard = ColorClipboard()
    return CustomColorPicker(colorConfig: $colorConfig, colorClipboard: $colorClipboard, isEditing: false) {} onEdit: {}
}
