//
//  FieldValidationPolicy.swift
//  AsyncFormKit
//
//  Created by Carlos Alvarez on 19/4/26.
//

import Foundation

public enum FieldValidationPolicy: Sendable, Equatable {
    case onChange
    case onBlur
    case onChangeDebounced(UInt64)
    case manual
}
