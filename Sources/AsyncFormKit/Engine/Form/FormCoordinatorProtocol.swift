//
//  FormCoordinatorProtocol.swift
//  AsyncFormKit
//
//  Created by Carlos Alvarez on 19/4/26.
//

import Foundation

@MainActor
public protocol FormCoordinatorProtocol: AnyObject {
    var isFormValid: Bool { get set }
    var isValidating: Bool { get set }
    var formErrorText: String { get set }
    var nodes: [AnyFormNode] { get set }
    var lineSeparator: String { get }

    func activate()
    func refreshState() async
    func validateAll() async
    func currentValues() -> [String: String]
}
