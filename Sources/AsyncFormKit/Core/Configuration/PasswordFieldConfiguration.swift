//
//  PasswordFieldConfiguration.swift
//  AsyncFormKit
//
//  Created by Carlos Alvarez on 19/4/26.
//

import Foundation
import UIKit

public struct PasswordFieldConfiguration: FieldConfiguration {
    public let id: String
    public let title: String
    public let rules: [any ValidationRule]
    public let keyboardType: UIKeyboardType
    public let errorPresentationMode: ErrorPresentationMode
    public let validationPolicy: ValidationPolicy

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
        self.errorPresentationMode = .highestPriority
        self.validationPolicy = .onChangeDebounced(300_000_000)
    }

    public func normalize(_ text: String) -> String {
        text
    }
}
