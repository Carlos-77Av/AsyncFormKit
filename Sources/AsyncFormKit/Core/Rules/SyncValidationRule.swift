//
//  SyncValidationRule.swift
//  AsyncFormKit
//
//  Created by Carlos Alvarez on 19/4/26.
//

import Foundation

public protocol SyncValidationRule: ValidationRule {
    func validateSync(
        _ text: String,
        context: ValidationContext
    ) -> Bool
}

public extension SyncValidationRule {
    func validate(
        _ text: String,
        context: ValidationContext
    ) async -> Bool {
        validateSync(text, context: context)
    }
}
