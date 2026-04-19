//
//  ValidationSummary.swift
//  AsyncFormKit
//
//  Created by Carlos Alvarez on 19/4/26.
//

import Foundation

public struct ValidationSummary {
    public let isValid: Bool
    public let brokenRules: [any InputRule]

    public init(
        isValid: Bool,
        brokenRules: [any InputRule]
    ) {
        self.isValid = isValid
        self.brokenRules = brokenRules
    }
}
