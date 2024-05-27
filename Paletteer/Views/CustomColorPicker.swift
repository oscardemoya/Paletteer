//
//  CustomColorPicker.swift
//  Paletteer
//
//  Created by Oscar De Moya on 28/04/24.
//

import SwiftUI

struct CustomColorPicker: View {
    @State var title: String = ""
    @Binding var selectedColor: Color
    @State private var textClipboard: String?
    @State private var colorClipboard = ColorClipboard()
    @State private var recentColors: [Color] = []
    @State private var showingSheet = false
    @State private var sheetHeight: CGFloat = .zero
    @State private var colorSpace: ColorSpace = .hct
    @State private var squareHeight: CGFloat = .zero
    @State private var hueSliderValue = Self.hueRange.median
    @State private var chromaOrSaturationSliderValue = Self.chromaOrSaturationRange.median
    @State private var toneOrBrightnessSliderValue = Self.toneOrBrightnessRange.median
    @State private var showCopyIcons: Bool = true
    
    static let hueRange: ClosedRange<Double> = 0...360
    static let chromaOrSaturationRange: ClosedRange<Double> = 0...120
    static let toneOrBrightnessRange: ClosedRange<Double> = 0...100
    
    let gridItems = [GridItem(.fixed(40))]
    
    var colorWheelColors: [Color] {
        guard let hct = selectedColor.hct else { return [] }
        return TemperatureCache(hct)
            .analogous(count: 12)
            .sorted(by: { $0.hue < $1.hue })
            .map { Color(hctColor: $0) }
    }
    
    var body: some View {
        Button {
            showingSheet.toggle()
        } label: {
            HStack {
                Text(title)
                Spacer()
                borderedRect(color: selectedColor)
                    .frame(width: 30, height: 30)
            }
        }
        .buttonStyle(.custom(backgroundColor: .secondaryActionBackground,
                             foregroundColor: .secondaryActionForeground))
        .sheet(isPresented: $showingSheet) {
            colorCreator
        }
    }
    
    @ViewBuilder
    var colorCreator: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                VStack(spacing: 16) {
                    HStack(alignment: .center) {
                        Spacer().frame(width: 32, height: 32)
                        Spacer()
                        Picker("", selection: $colorSpace) {
                            ForEach(ColorSpace.allCases) {
                                Text($0.title)
                            }
                        }
                        .pickerStyle(.segmented)
                        .fixedSize()
                        Spacer()
                        CircularCloseButton {
                            showingSheet = false
                        }
                        .frame(width: 32, height: 32)
                    }
                }
                .padding(12)
                Divider()
                VStack(spacing: 16) {
                    selectedColorView
                    switch colorSpace {
                    case .hct, .hsb:
                        hctSliders
                    case .rgb:
                        ColorPicker(title, selection: $selectedColor, supportsOpacity: false)
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
#if os(macOS)
            .fixedSize()
#else
            .readSize { size in
                sheetHeight = size.height
            }
            .presentationDetents([.height(sheetHeight)])
#endif
        }
        .presentationDragIndicator(.hidden)
        .onChange(of: showingSheet) {
            if showingSheet {
                setColorValues()
                updateTextClipboard()
            }
        }
        .onChange(of: colorSpace, setColorValues)
        .onChange(of: hueSliderValue, updateColor)
        .onChange(of: chromaOrSaturationSliderValue, updateColor)
        .onChange(of: toneOrBrightnessSliderValue, updateColor)
        .onChange(of: textClipboard, copyTextToPasteboard)
    }
    
    func copyTextToPasteboard() {
        String.pasteboardString = textClipboard
    }
    
    func updateTextClipboard() {
        textClipboard = String.pasteboardString
    }
    
    @ViewBuilder
    var pasteboardLookupButton: some View {
        pasteboardColor(color: .foreground900, icon: Image(systemName: "square.on.square.dashed"))
            .onTapGesture {
                updateTextClipboard()
            }
    }
    
    @ViewBuilder
    func pasteColorButton(color: Color, size: CGFloat = 32) -> some View {
        pasteboardColor(color: color, size: size)
            .onTapGesture {
                selectedColor = color
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
        guard let hct = selectedColor.hct else {
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
        guard let hsba = selectedColor.hsba else {
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
            selectedColor = Color(hctColor: hctColor)
        case .hsb:
            let hue = hueSliderValue / 360
            let saturation = chromaOrSaturationSliderValue / 100
            let brightness = toneOrBrightnessSliderValue / 100
            selectedColor = Color(hue: hue, saturation: saturation, brightness: brightness)
        case .rgb:
            break
        }
        
    }
    
    @ViewBuilder
    var selectedColorView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.title3)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                HStack(spacing: 12) {
                    rectangle(color: selectedColor)
                        .frame(width: squareHeight, height: squareHeight)
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
                if let textClipboard, let color = textClipboard.color {
                    pasteColorButton(color: color)
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
            if let textClipboard, textClipboard.color != nil {
                Text(textClipboard)
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
                .foregroundColor(.foreground700)
        )
        .frame(maxHeight: .infinity)
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
            colorValue("RGB", value: selectedColor.hexRGB)
            colorValue("HCT", value: selectedColor.hct?.label ?? "")
        }
        .readSize { size in
            squareHeight = size.height
        }
    }
    
    @ViewBuilder
    func colorValue(_ titleKey: LocalizedStringKey, value: String) -> some View {
        HStack(spacing: 2) {
            Text(titleKey)
                .fontWeight(.bold)
            Button {
                textClipboard = value.uppercased()
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
    @State var color: Color = .blue
    return CustomColorPicker(title: "Title", selectedColor: $color)
}
