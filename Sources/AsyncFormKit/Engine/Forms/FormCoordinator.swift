//
//  FormCoordinator.swift
//  AsyncFormKit
//
//  Created by Carlos Alvarez on 19/4/26.
//

import Foundation
import Observation

@MainActor
@Observable
public final class FormCoordinator: FormCoordinating {
    public var isFormValid: Bool
    public var isValidating: Bool
    public var formErrorMessage: String
    public var fields: [FormFieldType]
    public let errorLineSeparator: String

    public init(
        fields: [FormFieldType],
        errorLineSeparator: String = ": "
    ) {
        self.fields = fields
        self.errorLineSeparator = errorLineSeparator
        self.isFormValid = false
        self.isValidating = false
        self.formErrorMessage = ""
    }

    public func activate() {
        for field in fields {
            if let formField = field as? FormField {
                formField.attach(to: self)
            }
        }
    }

    public func refreshState() async {
        isValidating = fields.contains(where: { $0.status == .validating })
        isFormValid = !fields.isEmpty && fields.allSatisfy(\.isValid)

        if isFormValid {
            formErrorMessage = ""
            return
        }

        let lines = fields.compactMap { field -> String? in
            guard !field.errorMessage.isEmpty else { return nil }
            return "\(field.label)\(errorLineSeparator)\(field.errorMessage)"
        }

        formErrorMessage = lines.joined(separator: "\n")
    }

    public func validateAllFields() async {
        for field in fields {
            field.markAsTouched()
            await field.validate(trigger: .onSubmit)
        }

        await refreshState()
    }

    public func currentFieldValues() -> [String: String] {
        Dictionary(uniqueKeysWithValues: fields.map { ($0.id, $0.value) })
    }
}
