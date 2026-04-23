//
//  FieldValidating.swift
//  AsyncFormKit
//
//  Created by Carlos Alvarez on 19/4/26.
//

import Foundation

public protocol FieldValidating: Sendable {
    func validate(
        value: String,
        rules: [any ValidationRule],
        context: ValidationContext
    ) async -> ValidationResult

    func buildErrorMessage(
        from failedRules: [any ValidationRule],
        mode: ErrorPresentationMode
    ) -> String
}
