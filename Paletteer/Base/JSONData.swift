//
//  JSONData.swift
//  Paletteer
//
//  Created by Oscar De Moya on 2/06/24.
//

import Foundation

public extension Data {
    var jsonPrettyPrinted: String? {
        guard let json = try? JSONSerialization.jsonObject(with: self, options: []) else { return nil }
        guard let data = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted) else { return nil }
        return String(data: data, encoding: .utf8)
    }
}
