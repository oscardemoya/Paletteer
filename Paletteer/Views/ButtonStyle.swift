//
//  ButtonStyle.swift
//  Paletteer
//
//  Created by Oscar De Moya on 27/04/24.
//

import SwiftUI

struct CustomButtonStyle: ButtonStyle {
    var backgroundColor: Color
    var foregroundColor: Color
    var cornerRadius: CGFloat
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .font(.body)
            .background(backgroundColor)
            .foregroundColor(foregroundColor)
            .cornerRadius(cornerRadius, antialiased: true)
            .scaleEffect(configuration.isPressed ? 0.99 : 1.0)
            .transition(.opacity)
    }
}

extension ButtonStyle where Self == CustomButtonStyle {
    static func custom(backgroundColor: Color = .blue,
                       foregroundColor: Color = .white,
                       cornerRadius: CGFloat = 16) -> CustomButtonStyle {
        .init(backgroundColor: backgroundColor, foregroundColor: foregroundColor, cornerRadius: cornerRadius)
    }
}

#Preview {
    VStack {
        Button("Button", action: {}).buttonStyle(.custom())
    }
    .padding()
}
