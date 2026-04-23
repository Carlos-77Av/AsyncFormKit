//
//  ValidationResult.swift
//  AsyncFormKit
//
//  Created by Carlos Alvarez on 19/4/26.
//

import Foundation

public struct ValidationResult {
    public let isValid: Bool
    public let failedRules: [any ValidationRule]

    public init(
        isValid: Bool,
        failedRules: [any ValidationRule]
    ) {
        self.isValid = isValid
        self.failedRules = failedRules
    }
}
