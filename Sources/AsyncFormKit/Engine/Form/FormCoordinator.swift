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
public final class FormCoordinator: FormCoordinatorProtocol {
    public var isFormValid: Bool
    public var isValidating: Bool
    public var formErrorText: String
    public var nodes: [AnyFormNode]
    public let lineSeparator: String

    public init(
        nodes: [AnyFormNode],
        lineSeparator: String = ": "
    ) {
        self.nodes = nodes
        self.lineSeparator = lineSeparator
        self.isFormValid = false
        self.isValidating = false
        self.formErrorText = ""
    }

    public func activate() {
        for node in nodes {
            if let formNode = node as? FormNode {
                formNode.attach(to: self)
            }
        }
    }

    public func refreshState() async {
        isValidating = nodes.contains(where: { $0.status == .validating })
        isFormValid = !nodes.isEmpty && nodes.allSatisfy(\.isValid)

        if isFormValid {
            formErrorText = ""
            return
        }

        let lines = nodes.compactMap { node -> String? in
            guard !node.errorText.isEmpty else { return nil }
            return "\(node.label)\(lineSeparator)\(node.errorText)"
        }

        formErrorText = lines.joined(separator: "\n")
    }

    public func validateAll() async {
        for node in nodes {
            node.markAsTouched()
            await node.validate(trigger: .onSubmit)
        }

        await refreshState()
    }

    public func currentValues() -> [String: String] {
        Dictionary(uniqueKeysWithValues: nodes.map { ($0.id, $0.textValue) })
    }
}
