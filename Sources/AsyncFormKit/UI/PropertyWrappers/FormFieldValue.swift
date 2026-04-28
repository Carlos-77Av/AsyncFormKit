//
//  FormFieldValue.swift
//  AsyncFormKit
//
//  Created by Carlos Alvarez on 28/4/26.
//

@propertyWrapper
@MainActor
public final class FormFieldValue {
    private let field: FormField

    public var wrappedValue: String {
        get { field.value }
        set { field.updateValue(newValue) }
    }

    public var projectedValue: FormField {
        field
    }

    public init(
        wrappedValue: String = "",
        configuration: any FieldConfiguration,
        id: String? = nil
    ) {
        self.field = FormField(
            id: id,
            initialValue: wrappedValue,
            configuration: configuration
        )
    }
}
