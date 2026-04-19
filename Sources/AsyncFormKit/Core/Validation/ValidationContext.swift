//
//  Untitled.swift
//  AsyncFormKit
//
//  Created by Carlos Alvarez on 19/4/26.
//

import Foundation

public struct ValidationContext: Sendable {
    public let valuesByID: [String: String]
    public let trigger: ValidationTrigger

    public init(
        valuesByID: [String: String],
        trigger: ValidationTrigger
    ) {
        self.valuesByID = valuesByID
        self.trigger = trigger
    }

    public func value(for fieldID: String) -> String {
        valuesByID[fieldID] ?? ""
    }
}
