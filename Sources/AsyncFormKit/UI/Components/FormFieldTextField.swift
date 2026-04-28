//
//  FormFieldTextField.swift
//  AsyncFormKit
//
//  Created by Carlos Alvarez on 28/4/26.
//

import SwiftUI
import UIKit

public struct FormFieldTextField: UIViewRepresentable {
    private let title: String
    private let field: FormField

    public init(
        _ title: String,
        field: FormField
    ) {
        self.title = title
        self.field = field
    }

    public func makeUIView(context: Context) -> UITextField {
        let textField = UITextField(frame: .zero)
        textField.placeholder = title
        textField.keyboardType = field.configuration.keyboardType
        textField.delegate = context.coordinator
        textField.text = field.displayValue

        return textField
    }

    public func updateUIView(
        _ textField: UITextField,
        context: Context
    ) {
        context.coordinator.field = field

        textField.placeholder = title
        textField.keyboardType = field.configuration.keyboardType

        guard textField.text != field.displayValue else { return }
        textField.text = field.displayValue
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(field: field)
    }

    @MainActor
    public final class Coordinator: NSObject, UITextFieldDelegate {
        var field: FormField

        init(field: FormField) {
            self.field = field
        }

        public func textField(
            _ textField: UITextField,
            shouldChangeCharactersIn range: NSRange,
            replacementString string: String
        ) -> Bool {
            let currentText = textField.text ?? ""

            guard let textRange = Range(range, in: currentText) else {
                return false
            }

            let proposedText = currentText.replacingCharacters(
                in: textRange,
                with: string
            )

            field.updateDisplayValue(proposedText)
            textField.text = field.displayValue
            moveCursorToEnd(in: textField)

            return false
        }

        public func textFieldDidEndEditing(_ textField: UITextField) {
            field.blur()
            textField.text = field.displayValue
        }

        public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder()
            return false
        }

        private func moveCursorToEnd(in textField: UITextField) {
            let endPosition = textField.endOfDocument
            textField.selectedTextRange = textField.textRange(
                from: endPosition,
                to: endPosition
            )
        }
    }
}
