//
//  Untitled.swift
//  AsyncFormKit
//
//  Created by Carlos Alvarez on 19/4/26.
//

import Foundation

public protocol SyncInputRule: InputRule {
    func validateSync(
        _ text: String,
        context: ValidationContext
    ) -> Bool
}

public extension SyncInputRule {
    func validate(
        _ text: String,
        context: ValidationContext
    ) async -> Bool {
        validateSync(text, context: context)
    }
}
