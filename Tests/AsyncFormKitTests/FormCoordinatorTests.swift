import Testing
@testable import AsyncFormKit

@Test
@MainActor
func testFormSetup() async {
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

    #expect(form.isFormValid)
    #expect(form.formErrorMessage.isEmpty)
}
