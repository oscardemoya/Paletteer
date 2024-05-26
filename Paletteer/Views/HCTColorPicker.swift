//
//  HCTColorPicker.swift
//  Paletteer
//
//  Created by Oscar De Moya on 28/04/24.
//

import SwiftUI

struct HCTColorPicker: View {
    @State var title: String = ""
    @Binding var selectedColor: Color
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
    
    let gridRows = [GridItem(.fixed(44))]
    
    var colorWheelColors: [Color] {
        guard let hct = selectedColor.hct else { return [] }
        return TemperatureCache(hct).analogous(count: 12).map { Color(hctColor: $0) }
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
        .buttonStyle(.custom())
        .sheet(isPresented: $showingSheet) {
            colorCreator
        }
    }
    
    @ViewBuilder
    var colorCreator: some View {
        VStack(spacing: 0) {
            VStack(spacing: 16) {
                HStack(alignment: .center) {
                    if let colorFromClipboard {
                        pasteColorButton(color: colorFromClipboard)
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
                    CircularCloseButton(size: .large) {
                        showingSheet = false
                    }
                    .frame(width: 32, height: 32)
                }
            }
            .padding()
            Divider()
            switch colorSpace {
            case .hct, .hsb:
                hctColorPicker
            case .rgb:
                ColorPicker(title, selection: $selectedColor, supportsOpacity: false)
                    .rounded()
                    .padding()
            }
            colorWheel
        }
        .readSize { size in
            sheetHeight = size.height
        }
        .presentationDetents([.height(sheetHeight)])
        .presentationDragIndicator(.hidden)
        .onChange(of: showingSheet) {
            if showingSheet {
                setColorValues()
            }
        }
        .onChange(of: colorSpace, setColorValues)
        .onChange(of: hueSliderValue, updateColor)
        .onChange(of: chromaOrSaturationSliderValue, updateColor)
        .onChange(of: toneOrBrightnessSliderValue, updateColor)
    }
    
    @ViewBuilder
    func pasteColorButton(color: Color) -> some View {
        ZStack {
            rectangle(color: color)
            Image(systemName: "doc.on.clipboard")
                .symbolRenderingMode(.hierarchical)
                .foregroundColor(color.contrastingColor)
                .padding(8)
        }
        .frame(width: 36, height: 36)
        .onTapGesture {
            selectedColor = color
            setColorValues()
        }
    }
    
    var colorFromClipboard: Color? {
        guard let pasteboard = String.pasteboardString else { return nil }
        print("Text in clipboard: \(pasteboard)")
        if let color = color(fromHTCString: pasteboard) { return color }
        if let color = color(fromHexString: pasteboard) { return color }
        return nil
    }
    
    func color(fromHTCString string: String) -> Color? {
        let bodyRegex = /H(?<hue>\d+)\s* C(?<chroma>\d+)\s* T(?<tone>\d+)/.ignoresCase().dotMatchesNewlines()
        return string.matches(of: bodyRegex).compactMap { match -> Color? in
            guard let hue = Double(match.output.hue) else { return nil }
            guard let chroma = Double(match.output.chroma) else { return nil }
            guard let tone = Double(match.output.tone) else { return nil }
            let hct = Hct.from(hue, chroma, tone)
            return Color(hctColor: hct)
        }.first
    }
    
    func color(fromHexString string: String) -> Color? {
        let bodyRegex = /#(?<hexString>[a-f0-9]{6})/.ignoresCase().dotMatchesNewlines()
        return string.matches(of: bodyRegex).compactMap { match -> Color? in
            let hexString = String(match.output.hexString)
            return Color(hex: hexString)
        }.first
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
    var hctColorPicker: some View {
        VStack(spacing: 12) {
            Text(title)
                .font(.title3)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
            HStack(spacing: 12) {
                rectangle(color: selectedColor)
                    .frame(width: squareHeight, height: squareHeight)
                colorValues
                Spacer()
            }
            hctSliders
        }
        .padding()
    }
    
    @ViewBuilder
    var hctSliders: some View {
        Grid(alignment: .leading) {
            hctSlider("Hue", sliderValue: $hueSliderValue, in: Self.hueRange)
            hctSlider("Chroma", sliderValue: $chromaOrSaturationSliderValue, in: Self.chromaOrSaturationRange)
            hctSlider("Tone", sliderValue: $toneOrBrightnessSliderValue, in: Self.toneOrBrightnessRange)
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
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                LazyHGrid(rows: gridRows)  {
                    ForEach(colorWheelColors, id: \.self) { color in
                        ZStack {
                            rectangle(color: color)
                            if showCopyIcons {
                                Image(systemName: "square.on.square")
                                    .foregroundColor(color.contrastingColor)
                            }
                        }
                        .aspectRatio(1, contentMode: .fill)
                        .onTapGesture {
                            withAnimation {
                                String.pasteboardString = color.hexRGB.uppercased()
                                showingSheet = false
                            }
                        }
                    }
                }
            }
            .fixedSize(horizontal: false, vertical: true)
        }
        .contentMargins(12)
    }
    
    func rectangle(color: Color) -> some View {
        Rectangle()
            .fill(color)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
    
    func borderedRect(color: Color) -> some View {
        rectangle(color: color)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(color.contrastingColor, lineWidth: 1)
            )
    }
    
    var colorValues: some View {
        return VStack(alignment: .leading) {
            HStack {
                Text("RGB")
                    .fontWeight(.bold)
                Button {
                    String.pasteboardString = selectedColor.hexRGB.uppercased()
                } label: {
                    HStack {
                        Text(selectedColor.hexRGB.uppercased())
                        if showCopyIcons {
                            Image(systemName: "square.on.square")
                        }
                    }
                    .padding(2)
                }
            }
            HStack {
                Text("HTC")
                    .fontWeight(.bold)
                Button {
                    if let hct = selectedColor.hct {
                        String.pasteboardString = hct.label
                    }
                } label: {
                    HStack {
                        if let hct = selectedColor.hct {
                            Text(hct.label)
                        }
                        if showCopyIcons {
                            Image(systemName: "square.on.square")
                        }
                    }
                    .padding(2)
                }
            }
        }
        .readSize { size in
            squareHeight = size.height
        }
    }
}

#Preview {
    @State var color: Color = .blue
    return HCTColorPicker(title: "Title", selectedColor: $color)
}
