//
//  ColorPaletteListView.swift
//  Paletteer
//
//  Created by Oscar De Moya on 1/18/25.
//

import SwiftUI
import SwiftData

struct ColorPaletteListView: View {
    var items: [ColorPalette]
    @Binding var selectedPalette: ColorPalette?
    @Environment(\.modelContext) private var modelContext
    @AppStorage(key(.colorPaletteParams)) var params = ColorPaletteParams()
    @AppStorage(key(.colorScheme)) var selectedAppearance: AppColorScheme = .system
    @State private var isConfiguring = false
    
    var body: some View {
        NavigationStack {
            Group {
                if items.isEmpty {
                    emptyStateView
                } else {
                    contentView
                }
            }
            .navigationTitle("Paletteer")
            .sheet(isPresented: $isConfiguring) {
                SettingsPane()
            }
#if !os(macOS) && !targetEnvironment(macCatalyst)
            .navigationBarTitleDisplayMode(.inline)
#endif
            .toolbar {
#if !os(macOS) && !targetEnvironment(macCatalyst)
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        isConfiguring = true
                    } label: {
                        Image(systemName: "gear")
                    }
                }
#endif
                ToolbarItem(placement: .primaryAction) {
                    Button(action: addItem) {
                        Label("Add", systemImage: "plus")
                    }
                }
            }
        }
    }
    
    @ViewBuilder var contentView: some View {
        List {
            ForEach(items) { item in
                ColorPaletteRow(colorPalette: item, selectedPalette: $selectedPalette)
                    .onTapGesture {
                        selectedPalette = item
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            withAnimation {
                                modelContext.delete(item)
                                selectedPalette = nil
                            }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                        .tint(.destructiveBackground)
                    }
            }
            .listRowInsets(EdgeInsets())
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .scrollContentBackground(.hidden)
        .contentMargins(.zero)
        .background(.clear)
    }
    
    @ViewBuilder var emptyStateView: some View {
        ContentUnavailableView(
            "No Color Palettes",
            systemImage: "tray",
            description: Text("Please add a color palette to get started.")
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.secondaryBackground)
    }
    
    private func addItem() {
        withAnimation {
            let newItem = ColorPalette()
            modelContext.insert(newItem)
            try? modelContext.save()
        }
    }
}

#Preview {
    @Previewable @State var items: [ColorPalette] = [.makeSample()]
    @Previewable @State var selectedPalette: ColorPalette?
    ColorPaletteListView(items: items, selectedPalette: $selectedPalette)
        .modelContainer(for: ColorPalette.self, inMemory: true)
}
