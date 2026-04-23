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

### FormCoordinator
Coordinates all fields in a form and exposes:
- form validity
- form validation state
- aggregated error text

### FieldValidator
Runs validation rules and builds the final error output.

## Example

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
- initial Swift Testing coverage

## Roadmap

- Improve dependent field revalidation
- Add more built-in rules
- Add remote async validation examples
- Expand test coverage
- Add more SwiftUI convenience helpers

## Goals

AsyncFormKit aims to provide a clean and modern approach to rule-based form validation using async/await, while keeping the architecture flexible, scalable, and easy to integrate into Swift projects.
