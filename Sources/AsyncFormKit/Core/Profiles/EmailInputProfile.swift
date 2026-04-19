//
//  EmailInputProfile.swift
//  AsyncFormKit
//
//  Created by Carlos Alvarez on 19/4/26.
//

import Foundation
import UIKit

public struct EmailInputProfile: InputProfile {
    public let id: String
    public let title: String
    public let rules: [any InputRule]
    public let keyboardType: UIKeyboardType
    public let validationMode: ValidationMode
    public let validationPolicy: FieldValidationPolicy

    public init(
        id: String = "email",
        title: String = "Email"
    ) {
        self.id = id
        self.title = title
        self.rules = [
            RequiredRule(message: "Email is required"),
            EmailRule(message: "Please enter a valid email")
        ]
        self.keyboardType = .emailAddress
        self.validationMode = .highestPriority
        self.validationPolicy = .onChangeDebounced(300_000_000)
    }

    public func normalize(_ text: String) -> String {
        text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
