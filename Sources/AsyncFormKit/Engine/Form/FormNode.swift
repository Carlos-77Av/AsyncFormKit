//
//  FormNode.swift
//  AsyncFormKit
//
//  Created by Carlos Alvarez on 19/4/26.
//

import Foundation
import Observation

@MainActor
@Observable
public final class FormNode: AnyFormNode {
    public let id: String
    public let label: String
    public let profile: any InputProfile

    public private(set) var textValue: String
    public private(set) var status: FieldStatus
    public private(set) var errorText: String
    public private(set) var brokenRules: [any InputRule]
    public private(set) var hasBeenTouched: Bool
    public private(set) var isDirty: Bool

    public var isValid: Bool {
        status == .valid
    }

    private let checker: any FieldChecking
    private weak var coordinator: FormCoordinatorProtocol?
    private var validationTask: Task<Void, Never>?

    public init(
        id: String? = nil,
        initialValue: String = "",
        profile: any InputProfile,
        checker: any FieldChecking = FieldChecker()
    ) {
        self.id = id ?? profile.id
        self.label = profile.title
        self.profile = profile
        self.textValue = profile.normalize(initialValue)
        self.status = .idle
        self.errorText = ""
        self.brokenRules = []
        self.hasBeenTouched = !initialValue.isEmpty
        self.isDirty = false
        self.checker = checker
    }

    public func attach(to coordinator: FormCoordinatorProtocol) {
        self.coordinator = coordinator
    }

    public func markAsTouched() {
        hasBeenTouched = true
    }

    public func updateText(_ newValue: String) {
        let normalized = profile.normalize(newValue)
        guard normalized != textValue else { return }

        textValue = normalized
        hasBeenTouched = true
        isDirty = true

        scheduleValidationIfNeeded(for: .onChange)
    }

    public func blur() {
        hasBeenTouched = true
        scheduleValidationIfNeeded(for: .onBlur)
    }

    public func validate(trigger: ValidationTrigger) async {
        validationTask?.cancel()
        await performValidation(trigger: trigger)
    }

    private func performValidation(trigger: ValidationTrigger) async {
        status = .validating

        let values = coordinator?.currentValues() ?? [id: textValue]
        let context = ValidationContext(
            valuesByID: values,
            trigger: trigger
        )

        let summary = await checker.validate(
            text: textValue,
            rules: profile.rules,
            context: context
        )

        guard !Task.isCancelled else { return }

        brokenRules = summary.brokenRules
        status = summary.isValid ? .valid : .invalid

        if hasBeenTouched {
            errorText = checker.buildError(
                from: summary.brokenRules,
                mode: profile.validationMode
            )
        } else {
            errorText = ""
        }

        await coordinator?.refreshState()
    }

    private func scheduleValidationIfNeeded(for trigger: ValidationTrigger) {
        switch (profile.validationPolicy, trigger) {
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
