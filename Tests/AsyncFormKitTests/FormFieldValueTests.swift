import SwiftUI
import Testing
@testable import AsyncFormKit

@MainActor
private struct FormFieldValueHarness {
    @FormFieldValue(configuration: EmailFieldConfiguration())
    var email = ""

    var emailBinding: Binding<String> {
        $email.binding
    }

    var emailField: FormField {
        $email
    }
}

private struct TextFieldHarness: View {
    @FormFieldValue(configuration: EmailFieldConfiguration())
    var email = ""

    var body: some View {
        TextField("Email", text: $email.binding)
    }
}

@Test
@MainActor
func updatesTextValue() {
    let harness = FormFieldValueHarness()

    harness.email = " test@example.com "

    #expect(harness.email == "test@example.com")
    #expect(harness.emailField.value == "test@example.com")
    #expect(harness.emailField.isTouched)
    #expect(harness.emailField.isDirty)
}

@Test
@MainActor
func providesTextBinding() {
    let harness = FormFieldValueHarness()
    let binding: Binding<String> = harness.emailBinding

    binding.wrappedValue = "second@example.com"

    #expect(harness.email == "second@example.com")
    #expect(harness.emailField.value == "second@example.com")
}

@Test
@MainActor
func worksInTextField() {
    _ = TextFieldHarness()
}

@Test
@MainActor
func providesFormFieldStatus() async {
    let harness = FormFieldValueHarness()

    #expect(!harness.emailField.isValid)

    harness.email = "test@example.com"
    await harness.emailField.validate(trigger: .manual)

    #expect(harness.emailField.isValid)
    #expect(harness.emailField.errorMessage.isEmpty)
}

@Test
@MainActor
func exposesFormFieldFromOutsideType() {
    let harness = FormFieldValueHarness()
    let field: FormField = harness.$email

    #expect(field.id == "email")
}
