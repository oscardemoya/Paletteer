//
//  FileManager.swift
//  Paletteer
//
//  Created by Oscar De Moya on 28/04/24.
//

import Foundation

extension FileManager {
    func fileURL(fileName: String = UUID().uuidString) -> URL? {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        return documentsDirectory.appendingPathComponent(fileName)
    }
    
    func removeDirectory(atURL url: URL) {
        do {
            try removeItem(at: url)
        } catch {
            print("Error removing directory: \(error)")
        }
    }
}
