//
//  FormFieldFormattingModifier.swift
//  AsyncFormKit
//
//  Created by Carlos Alvarez on 28/4/26.
//

import Foundation
import SwiftUI
import UIKit

public enum FormFieldFormattingMode: Sendable, Equatable {
    case live
    case debounced(delay: TimeInterval)
}

public extension View {
    func formFieldFormatting(
        _ field: FormField,
        mode: FormFieldFormattingMode = .live
    ) -> some View {
        modifier(
            FormFieldFormattingModifier(
                field: field,
                mode: mode
            )
        )
    }
}

private struct FormFieldFormattingModifier: ViewModifier {
    let field: FormField
    let mode: FormFieldFormattingMode

    func body(content: Content) -> some View {
        content.background(
            FormFieldFormattingConnector(
                field: field,
                mode: mode
            )
        )
    }
}

private struct FormFieldFormattingConnector: UIViewRepresentable {
    let field: FormField
    let mode: FormFieldFormattingMode

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        view.isHidden = true
        view.isUserInteractionEnabled = false

        return view
    }

    func updateUIView(
        _ uiView: UIView,
        context: Context
    ) {
        context.coordinator.field = field
        context.coordinator.mode = mode

        DispatchQueue.main.async {
            context.coordinator.attach(from: uiView)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(
            field: field,
            mode: mode
        )
    }

    static func dismantleUIView(
        _ uiView: UIView,
        coordinator: Coordinator
    ) {
        DispatchQueue.main.async {
            coordinator.detach()
        }
    }

    @MainActor
    final class Coordinator: NSObject {
        var field: FormField
        var mode: FormFieldFormattingMode

        private weak var textField: UITextField?
        private var pendingText: String?
        private var debounceTask: Task<Void, Never>?
        private var isApplyingFormattedText = false

        init(
            field: FormField,
            mode: FormFieldFormattingMode
        ) {
            self.field = field
            self.mode = mode
        }

        func attach(from markerView: UIView) {
            guard let foundTextField = markerView.nearestTextField(),
                  foundTextField !== textField else {
                return
            }

            detach()
            textField = foundTextField

            foundTextField.addTarget(
                self,
                action: #selector(textDidChange(_:)),
                for: .editingChanged
            )

            foundTextField.addTarget(
                self,
                action: #selector(editingDidEnd(_:)),
                for: .editingDidEnd
            )
        }

        @objc
        private func textDidChange(_ sender: UITextField) {
            guard !isApplyingFormattedText else { return }

            switch mode {
            case .live:
                field.updateDisplayValue(sender.text ?? "")
                applyFormattedText(to: sender)

            case .debounced:
                pendingText = sender.text ?? ""
                scheduleDebouncedFormatting(for: sender)
            }
        }

        @objc
        private func editingDidEnd(_ sender: UITextField) {
            applyPendingText(to: sender)
            field.blur()
        }

        func detach() {
            debounceTask?.cancel()
            pendingText = nil

            if let textField {
                textField.removeTarget(
                    self,
                    action: #selector(textDidChange(_:)),
                    for: .editingChanged
                )

                textField.removeTarget(
                    self,
                    action: #selector(editingDidEnd(_:)),
                    for: .editingDidEnd
                )
            }

            textField = nil
        }

        private func scheduleDebouncedFormatting(for textField: UITextField) {
            debounceTask?.cancel()

            let delay = switch mode {
            case .live:
                TimeInterval.zero
            case .debounced(let delay):
                max(0, delay)
            }

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

            guard let text = pendingText else { return }
            pendingText = nil

            field.updateDisplayValue(text)
            applyFormattedText(to: textField)
        }

        private func applyFormattedText(to textField: UITextField) {
            isApplyingFormattedText = true
            textField.text = field.displayValue
            moveCursorToEnd(in: textField)
            isApplyingFormattedText = false
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

private extension UIView {
    func nearestTextField() -> UITextField? {
        var currentView: UIView? = self

        while let view = currentView {
            if let textField = view.firstDescendantTextField() {
                return textField
            }

            currentView = view.superview
        }

        return nil
    }

    func firstDescendantTextField() -> UITextField? {
        if let textField = self as? UITextField {
            return textField
        }

        for subview in subviews {
            if let textField = subview.firstDescendantTextField() {
                return textField
            }
        }

        return nil
    }
}
