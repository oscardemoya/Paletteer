//
//  Item.swift
//  Paletteer
//
//  Created by Oscar De Moya on 1/18/25.
//

import SwiftUI
import SwiftData

@Model
final class ColorPalette: Identifiable, Hashable, Equatable {
    var id: String = UUID().uuidString
    var createdAt: Date = Date.now
    var name: String = ""
    var representation: String = ""
    
    @Transient var configs: [ColorConfig] = [] {
        didSet {
            representation = configs.representation
        }
    }
    
    init(id: String = UUID().uuidString,
         createdAt: Date = Date.now,
         name: String = "New Color Palette",
         representation: String = "") {
        self.id = id
        self.createdAt = createdAt
        self.name = name
        setConfigs(from: representation)
    }
    
    static func makeSample() -> Self {
        .init(representation: [ColorConfig].sample.representation)
    }
    
    func setConfigs(from representation: String) {
        self.representation = representation
        updateConfigs()
    }
    
    func updateConfigs() {
        configs = representation.split(separator: "\n").compactMap { line in
            ColorConfig(from: String(line))
        }
    }
    
    func colorWheel(for colorScheme: AppColorScheme, with params: ColorPaletteParams) -> [[Color]] {
        guard !configs.isEmpty else {
            var colors: [Color] = [.clear]
            (1...4).forEach { index in
                colors.append(.secondaryBackground.opacity(Double(index) / 5))
            }
            return [colors]
        }
        return configs.compactMap { colorConfig in
            let shades = colorConfig.shades(params: params, colorSpace: .hsb)
            var colors: [Color] = [.clear]
            (1...4).forEach { index in
                if let color = shades[safe: Int(round(Double(shades.count) * Double(index) / 5))] {
                    colors.append(colorScheme.color(for: color))
                }
            }
            return colors
        }
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: ColorPalette, rhs: ColorPalette) -> Bool {
        guard lhs.id == rhs.id else { return false }
        guard lhs.createdAt == rhs.createdAt else { return false }
        guard lhs.name == rhs.name else { return false }
        guard lhs.configs == rhs.configs else { return false }
        return true
    }
}
