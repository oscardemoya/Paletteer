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
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(items) { item in
                    ColorPaletteRow(colorPalette: item)
                        .onTapGesture {
                            selectedPalette = item
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                withAnimation {
                                    modelContext.delete(item)
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
            .navigationTitle("Paletteer")
#if !os(macOS) && !targetEnvironment(macCatalyst)
            .navigationBarTitleDisplayMode(.inline)
#endif
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: addItem) {
                        Label("Add", systemImage: "plus")
                    }
                }
            }
        }
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
