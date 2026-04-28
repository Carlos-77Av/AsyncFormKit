# AsyncFormKit

AsyncFormKit is a lightweight async/await-based form validation library for Swift projects.

It is designed to support modern form flows with reusable validation rules, field-level validation, form-level coordination, and a clean architecture that can grow over time.

## Features

- Async/await-first validation
- Reusable validation rules
- Field-based validation architecture
- Form-wide coordination
- Cross-field validation support
- Debounced validation policies
- SwiftUI-friendly bindings
- Property wrapper support for SwiftUI text fields
- Configurable currency formatting without depending on the current locale
- Clean and extensible design

## Core Concepts

### ValidationRule
Defines reusable validation logic.

### FieldConfiguration
Describes how a field behaves, including:
- rules
- normalization
- validation policy
- keyboard type
- error presentation mode

### FormField
Represents a single field and handles:
- current value
- touched state
- dirty state
- validation state
- error message

### FormFieldValue
Property wrapper that lets a form field read and write like a `String`, while still keeping the underlying `FormField` available for validation.

Use the wrapped value as plain text:

```swift
email = "test@example.com"
print(email)
```

Use the projected value as the underlying `FormField`:

```swift
$email.isValid
$email.errorMessage
```

Use the field binding with SwiftUI inputs:

```swift
TextField("Email", text: $email.binding)
```

Currency fields keep a clean canonical value while showing a formatted value in the text field:

```swift
@FormFieldValue(configuration: CurrencyFieldConfiguration(format: .usd))
var amount = ""
```

For live cent-based currency masking while the field is focused, use `FormFieldTextField`:

```swift
FormFieldTextField("Amount", field: $amount)

// Typing 3 displays "$ 0.03"
// Then typing 9 displays "$ 0.39"
// Then typing 7 displays "$ 3.97"
```

For delayed cent-based formatting, use `DebouncedFormFieldTextField`:

```swift
DebouncedFormFieldTextField(
    "Amount",
    field: $amount,
    debounceDelay: 0.8
)

// Typing 452342 stays editable while typing.
// After 0.8 seconds it displays "$ 4,523.42"
// amount remains "4523.42"
```

If you need a custom `TextField` design, keep your own `TextField` and add the formatting modifier:

```swift
TextField("Amount", text: $amount.binding)
    .font(.title2)
    .padding()
    .formFieldFormatting(
        $amount,
        mode: .debounced(delay: 0.8)
    )

// Typing 452342 stays editable while typing.
// After 0.8 seconds it displays "$ 4,523.42"
```

Register fields in a form with the projected value:

```swift
FormCoordinator(fields: [$email])
```

### FormCoordinator
Coordinates all fields in a form and exposes:
- form validity
- form validation state
- aggregated error text

### FieldValidator
Runs validation rules and builds the final error output.

## SwiftUI Example

```swift
import AsyncFormKit
import Observation
import SwiftUI

@MainActor
final class SignInViewModel {
    @FormFieldValue(configuration: EmailFieldConfiguration())
    var email = ""

    @FormFieldValue(configuration: PasswordFieldConfiguration())
    var password = ""

    lazy var form = FormCoordinator(
        fields: [
            $email,
            $password
        ]
    )

    init() {
        form.activate()
    }

    func signIn() async {
        await form.validateAllFields()

        guard form.isFormValid else { return }

        // Continue with your sign-in flow.
    }
}

struct SignInView: View {
    @State private var viewModel = SignInViewModel()

    var body: some View {
        Form {
            TextField("Email", text: viewModel.$email.binding)
                .keyboardType(.emailAddress)

            SecureField("Password", text: viewModel.$password.binding)

            Button("Sign In") {
                Task {
                    await viewModel.signIn()
                }
            }
        }
    }
}
```

With `@FormFieldValue`, the field value is used like a normal `String`. You do not need to call `.value` to read it or `.updateValue(...)` to change it.

## Manual Example

```swift
let emailField = FormField(configuration: EmailFieldConfiguration())
let passwordField = FormField(configuration: PasswordFieldConfiguration())
let confirmField = FormField(
    configuration: ConfirmPasswordFieldConfiguration(passwordFieldID: "password")
)

let form = FormCoordinator(
    fields: [emailField, passwordField, confirmField]
)

form.activate()

emailField.updateValue("test@example.com")
passwordField.updateValue("12345678")
confirmField.updateValue("12345678")

await form.validateAllFields()

print(form.isFormValid)
print(form.formErrorMessage)
```

## Project Structure

```text
Sources/
└── AsyncFormKit/
    ├── Core/
    ├── Engine/
    └── UI/
```

## Current Status

This project is currently in active development.

The current version already includes:
- core validation models
- built-in rules
- field validation engine
- form coordination
- SwiftUI binding support
- `@FormFieldValue` property wrapper
- currency field formatting
- initial Swift Testing coverage

## Roadmap

- Improve dependent field revalidation
- Add more built-in rules
- Add remote async validation examples
- Expand test coverage
- Add more SwiftUI convenience helpers

## Goals

AsyncFormKit aims to provide a clean and modern approach to rule-based form validation using async/await, while keeping the architecture flexible, scalable, and easy to integrate into Swift projects.
