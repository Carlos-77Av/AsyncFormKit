//
//  FormNode+Binding.swift
//  AsyncFormKit
//
//  Created by Carlos Alvarez on 19/4/26.
//

import SwiftUI

public extension FormNode {
    var binding: Binding<String> {
        Binding(
            get: { self.textValue },
            set: { self.updateText($0) }
        )
    }
}
