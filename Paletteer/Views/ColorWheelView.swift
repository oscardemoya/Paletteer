//
//  ColorWheelView.swift
//  Paletteer
//
//  Created by Oscar De Moya on 1/18/25.
//


import SwiftUI

struct ColorWheelView: View {
    let colors: [[Color]]
    let slicePadding: CGFloat = 2

    var sliceCount: Int { colors.count }
    
    var body: some View {
        GeometryReader { geometry in
            let radius = min(geometry.size.width, geometry.size.height) / 2
            let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
            let sliceAngle = Angle(degrees: 360.0 / Double(sliceCount))

            Canvas { context, size in
                for (index, shades) in colors.enumerated() {
                    let startAngle = sliceAngle * Double(index)
                    let endAngle = sliceAngle * Double(index + 1)

                    for (shadeIndex, color) in shades.enumerated() {
                        let ringThickness = radius / CGFloat(shades.count)
                        let innerRadius = CGFloat(shadeIndex) * ringThickness
                        let outerRadius = innerRadius + ringThickness - slicePadding

                        context.fill(
                            Path { path in
                                path.addArc(
                                    center: center,
                                    radius: innerRadius,
                                    startAngle: startAngle,
                                    endAngle: endAngle,
                                    clockwise: false
                                )
                                path.addArc(
                                    center: center,
                                    radius: outerRadius,
                                    startAngle: endAngle,
                                    endAngle: startAngle,
                                    clockwise: true
                                )
                                path.closeSubpath()
                            },
                            with: .color(color)
                        )
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

#Preview {
    @Previewable let colors: [[Color]] = [
        [.green, .mint, .teal],
        [.blue, .cyan, .indigo],
        [.yellow, .orange, .brown],
        [.red, .pink, .orange],
    ]
    ColorWheelView(colors: colors)
}
