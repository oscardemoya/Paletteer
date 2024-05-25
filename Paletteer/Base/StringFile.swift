//
//  StringFile.swift
//  Paletteer
//
//  Created by Oscar De Moya on 27/04/24.
//

import Foundation

extension String {
    init?(forResource name: String?, ofType ext: String? = nil, parameters: [String: Any]? = nil,
                 bundle: Bundle = Bundle.main) {
        guard let path = bundle.path(forResource: name, ofType: ext) else { return nil }
        guard var string = try? String(contentsOfFile: path, encoding: String.Encoding.utf8) else { return nil }
        guard let parameters = parameters else {
            self = string
            return
        }
        parameters.keys.forEach { (key) in
            guard let value = parameters[key] else { return }
            string = string.replacingOccurrences(of: key, with: "\(value)")
        }
        self = string
    }
    
    func write(to fileName: String) {
        guard let url = FileManager.default.fileURL(fileName: fileName) else { return }
        let directoryURL = url.deletingLastPathComponent()
        do {
            try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("Error creating directories: \(error)")
            return
        }
        do {
            try write(to: url, atomically: true, encoding: String.Encoding.utf8)
        } catch {
            print(error.localizedDescription)
        }
    }
}
