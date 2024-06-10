//
//  CircularProgressView.swift
//  Paletteer
//
//  Created by Oscar De Moya on 2/06/24.
//

import SwiftUI

struct CircularProgressView: View {
    var progress: Double
    var color: Color
    var lineWidth: CGFloat
    var rotationAngle: Angle = .zero
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(
                    color.opacity(0.25),
                    lineWidth: lineWidth
                )
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    color,
                    style: StrokeStyle(
                        lineWidth: lineWidth,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90) + rotationAngle)
        }
    }
}

#Preview {
    CircularProgressView(progress: 0.25, color: .blue, lineWidth: 10)
}
