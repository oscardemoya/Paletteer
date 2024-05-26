//
//  ButtonStyle.swift
//  Paletteer
//
//  Created by Oscar De Moya on 27/04/24.
//

import SwiftUI

struct CustomButtonStyle: ButtonStyle {
    var backgroundColor: Color
    var cornerRadius: CGFloat
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(backgroundColor)
            .cornerRadius(cornerRadius, antialiased: true)
            .padding(.vertical, 2)
            .scaleEffect(configuration.isPressed ? 0.99 : 1.0)
            .transition(.opacity)
    }
}

extension ButtonStyle where Self == CustomButtonStyle {
    static func custom(backgroundColor: Color = Color.gray.opacity(0.2), cornerRadius: CGFloat = 16) -> CustomButtonStyle {
        .init(backgroundColor: backgroundColor, cornerRadius: cornerRadius)
    }
}

#Preview {
    VStack {
        Button("Button", action: {}).buttonStyle(.custom())
    }
    .padding()
}
