//
//  FieldValidator.swift
//  AsyncFormKit
//
//  Created by Carlos Alvarez on 19/4/26.
//

import Foundation

public struct FieldValidator: FieldValidating {
    public init() {}

    public func validate(
        value: String,
        rules: [any ValidationRule],
        context: ValidationContext
    ) async -> ValidationResult {
        var failedRules: [any ValidationRule] = []

        for rule in rules {
            let shouldRun = shouldEvaluate(rule: rule, trigger: context.trigger)
            guard shouldRun else { continue }

            let isValid = await rule.validate(value, context: context)
            if !isValid {
                failedRules.append(rule)
            }
        }

        return ValidationResult(
            isValid: failedRules.isEmpty,
            failedRules: failedRules
        )
    }

    public func buildErrorMessage(
        from failedRules: [any ValidationRule],
        mode: ErrorPresentationMode
    ) -> String {
        guard !failedRules.isEmpty else { return "" }

        switch mode {
        case .joinAll(let separator):
            return failedRules
                .map(\.message)
                .joined(separator: separator)

        case .highestPriority:
            return failedRules
                .sorted { $0.priority > $1.priority }
                .first?.message ?? ""

        case .custom(let message):
            return message
        }
    }

    private func shouldEvaluate(
        rule: any ValidationRule,
        trigger: ValidationTrigger
    ) -> Bool {
        switch trigger {
        case .onChange, .onBlur:
            return rule.executionKind == .local
        case .onSubmit, .manual:
            return true
        }
    }
}
