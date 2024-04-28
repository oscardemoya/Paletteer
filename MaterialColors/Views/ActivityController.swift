//
//  ActivityController.swift
//  MaterialColors
//
//  Created by Oscar De Moya on 27/04/24.
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

#if !os(macOS)
struct ActivityViewController: UIViewControllerRepresentable {
    
    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ActivityViewController>) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController,
                                context: UIViewControllerRepresentableContext<ActivityViewController>) {}
    
}
#endif
