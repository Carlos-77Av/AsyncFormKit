//
//  FieldConfiguration.swift
//  AsyncFormKit
//
//  Created by Carlos Alvarez on 19/4/26.
//

import Foundation
import UIKit

public protocol FieldConfiguration: Sendable {
    var id: String { get }
    var title: String { get }
    var rules: [any ValidationRule] { get }
    var keyboardType: UIKeyboardType { get }
    var errorPresentationMode: ErrorPresentationMode { get }
    var validationPolicy: ValidationPolicy { get }

    func normalize(_ text: String) -> String
}

public extension FieldConfiguration {
    var keyboardType: UIKeyboardType { .default }
    var errorPresentationMode: ErrorPresentationMode { .joinAll() }
    var validationPolicy: ValidationPolicy { .onChange }

    func normalize(_ text: String) -> String {
        text
    }
}
