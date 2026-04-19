//
//  PasswordInputProfile.swift
//  AsyncFormKit
//
//  Created by Carlos Alvarez on 19/4/26.
//

import Foundation
import UIKit

public struct PasswordInputProfile: InputProfile {
    public let id: String
    public let title: String
    public let rules: [any InputRule]
    public let keyboardType: UIKeyboardType
    public let validationMode: ValidationMode
    public let validationPolicy: FieldValidationPolicy

    public init(
        id: String = "password",
        title: String = "Password"
    ) {
        self.id = id
        self.title = title
        self.rules = [
            RequiredRule(message: "Password is required"),
            MinLengthRule(
                minimum: 8,
                message: "Password must contain at least 8 characters"
            )
        ]
        self.keyboardType = .default
        self.validationMode = .highestPriority
        self.validationPolicy = .onChangeDebounced(300_000_000)
    }

    public func normalize(_ text: String) -> String {
        text
    }
}
