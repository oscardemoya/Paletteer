//
//  CustomColorPicker.swift
//  Paletteer
//
//  Created by Oscar De Moya on 28/04/24.
//

import SwiftUI

struct CustomColorPicker: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage(key(.showCopyIcons)) var showCopyIcons: Bool = true
    @Binding var colorConfig: ColorConfig
    @Binding var colorClipboard: ColorClipboard
    var isEditing: Bool
    var onDelete: Action?
    var onEdit: Action?
    @State private var selectedColor: Color = .blue
    @State private var recentColors: [Color] = []
    @State private var isEditingColor = false
    @State private var sheetHeight: CGFloat = .zero
    @State private var colorSpace: ColorSpace = .hct
    @State private var hueSliderValue = Self.hueRange.median
    @State private var chromaOrSaturationSliderValue = Self.chromaOrSaturationRange.median
    @State private var toneOrBrightnessSliderValue = Self.toneOrBrightnessRange.median
    @State private var closeButtonSize: CGSize = .zero
    @State private var showDeleteConfirmation: Bool = false
    @State private var colorRangeWidth: ColorRangeWidth = .full
    
    static let hueRange: ClosedRange<Double> = 0...360
    static let chromaOrSaturationRange: ClosedRange<Double> = 0...120
    static let toneOrBrightnessRange: ClosedRange<Double> = 0...100
    
    let gridItems = [GridItem(.fixed(40))]
    
    var body: some View {
        Button { if !colorConfig.colorName.isEmpty { isEditingColor = true } } label: {
            HStack(spacing: 8) {
                VStack(spacing: 0) {
                    if isEditing {
                        TextField("Color Name", text: $colorConfig.colorName)
                            .textFieldStyle(.plain)
                    } else {
                        if !colorConfig.groupName.isEmpty {
                            Text(colorConfig.groupName)
                                .font(.subheadline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(.foreground300)
                        }
                        Text(colorConfig.colorName)
                            .font(.headline)
                            .fontWeight(.medium)
                            .foregroundColor(.foreground100)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .frame(maxWidth: .infinity)
                HStack(spacing: 8) {
                    if colorConfig.lightColorScale.isLightening {
                        Image(systemName: "square.2.layers.3d.fill")
                            .font(.title3)
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(.background950, .background800)
                            .rounded(backgroundColor: .background500, padding: 4, cornerRadius: 8)
                    }
                    if colorConfig.darkColorScale.isDarkening {
                        Image(systemName: "square.2.layers.3d.fill")
                            .font(.title3)
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(.background050, .background200)
                            .rounded(backgroundColor: .background500, padding: 4, cornerRadius: 8)
                    }
                }
                ZStack {
                    ColorPickerPreview(color: colorConfig.colorModel)
                        .frame(width: 32, height: 32)
                        .onTapGesture {
                            isEditingColor = true
                        }
                    if !colorConfig.rangeWidth.isFull {
                        CircularProgressView(progress: colorConfig.rangeWidth.progress,
                                             color: colorConfig.color.contrastingColor,
                                             lineWidth: 4)
                            .frame(width: 16, height: 16)
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
        .onAppear {
            selectedColor = colorConfig.color
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
#if os(macOS)
            .pasteDestination(for: String.self) { strings in
                if let string = strings.first {
                    colorClipboard.text = string
                }
            }
#endif
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
                    ColorPicker(colorConfig.colorName, selection: $selectedColor, supportsOpacity: false)
                        .frame(maxWidth: .infinity)
                        .rounded()
                        .onChange(of: selectedColor) { _, newValue in
                            colorConfig.colorModel = .rgb(newValue)
                        }
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
        pasteboardColor(color: .rgb(.foreground900), icon: Image(systemName: "square.on.square.dashed"))
            .onTapGesture {
                colorClipboard.text = String.pasteboardString
            }
    }
    
    @ViewBuilder
    func pasteColorButton(color: ColorModel, size: CGFloat = 32) -> some View {
        pasteboardColor(color: color, size: size)
            .onTapGesture {
                colorConfig.colorModel = color
                setColorValues()
            }
    }
    
    @ViewBuilder
    func pasteboardColor(color: ColorModel,
                         icon: Image = Image(systemName: "doc.on.clipboard"), size: CGFloat = 32) -> some View {
        ZStack {
            rectangle(color: color)
            icon
                .resizable()
                .scaledToFit()
                .padding(size / 4)
                .symbolRenderingMode(.hierarchical)
                .foregroundColor(color.color.contrastingColor)
                
        }
        .frame(width: size, height: size)
    }
    
    var colorWheelColors: [ColorModel] {
        guard let hct = colorConfig.hctColor else { return [] }
        let colors = TemperatureCache(hct).analogous(count: 12)
        return Array(Set(colors)).sorted(by: { $0.hue < $1.hue }).map { .hct($0) }
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
        guard let hct = colorConfig.hctColor else {
            print("Error converting color to HCT.")
            return
        }
        withAnimation {
            hueSliderValue = round(hct.hue)
            chromaOrSaturationSliderValue = round(hct.chroma)
            toneOrBrightnessSliderValue = round(hct.tone)
        }
    }
    
    func setHSBValues() {
        guard let hsba = colorConfig.color.hsba else {
            print("Error converting color to HSB.")
            return
        }
        withAnimation {
            hueSliderValue = round(hsba.hue * 360)
            chromaOrSaturationSliderValue = round(hsba.saturation * 100)
            toneOrBrightnessSliderValue = round(hsba.brightness * 100)
        }
    }
    
    func updateColor() {
        switch colorSpace {
        case .hct:
            let hctColor = Hct.from(hueSliderValue, chromaOrSaturationSliderValue, toneOrBrightnessSliderValue)
            colorConfig.colorModel = .hct(hctColor)
        case .hsb:
            let hue = hueSliderValue / 360
            let saturation = chromaOrSaturationSliderValue / 100
            let brightness = toneOrBrightnessSliderValue / 100
            colorConfig.colorModel = .rgb(Color(hue: hue, saturation: saturation, brightness: brightness))
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
                            .foregroundColor(.foreground300)
                    }
                    Text(colorConfig.colorName)
                        .font(.title3)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(.foreground100)
                }
                HStack(spacing: 12) {
                    rectangle(color: colorConfig.colorModel)
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
                .foregroundColor(.foreground300)
            if let text = colorClipboard.text, text.color != nil {
                Text(text)
                    .font(.caption2)
                    .foregroundColor(.foreground500)
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
                TextField("", value: sliderValue, formatter: NumberFormatter())
                    .multilineTextAlignment(.center)
#if !os(macOS)
                    .keyboardType(.decimalPad)
#endif
                    .frame(width: 50)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Stepper("\(Int(sliderValue.wrappedValue))", value: sliderValue, in: range)
                    .labelsHidden()
                    .fixedSize()
            }
            .padding(.leading, 4)
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
                        ForEach(colorWheelColors) { color in
                            ZStack {
                                rectangle(color: color)
                                if showCopyIcons {
                                    Image(systemName: "square.on.square")
                                        .symbolRenderingMode(.hierarchical)
                                        .foregroundColor(color.color.contrastingColor)
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
    
    func rectangle(color: ColorModel) -> some View {
        Rectangle()
            .fill(color.color)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
    
    @ViewBuilder
    var colorValues: some View {
        VStack(alignment: .leading) {
            colorValue("RGB", value: colorConfig.color.hexRGB)
            switch colorConfig.colorModel {
            case .hct(let color):
                colorValue("HCT", value: color.label)
            case .hsb(let hsba):
                colorValue("HSB", value: hsba.label)
            case .rgb(let color):
                colorValue("HCT", value: color.hct?.label ?? "")
            }
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
                        ForEach(colorClipboard.colors.reversed()) { color in
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
    @State var colorConfig = ColorConfig(colorModel: .rgb(.blue.muted), groupName: "Brand", colorName: "Primary",
                                         lightColorScale: .lightening, darkColorScale: .darkening, rangeWidth: .half)
    @State var colorClipboard = ColorClipboard()
    return CustomColorPicker(colorConfig: $colorConfig, colorClipboard: $colorClipboard, isEditing: false) {} onEdit: {}
}
