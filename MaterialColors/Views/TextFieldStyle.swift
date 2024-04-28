//
//  TextFieldStyle.swift
//  MaterialColors
//
//  Created by Oscar De Moya on 27/04/24.
//

import SwiftUI

struct TextFieldStyle: ViewModifier {
    var backgroundColor: Color
    var cornerRadius: CGFloat
    
    func body(content: Content) -> some View {
        if #available(iOS 17.0, *) {
            content
                .padding()
                .background(backgroundColor)
                .cornerRadius(cornerRadius, antialiased: true)
                .padding(.vertical, 2)
        } else {
            content
        }
    }
}

// MARK: View Extension

extension View {
    func rounded(backgroundColor: Color = Color.gray.opacity(0.2), cornerRadius: CGFloat = 16) -> some View {
        modifier(TextFieldStyle(backgroundColor: backgroundColor, cornerRadius: cornerRadius))
    }
}
