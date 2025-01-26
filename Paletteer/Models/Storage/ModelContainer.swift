//
//  ModelContainer.swift
//  Paletteer
//
//  Created by Oscar De Moya on 8/30/24.
//

import SwiftUI
import SwiftData

extension ModelContainer {
    static var shared: ModelContainer = {
        let storeURL = URL.documentsDirectory.appending(path: "database.sqlite")
        let schema = Schema([
            ColorPalette.self,
        ])
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            url: storeURL,
            cloudKitDatabase: .private("iCloud.com.kafeteer.Paletteer")
        )
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
}
