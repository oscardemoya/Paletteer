//
//  ColorPaletteListView.swift
//  Paletteer
//
//  Created by Oscar De Moya on 1/18/25.
//

import SwiftUI
import SwiftData

struct ColorPaletteListView: View {
    @Binding var selectedPalette: ColorPalette?
    
    @Query private var items: [ColorPalette]
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
                }
                .onDelete(perform: deleteItems)
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

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
                try? modelContext.save()
            }
        }
    }
}

#Preview {
    @Previewable @State var selectedPalette: ColorPalette?
    ColorPaletteListView(selectedPalette: $selectedPalette)
        .modelContainer(for: ColorPalette.self, inMemory: true)
}
