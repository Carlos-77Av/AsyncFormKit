import Testing
@testable import AsyncFormKit

@Test
@MainActor
func testFormSetup() async {
    let emailNode = FormNode(profile: EmailInputProfile())
    let passwordNode = FormNode(profile: PasswordInputProfile())
    let confirmNode = FormNode(
        profile: ConfirmPasswordInputProfile(passwordFieldID: "password")
    )

    let form = FormCoordinator(
        nodes: [emailNode, passwordNode, confirmNode]
    )

    form.activate()

    emailNode.updateText("test@example.com")
    passwordNode.updateText("12345678")
    confirmNode.updateText("12345678")

    await form.validateAll()

    #expect(form.isFormValid)
    #expect(form.formErrorText.isEmpty)
}
