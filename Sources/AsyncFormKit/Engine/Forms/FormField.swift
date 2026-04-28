//
//  FormField.swift
//  AsyncFormKit
//
//  Created by Carlos Alvarez on 19/4/26.
//

import Foundation
import Observation

@MainActor
@Observable
public final class FormField: FormFieldType {
    public let id: String
    public let label: String
    public let configuration: any FieldConfiguration

    public private(set) var value: String
    public private(set) var displayValue: String
    public private(set) var status: FieldStatus
    public private(set) var errorMessage: String
    public private(set) var failedRules: [any ValidationRule]
    public private(set) var isTouched: Bool
    public private(set) var isDirty: Bool

    public var isValid: Bool {
        status == .valid
    }

    private let validator: any FieldValidating
    private weak var coordinator: FormCoordinating?
    private var validationTask: Task<Void, Never>?

    public init(
        id: String? = nil,
        initialValue: String = "",
        configuration: any FieldConfiguration,
        validator: any FieldValidating = FieldValidator()
    ) {
        let normalizedValue = configuration.normalize(initialValue)

        self.id = id ?? configuration.id
        self.label = configuration.title
        self.configuration = configuration
        self.value = normalizedValue
        self.displayValue = configuration.displayText(for: normalizedValue)
        self.status = .idle
        self.errorMessage = ""
        self.failedRules = []
        self.isTouched = !initialValue.isEmpty
        self.isDirty = false
        self.validator = validator
    }

    public func attach(to coordinator: FormCoordinating) {
        self.coordinator = coordinator
    }

    public func markAsTouched() {
        isTouched = true
    }

    public func updateValue(_ newValue: String) {
        let normalized = configuration.normalize(newValue)
        updateStoredValue(normalized)
    }

    public func updateDisplayValue(_ newValue: String) {
        let normalized = configuration.normalizeDisplayText(newValue)
        updateStoredValue(normalized)
    }

    public func blur() {
        isTouched = true
        scheduleValidationIfNeeded(for: .onBlur)
    }

    public func validate(trigger: ValidationTrigger) async {
        validationTask?.cancel()
        await performValidation(trigger: trigger)
    }

    private func performValidation(trigger: ValidationTrigger) async {
        status = .validating

        let values = coordinator?.currentFieldValues() ?? [id: value]
        let context = ValidationContext(
            valuesByID: values,
            trigger: trigger
        )

        let result = await validator.validate(
            value: value,
            rules: configuration.rules,
            context: context
        )

        guard !Task.isCancelled else { return }

        failedRules = result.failedRules
        status = result.isValid ? .valid : .invalid

        if isTouched {
            errorMessage = validator.buildErrorMessage(
                from: result.failedRules,
                mode: configuration.errorPresentationMode
            )
        } else {
            errorMessage = ""
        }

        await coordinator?.refreshState()
    }

    private func updateStoredValue(_ normalized: String) {
        let displayText = configuration.displayText(for: normalized)
        guard normalized != value || displayText != displayValue else { return }

        value = normalized
        displayValue = displayText
        isTouched = true
        isDirty = true

        scheduleValidationIfNeeded(for: .onChange)
    }

    private func scheduleValidationIfNeeded(for trigger: ValidationTrigger) {
        switch (configuration.validationPolicy, trigger) {
        case (.manual, _):
            return

        case (.onBlur, .onChange):
            return

        case (.onChange, .onChange),
             (.onBlur, .onBlur):
            launchValidationTask(trigger: trigger, delay: nil)

        case let (.onChangeDebounced(delay), .onChange):
            launchValidationTask(trigger: trigger, delay: delay)

        case (_, .onSubmit), (_, .manual), (_, .onBlur):
            launchValidationTask(trigger: trigger, delay: nil)

        default:
            return
        }
    }

    private func launchValidationTask(
        trigger: ValidationTrigger,
        delay: UInt64?
    ) {
        validationTask?.cancel()

        validationTask = Task { [weak self] in
            guard let self else { return }

            if let delay {
                try? await Task.sleep(nanoseconds: delay)
            }

            guard !Task.isCancelled else { return }
            await self.performValidation(trigger: trigger)
        }
    }
}
