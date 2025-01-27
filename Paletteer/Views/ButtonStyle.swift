//
//  ButtonStyle.swift
//  Paletteer
//
//  Created by Oscar De Moya on 27/04/24.
//

import SwiftUI

struct CustomButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled: Bool
    
    var backgroundColor: Color
    var foregroundColor: Color
    var disabledBackgroundColor: Color
    var disabledForegroundColor: Color
    var cornerRadius: CGFloat
    var horizontalPadding: CGFloat = 16
    var verticalPadding: CGFloat = 12
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, horizontalPadding)
            .padding(.vertical, verticalPadding)
            .font(.body)
            .background(isEnabled ? backgroundColor : disabledBackgroundColor)
            .foregroundColor(isEnabled ? foregroundColor : disabledForegroundColor)
            .cornerRadius(cornerRadius, antialiased: true)
            .scaleEffect(configuration.isPressed ? 0.99 : 1.0)
            .transition(.opacity)
    }
}

extension ButtonStyle where Self == CustomButtonStyle {
    static func custom(backgroundColor: Color = .blue,
                       foregroundColor: Color = .white,
                       disabledBackgroundColor: Color = .gray,
                       disabledForegroundColor: Color = .white,
                       cornerRadius: CGFloat = 16,
                       horizontalPadding: CGFloat = 16,
                       verticalPadding: CGFloat = 12) -> CustomButtonStyle {
        .init(
            backgroundColor: backgroundColor,
            foregroundColor: foregroundColor,
            disabledBackgroundColor: disabledBackgroundColor,
            disabledForegroundColor: disabledForegroundColor,
            cornerRadius: cornerRadius,
            horizontalPadding: horizontalPadding,
            verticalPadding: verticalPadding
        )
    }
}

#Preview {
    VStack {
        Button("Button", action: {}).buttonStyle(.custom())
    }
    .padding()
}
