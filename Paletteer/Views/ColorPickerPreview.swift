//
//  ColorPickerPreview.swift
//  Paletteer
//
//  Created by Oscar De Moya on 3/06/24.
//

import SwiftUI

struct ColorPickerPreview: View {
    var color: ColorModel
    @State var contentSize: CGSize = .zero
    private var cornerRadius: CGFloat { round(contentSize.width / 4) }
    private var borderWidth: CGFloat { round(contentSize.width / 5) }
    
    let leadingGradientColors: [Color] = [
        Color(.systemRed),
        Color(.systemPurple),
        Color(.systemBlue),
        Color(.systemTeal),
        Color(.systemGreen),
        Color(.systemYellow),
        Color(.systemOrange),
        Color(.systemRed),
    ]

    var body: some View {
        borderedRect(color: color)
    }
    
    func borderedRect(color: ColorModel, strokeColor: Color = .foreground980) -> some View {
        rectangle(color: color)
            .readSize { size in
                contentSize = size
            }
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(
                        AngularGradient(colors: leadingGradientColors, center: .center),
                        lineWidth: borderWidth
                    )
                    .strokeBorder(strokeColor, lineWidth: ceil(borderWidth / 2))
            )
    }
    
    func rectangle(color: ColorModel) -> some View {
        Rectangle()
            .fill(color.color)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

#Preview {
    ColorPickerPreview(color: .rgb(.blue.muted))
        .frame(width: 120, height: 120)
}
