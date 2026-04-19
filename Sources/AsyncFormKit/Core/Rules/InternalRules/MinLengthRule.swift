//
//  MinLengthRule.swift
//  AsyncFormKit
//
//  Created by Carlos Alvarez on 19/4/26.
//

import Foundation

public struct MinLengthRule: SyncInputRule {
    public let minimum: Int
    public let code: String
    public let message: String
    public let priority: Int
    public let executionKind: RuleExecutionKind

    public init(
        minimum: Int,
        code: String = "min.length",
        message: String? = nil,
        priority: Int = 80,
        executionKind: RuleExecutionKind = .local
    ) {
        self.minimum = minimum
        self.code = code
        self.message = message ?? "Minimum \(minimum) characters required"
        self.priority = priority
        self.executionKind = executionKind
    }

    public func validateSync(
        _ text: String,
        context: ValidationContext
    ) -> Bool {
        text.count >= minimum
    }
}
