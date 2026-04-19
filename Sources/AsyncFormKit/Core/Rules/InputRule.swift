//
//  InputRule.swift
//  AsyncFormKit
//
//  Created by Carlos Alvarez on 19/4/26.
//

import Foundation

public protocol InputRule: Sendable {
    var code: String { get }
    var message: String { get }
    var priority: Int { get }
    var executionKind: RuleExecutionKind { get }

    func validate(
        _ text: String,
        context: ValidationContext
    ) async -> Bool
}
