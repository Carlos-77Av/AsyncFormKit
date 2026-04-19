//
//  MatchOtherFieldRule.swift
//  AsyncFormKit
//
//  Created by Carlos Alvarez on 19/4/26.
//

import Foundation

public struct MatchOtherFieldRule: SyncInputRule {
    public let otherFieldID: String
    public let code: String
    public let message: String
    public let priority: Int
    public let executionKind: RuleExecutionKind

    public init(
        otherFieldID: String,
        code: String = "field.mismatch",
        message: String = "Values do not match",
        priority: Int = 95,
        executionKind: RuleExecutionKind = .local
    ) {
        self.otherFieldID = otherFieldID
        self.code = code
        self.message = message
        self.priority = priority
        self.executionKind = executionKind
    }

    public func validateSync(
        _ text: String,
        context: ValidationContext
    ) -> Bool {
        text == context.value(for: otherFieldID)
    }
}
