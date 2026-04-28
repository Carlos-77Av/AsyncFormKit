//
//  FormField+Binding.swift
//  AsyncFormKit
//
//  Created by Carlos Alvarez on 19/4/26.
//

import SwiftUI

public extension FormField {
    var binding: Binding<String> {
        Binding(
            get: { self.displayValue },
            set: { self.updateDisplayValue($0) }
        )
    }
}
