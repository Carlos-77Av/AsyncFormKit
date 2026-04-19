//
//  ValidationMode.swift
//  AsyncFormKit
//
//  Created by Carlos Alvarez on 19/4/26.
//

import Foundation

public enum ValidationMode: Equatable, Sendable {
    case joinAll(separator: String = ", ")
    case highestPriority
    case custom(String)
}
