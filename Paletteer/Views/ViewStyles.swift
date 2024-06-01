//
//  ViewStyles.swift
//  Paletteer
//
//  Created by Oscar De Moya on 31/05/24.
//

import SwiftUI

extension View {
    func smoothCornerRadius(_ cornerRadius: CGFloat) -> some View {
        return self
            .clipShape(.rect(cornerRadius: cornerRadius, style: .continuous))
    }
    
    func buttonCornerRadius(_ cornerRadius: CGFloat) -> some View {
        return self
            #if os(OSX)
            .buttonBorderShape(.roundedRectangle)
            #else
            .buttonBorderShape(.roundedRectangle(radius: 16))
            #endif
    }
}

struct RoundedViewStyle: ViewModifier {
    var backgroundColor: Color
    var padding: CGFloat
    var cornerRadius: CGFloat
    
    func body(content: Content) -> some View {
        if #available(iOS 17.0, *) {
            content
                .padding(padding)
                .background(backgroundColor)
                .smoothCornerRadius(cornerRadius)
        } else {
            content
        }
    }
}

extension View {
    func rounded(backgroundColor: Color = .primaryInputBackground,
                 padding: CGFloat = 16, cornerRadius: CGFloat = 16) -> some View {
        modifier(RoundedViewStyle(backgroundColor: backgroundColor, padding: padding, cornerRadius: cornerRadius))
    }
}
