//
//  ErrorPresentationMode.swift
//  AsyncFormKit
//
//  Created by Carlos Alvarez on 19/4/26.
//

import Foundation

public enum ErrorPresentationMode: Equatable, Sendable {
    case joinAll(separator: String = ", ")
    case highestPriority
    case custom(String)
}
