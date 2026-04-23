//
//  RequiredRule.swift
//  AsyncFormKit
//
//  Created by Carlos Alvarez on 19/4/26.
//

import Foundation

public struct RequiredRule: SyncValidationRule {
    public let code: String
    public let message: String
    public let priority: Int
    public let executionKind: RuleExecutionKind

    public init(
        code: String = "required",
        message: String = "This field is required",
        priority: Int = 100,
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
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
