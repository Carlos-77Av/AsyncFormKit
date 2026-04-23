//
//  EmailRule.swift
//  AsyncFormKit
//
//  Created by Carlos Alvarez on 19/4/26.
//

import Foundation

public struct EmailRule: SyncValidationRule {
    public let code: String
    public let message: String
    public let priority: Int
    public let executionKind: RuleExecutionKind

    public init(
        code: String = "email.invalid",
        message: String = "Please enter a valid email",
        priority: Int = 90,
        executionKind: RuleExecutionKind = .local
    ) {
        self.code = code
        self.message = message
        self.priority = priority
        self.executionKind = executionKind
    }

    public func validateSync(
        _ text: String,
        context: ValidationContext
    ) -> Bool {
        let value = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !value.isEmpty else { return false }

        let pattern = #"^\S+@\S+\.\S+$"#
        return value.range(of: pattern, options: .regularExpression) != nil
    }
}
