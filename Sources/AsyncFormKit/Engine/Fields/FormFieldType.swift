//
//  FormFieldType.swift
//  AsyncFormKit
//
//  Created by Carlos Alvarez on 19/4/26.
//

import Foundation

@MainActor
public protocol FormFieldType: AnyObject {
    var id: String { get }
    var label: String { get }
    var value: String { get }
    var status: FieldStatus { get }
    var isValid: Bool { get }
    var errorMessage: String { get }
    var isTouched: Bool { get }
    var isDirty: Bool { get }

    func markAsTouched()
    func updateValue(_ newValue: String)
    func blur()
    func validate(trigger: ValidationTrigger) async
}
