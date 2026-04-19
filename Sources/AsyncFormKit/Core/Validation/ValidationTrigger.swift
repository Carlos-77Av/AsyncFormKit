//
//  ValidationTrigger.swift
//  AsyncFormKit
//
//  Created by Carlos Alvarez on 19/4/26.
//

import Foundation

public enum ValidationTrigger: Sendable {
    case onChange
    case onBlur
    case onSubmit
    case manual
}
