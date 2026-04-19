//
//  FieldChecker.swift
//  AsyncFormKit
//
//  Created by Carlos Alvarez on 19/4/26.
//

import Foundation

public struct FieldChecker: FieldChecking {
    public init() {}

    public func validate(
        text: String,
        rules: [any InputRule],
        context: ValidationContext
    ) async -> ValidationSummary {
        var brokenRules: [any InputRule] = []

        for rule in rules {
            let shouldRun = shouldEvaluate(rule: rule, trigger: context.trigger)
            guard shouldRun else { continue }

            let isValid = await rule.validate(text, context: context)
            if !isValid {
                brokenRules.append(rule)
            }
        }

        return ValidationSummary(
            isValid: brokenRules.isEmpty,
            brokenRules: brokenRules
        )
    }

    public func buildError(
        from brokenRules: [any InputRule],
        mode: ValidationMode
    ) -> String {
        guard !brokenRules.isEmpty else { return "" }

        switch mode {
        case .joinAll(let separator):
            return brokenRules
                .map(\.message)
                .joined(separator: separator)

        case .highestPriority:
            return brokenRules
                .sorted { $0.priority > $1.priority }
                .first?.message ?? ""

        case .custom(let message):
            return message
        }
    }

    private func shouldEvaluate(
        rule: any InputRule,
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
