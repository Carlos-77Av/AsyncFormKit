//
//  FieldStatus.swift
//  AsyncFormKit
//
//  Created by Carlos Alvarez on 19/4/26.
//

import Foundation

public enum FieldStatus: Equatable, Sendable {
    case idle
    case validating
    case valid
    case invalid
}
