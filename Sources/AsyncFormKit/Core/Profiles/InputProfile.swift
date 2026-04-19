//
//  InputProfile.swift
//  AsyncFormKit
//
//  Created by Carlos Alvarez on 19/4/26.
//

import Foundation
import UIKit

public protocol InputProfile: Sendable {
    var id: String { get }
    var title: String { get }
    var rules: [any InputRule] { get }
    var keyboardType: UIKeyboardType { get }
    var validationMode: ValidationMode { get }
    var validationPolicy: FieldValidationPolicy { get }

    func normalize(_ text: String) -> String
}

public extension InputProfile {
    var keyboardType: UIKeyboardType { .default }
    var validationMode: ValidationMode { .joinAll() }
    var validationPolicy: FieldValidationPolicy { .onChange }

    func normalize(_ text: String) -> String {
        text
    }
}
