//
//  GeneralSettingsView.swift
//  Paletteer
//
//  Created by Oscar De Moya on 26/06/24.
//

import SwiftUI

struct GeneralSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage(key(.colorPalette)) var colorPalette = [ColorConfig]()
    @AppStorage(key(.showCopyIcons)) var showCopyIcons: Bool = true
    @AppStorage(key(.useColorInClipboard)) var useColorInClipboard: Bool = true
    @State private var colorClipboard = ColorClipboard()
    @State private var showDestructiveConfirmation: Bool = false
    @State private var destructiveButtonTitle: LocalizedStringKey = ""
    @State private var destructiveButtonText: LocalizedStringKey = ""
    @State private var destructiveAction: Action = {}
    
    var body: some View {
        Form {
            Section("New Colors") {
                Toggle("Show Copy Icons", isOn: $showCopyIcons)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Toggle("Use Color in Clipboard", isOn: $useColorInClipboard)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            Section("Danger Zone") {
                Button {
                    destructiveButtonTitle = "Delete Color?"
                    destructiveButtonText = "Delete"
                    destructiveAction =  {
                        DispatchQueue.main.async {
                            dismiss()
                            colorPalette.removeAll()
                            colorClipboard.removeAll()
                        }
                    }
                    showDestructiveConfirmation = true
                } label: {
                    Text("Delete All Colors")
                        .frame(maxWidth: .infinity)
                }
                .tint(.destructiveBackground)
            }
        }
        .navigationTitle("General")
        .confirmationDialog(destructiveButtonTitle, isPresented: $showDestructiveConfirmation, titleVisibility: .visible) {
            Button(destructiveButtonText, role: .destructive, action: destructiveAction)
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This action cannot be undone.")
        }
    }
}

#Preview {
    GeneralSettingsView()
}
