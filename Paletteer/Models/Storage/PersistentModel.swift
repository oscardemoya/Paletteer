//
//  PersistentModel.swift
//  Paletteer
//
//  Created by Oscar De Moya on 9/8/24.
//

import SwiftData

extension PersistentModel {
    var isPersisted: Bool { persistentModelID.storeIdentifier != nil }
}
