//
//  ConfirmPasswordFieldConfiguration.swift
//  AsyncFormKit
//
//  Created by Carlos Alvarez on 19/4/26.
//

import Foundation
import UIKit

public struct ConfirmPasswordFieldConfiguration: FieldConfiguration {
    public let id: String
    public let title: String
    public let rules: [any ValidationRule]
    public let keyboardType: UIKeyboardType
    public let errorPresentationMode: ErrorPresentationMode
    public let validationPolicy: ValidationPolicy

    public init(
        id: String = "confirmPassword",
        title: String = "Confirm Password",
        passwordFieldID: String = "password"
    ) {
        self.id = id
        self.title = title
        self.rules = [
            RequiredRule(message: "Please confirm your password"),
            MatchOtherFieldRule(
                otherFieldID: passwordFieldID,
                message: "Passwords do not match"
            )
        ]
        self.keyboardType = .default
        self.errorPresentationMode = .highestPriority
        self.validationPolicy = .onChangeDebounced(300_000_000)
    }

    public func normalize(_ text: String) -> String {
        text
    }
}
