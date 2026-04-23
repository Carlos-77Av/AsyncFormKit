//
//  FormCoordinating.swift
//  AsyncFormKit
//
//  Created by Carlos Alvarez on 19/4/26.
//

import Foundation

@MainActor
public protocol FormCoordinating: AnyObject {
    var isFormValid: Bool { get set }
    var isValidating: Bool { get set }
    var formErrorMessage: String { get set }
    var fields: [FormFieldType] { get set }
    var errorLineSeparator: String { get }

    func activate()
    func refreshState() async
    func validateAllFields() async
    func currentFieldValues() -> [String: String]
}
