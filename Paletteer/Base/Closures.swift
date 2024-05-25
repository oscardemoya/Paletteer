//
//  Closures.swift
//  Paletteer
//
//  Created by Oscar De Moya on 28/04/24.
//

import Foundation

typealias Action = () -> Void
typealias ValueAction<T> = (T) -> Void
typealias TypeValueAction<T, V> = (T, V) -> Void
