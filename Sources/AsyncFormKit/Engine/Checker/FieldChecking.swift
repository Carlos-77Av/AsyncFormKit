//
//  FieldChecking.swift
//  AsyncFormKit
//
//  Created by Carlos Alvarez on 19/4/26.
//

import Foundation

public protocol FieldChecking: Sendable {
    func validate(
        text: String,
        rules: [any InputRule],
        context: ValidationContext
    ) async -> ValidationSummary

    func buildError(
        from brokenRules: [any InputRule],
        mode: ValidationMode
    ) -> String
}
