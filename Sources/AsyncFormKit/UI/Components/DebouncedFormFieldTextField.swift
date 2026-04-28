//
//  DebouncedFormFieldTextField.swift
//  AsyncFormKit
//
//  Created by Carlos Alvarez on 28/4/26.
//

import Foundation
import SwiftUI
import UIKit

public struct DebouncedFormFieldTextField: UIViewRepresentable {
    private let title: String
    private let field: FormField
    private let debounceDelay: TimeInterval

    public init(
        _ title: String,
        field: FormField,
        debounceDelay: TimeInterval = 0.8
    ) {
        self.title = title
        self.field = field
        self.debounceDelay = debounceDelay
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
        context.coordinator.debounceDelay = debounceDelay

        textField.placeholder = title
        textField.keyboardType = field.configuration.keyboardType

        guard !context.coordinator.hasPendingText,
              textField.text != field.displayValue else {
            return
        }

        textField.text = field.displayValue
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(
            field: field,
            debounceDelay: debounceDelay
        )
    }

    @MainActor
    public final class Coordinator: NSObject, UITextFieldDelegate {
        var field: FormField
        var debounceDelay: TimeInterval
        var hasPendingText: Bool {
            pendingText != nil
        }

        private var pendingText: String?
        private var debounceTask: Task<Void, Never>?

        init(
            field: FormField,
            debounceDelay: TimeInterval
        ) {
            self.field = field
            self.debounceDelay = debounceDelay
        }

        deinit {
            debounceTask?.cancel()
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

            pendingText = proposedText
            scheduleDebouncedFormatting(for: textField)

            return true
        }

        public func textFieldDidEndEditing(_ textField: UITextField) {
            applyPendingText(to: textField)
            field.blur()
        }

        public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            applyPendingText(to: textField)
            textField.resignFirstResponder()
            return false
        }

        private func scheduleDebouncedFormatting(for textField: UITextField) {
            debounceTask?.cancel()

            let delay = max(0, debounceDelay)
            debounceTask = Task { [weak self, weak textField] in
                let nanoseconds = UInt64(delay * 1_000_000_000)
                try? await Task.sleep(nanoseconds: nanoseconds)

                guard !Task.isCancelled,
                      let self,
                      let textField else {
                    return
                }

                await MainActor.run {
                    self.applyPendingText(to: textField)
                }
            }
        }

        private func applyPendingText(to textField: UITextField) {
            debounceTask?.cancel()

            let text = pendingText ?? textField.text ?? ""
            pendingText = nil

            field.updateDisplayValue(text)
            textField.text = field.displayValue
            moveCursorToEnd(in: textField)
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
