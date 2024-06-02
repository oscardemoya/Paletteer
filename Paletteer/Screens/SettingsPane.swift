//
//  SettingsPane.swift
//  Paletteer
//
//  Created by Oscar De Moya on 1/06/24.
//

import SwiftUI

struct SettingsPane: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage(key(.colorPalette)) var colorPalette = [ColorConfig]()
    @AppStorage(key(.showCopyIcons)) var showCopyIcons: Bool = true
    @State private var showDeleteConfirmation: Bool = false

    var body: some View {
        NavigationStack {
            Form {
                Toggle("Show Copy Icons", isOn: $showCopyIcons)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(4)
                Button {
                    showDeleteConfirmation = true
                } label: {
                    Text("Delete All Colors")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.custom(backgroundColor: .destructiveBackground,
                                     foregroundColor: .primaryActionForeground,
                                     cornerRadius: 16))
            }
            .navigationTitle("Settings")
        }
#if os(macOS)
        .padding()
        .frame(width: 300)
#else
        .frame(maxWidth: .infinity)
#endif
        .confirmationDialog("Delete Color?", isPresented: $showDeleteConfirmation, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                DispatchQueue.main.async {
                    dismiss()
                    colorPalette.removeAll()
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This action cannot be undone.")
        }
    }
}

#Preview {
    SettingsPane()
}
