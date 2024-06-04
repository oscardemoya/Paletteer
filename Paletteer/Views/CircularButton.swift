//
//  CircularButton.swift
//  Paletteer
//
//  Created by Oscar De Moya on 28/04/24.
//

import SwiftUI

struct CircularButtonStyle: ButtonStyle {
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
            case .large: return 8
            }
        }
        
        var verticalPadding: CGFloat {
            switch self {
            case .compact: return 0
            case .regular: return 16
            case .large: return 8
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

extension ButtonStyle where Self == CircularButtonStyle {
    static func circular(size: CircularButtonStyle.Size = .regular) -> CircularButtonStyle {
        .init(size: size)
    }
}

struct CircularButton: View {
    var size: CircularButtonStyle.Size = .regular
    var systemName: String = "xmark.circle.fill"
    var action: Action
    
    var body: some View {
        Button {
            action()
        } label: {
            Image(systemName: systemName)
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
