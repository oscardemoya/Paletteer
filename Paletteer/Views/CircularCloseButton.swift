//
//  CircularCloseButton.swift
//  Paletteer
//
//  Created by Oscar De Moya on 28/04/24.
//

import SwiftUI

struct CircularCloseButtonStyle: ButtonStyle {
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
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: size.fontSize))
            .symbolRenderingMode(.hierarchical)
            .padding(.horizontal, size.horizontalPadding)
            .padding(.vertical, size.verticalPadding)
            .foregroundColor(.gray.opacity(0.75))
    }
}

extension ButtonStyle where Self == CircularCloseButtonStyle {
    static func circular(size: CircularCloseButtonStyle.Size = .regular) -> CircularCloseButtonStyle {
        .init(size: size)
    }
}

struct CircularCloseButton: View {
    var size: CircularCloseButtonStyle.Size = .regular
    var action: Action
    
    var body: some View {
        Button {
            action()
        } label: {
            Image(systemName: "xmark.circle.fill")
        }
        .buttonStyle(.circular(size: size))
    }
}
        

#Preview {
    VStack {
        Button {} label: {
            Image(systemName: "xmark.circle.fill")
        }
        .buttonStyle(.circular(size: .large))
    }
    .padding()
}
