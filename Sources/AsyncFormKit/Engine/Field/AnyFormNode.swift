//
//  AnyFormNode.swift
//  AsyncFormKit
//
//  Created by Carlos Alvarez on 19/4/26.
//

import Foundation

@MainActor
public protocol AnyFormNode: AnyObject {
    var id: String { get }
    var label: String { get }
    var textValue: String { get }
    var status: FieldStatus { get }
    var isValid: Bool { get }
    var errorText: String { get }
    var hasBeenTouched: Bool { get }
    var isDirty: Bool { get }

    func markAsTouched()
    func updateText(_ newValue: String)
    func blur()
    func validate(trigger: ValidationTrigger) async
}
