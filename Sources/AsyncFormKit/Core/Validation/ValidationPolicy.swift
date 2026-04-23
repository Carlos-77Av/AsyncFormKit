//
//  ValidationPolicy.swift
//  AsyncFormKit
//
//  Created by Carlos Alvarez on 19/4/26.
//

import Foundation

public enum ValidationPolicy: Sendable, Equatable {
    case onChange
    case onBlur
    case onChangeDebounced(UInt64)
    case manual
}
