//
//  JSONString.swift
//  Paletteer
//
//  Created by Oscar De Moya on 2/06/24.
//

import Foundation

public extension String {
    var jsonObject: Any? {
        guard let data = data(using: .utf8) else { return nil }
        guard let json = try? JSONSerialization.jsonObject(with: data, options: []) else { return nil }
        return json
    }
}
