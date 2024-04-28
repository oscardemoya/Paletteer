//
//  HCTColorPicker.swift
//  MaterialColors
//
//  Created by Oscar De Moya on 28/04/24.
//

import SwiftUI

struct HCTColorPicker: View {
    @State var title: String = ""
    @Binding var color: Color
    @State private var showingSliders = false
    @State private var sheetHeight: CGFloat = .zero
    @State private var squareHeight: CGFloat = .zero
    @State private var hueSliderValue: Double = 180
    @State private var chromaSliderValue: Double = 60
    @State private var toneSliderValue: Double = 50
    
    var body: some View {
        Button {
            showingSliders.toggle()
        } label: {
            Text(title)
            Spacer()
            rectangle(color: color)
                .frame(width: 30, height: 30)
        }
        .sheet(isPresented: $showingSliders) {
            VStack(spacing: 24) {
                HStack(alignment: .center) {
                    Spacer()
                        .frame(width: 32, height: 32)
                    Spacer()
                    Text(title)
                        .font(.headline)
                    Spacer()
                    CircularCloseButton {
                        showingSliders = false
                    }
                    .frame(width: 32, height: 32)
                }
                HStack(spacing: 12) {
                    rectangle(color: color)
                        .frame(width: squareHeight, height: squareHeight)
                    colorValues()
                    Spacer()
                }
                Grid(alignment: .leading) {
                    GridRow {
                        Text("Hue").frame(alignment: .leading)
                        Slider(value: $hueSliderValue, in: 0...360)
                        Text("\(Int(hueSliderValue))")
                            .frame(minWidth: 36)
                            .gridColumnAlignment(.trailing)
                    }
                    GridRow {
                        Text("Chroma").frame(alignment: .leading)
                        Slider(value: $chromaSliderValue, in: 0...120)
                        Text("\(Int(chromaSliderValue))")
                            .frame(minWidth: 36)
                            .gridColumnAlignment(.trailing)
                    }
                    GridRow {
                        Text("Tone").frame(alignment: .leading)
                        Slider(value: $toneSliderValue, in: 0...100)
                        Text("\(Int(toneSliderValue))")
                            .frame(minWidth: 36)
                            .gridColumnAlignment(.trailing)
                    }
                }
            }
            .padding()
            .readSize { size in
                sheetHeight = size.height
            }
            .presentationDetents([.height(sheetHeight)])
            .presentationDragIndicator(.hidden)
            .onChange(of: showingSliders) {
                if showingSliders {
                    guard let hct = color.hct else {
                        print("Error converting color to HCT.")
                        return
                    }
                    hueSliderValue = hct.hue
                    chromaSliderValue = hct.chroma
                    toneSliderValue = hct.tone
                }
            }
            .onChange(of: hueSliderValue) {
                updateColor()
            }
            .onChange(of: chromaSliderValue) {
                updateColor()
            }
            .onChange(of: toneSliderValue) {
                updateColor()
            }
        }
    }
    
    func updateColor() {
        let hctColor = Hct.from(hueSliderValue, chromaSliderValue, toneSliderValue)
        color = Color(hctColor: hctColor)
    }
    
    func rectangle(color: Color) -> some View {
        Rectangle()
            .fill(color)
            .cornerRadius(8)
    }
    
    func colorValues() -> some View {
        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("RGB")
                    .fontWeight(.bold)
                Button {
                    UIPasteboard.general.string = color.hexRGB.uppercased()
                } label: {
                    Text(color.hexRGB.uppercased())
                    Image(systemName: "square.on.square")
                }
            }
            HStack {
                Text("HTC")
                    .fontWeight(.bold)
                Button {
                    if let hct = color.hct {
                        UIPasteboard.general.string = hct.label
                    }
                } label: {
                    if let hct = color.hct {
                        Text(hct.label)
                    }
                    Image(systemName: "square.on.square")
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
    return HCTColorPicker(title: "Title", color: $color)
}
