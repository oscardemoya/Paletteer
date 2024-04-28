//
//  CircularCloseButton.swift
//  MaterialColors
//
//  Created by Oscar De Moya on 28/04/24.
//

import SwiftUI

struct CircularCloseButton: View {
    enum Size {
        case compact
        case regular
        case large
        
        var isCompact: Bool { self == .compact }
        var isRegular: Bool { self == .regular }
        var isLarge: Bool { self == .large }
        
        var fontSize: CGFloat {
            switch self {
            case .compact: return 16
            case .regular: return 24
            case .large: return 32
            }
        }
        
        var horizontalPadding: CGFloat {
            switch self {
            case .compact: return 8
            case .regular: return 16
            case .large: return 12
            }
        }
        
        var verticalPadding: CGFloat {
            switch self {
            case .compact: return 0
            case .regular: return 16
            case .large: return 12
            }
        }
    }
    
    var size: Size = .regular
    var action: Action

    var body: some View {
        Button {
            action()
        } label: {
            Image(systemName: "xmark.circle.fill")
                .font(.system(size: size.fontSize))
                .symbolRenderingMode(.hierarchical)
                .padding(.horizontal, size.horizontalPadding)
                .padding(.vertical, size.verticalPadding)
        }
        .foregroundColor(.gray.opacity(0.75))
    }
}

struct CircularCloseButton_Previews: PreviewProvider {
    static var previews: some View {
        CircularCloseButton() {}
    }
}

