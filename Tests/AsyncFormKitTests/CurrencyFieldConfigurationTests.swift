import SwiftUI
import Testing
@testable import AsyncFormKit

private struct ExactValueRule: SyncValidationRule {
    let code: String = "exactValue"
    let message: String = "Value does not match"
    let priority: Int = 100
    let executionKind: RuleExecutionKind = .local
    let expectedValue: String

    func validateSync(
        _ text: String,
        context: ValidationContext
    ) -> Bool {
        text == expectedValue
    }
}

@Test
@MainActor
func formatsUSDCurrencyBindingAsMinorUnits() {
    let field = FormField(
        configuration: CurrencyFieldConfiguration(format: .usd)
    )
    let binding: Binding<String> = field.binding

    binding.wrappedValue = "4000"

    #expect(field.value == "40.00")
    #expect(field.displayValue == "$ 40.00")
    #expect(binding.wrappedValue == "$ 40.00")
}

@Test
@MainActor
func reformatsCurrencyBindingAfterEachTypedDigit() {
    let field = FormField(
        configuration: CurrencyFieldConfiguration(format: .usd)
    )
    let binding: Binding<String> = field.binding

    binding.wrappedValue = "4"
    #expect(field.value == "0.04")
    #expect(binding.wrappedValue == "$ 0.04")

    binding.wrappedValue = "$ 0.040"
    #expect(field.value == "0.40")
    #expect(binding.wrappedValue == "$ 0.40")

    binding.wrappedValue = "$ 0.400"
    #expect(field.value == "4.00")
    #expect(binding.wrappedValue == "$ 4.00")
}

@Test
@MainActor
func formatsCRCCurrencyBindingAsMinorUnits() {
    let field = FormField(
        configuration: CurrencyFieldConfiguration(format: .crc)
    )
    let binding: Binding<String> = field.binding

    binding.wrappedValue = "4000"

    #expect(field.value == "40.00")
    #expect(field.displayValue == "₡ 40,00")
    #expect(binding.wrappedValue == "₡ 40,00")
}

@Test
@MainActor
func clearsCurrencyDisplayToEmptyCanonicalValue() {
    let field = FormField(
        configuration: CurrencyFieldConfiguration(format: .usd)
    )
    let binding: Binding<String> = field.binding

    binding.wrappedValue = "4000"
    binding.wrappedValue = ""

    #expect(field.value.isEmpty)
    #expect(field.displayValue.isEmpty)
    #expect(binding.wrappedValue.isEmpty)
}

@Test
@MainActor
func groupsCurrencyDisplayWithoutUsingLocale() {
    let usdField = FormField(
        initialValue: "1234.56",
        configuration: CurrencyFieldConfiguration(format: .usd)
    )
    let crcField = FormField(
        initialValue: "1234.56",
        configuration: CurrencyFieldConfiguration(format: .crc)
    )

    #expect(usdField.value == "1234.56")
    #expect(usdField.displayValue == "$ 1,234.56")
    #expect(crcField.value == "1234.56")
    #expect(crcField.displayValue == "₡ 1.234,56")
}

@Test
@MainActor
func formatsCurrencyAsMinorUnitsForDebouncedInput() {
    let field = FormField(
        configuration: CurrencyFieldConfiguration(format: .usd)
    )

    field.updateDisplayValue("452342")

    #expect(field.value == "4523.42")
    #expect(field.displayValue == "$ 4,523.42")
}

@Test
@MainActor
func validatesCurrencyUsingCanonicalValue() async {
    let field = FormField(
        configuration: CurrencyFieldConfiguration(
            format: .usd,
            rules: [ExactValueRule(expectedValue: "40.00")]
        )
    )

    field.updateDisplayValue("4000")
    await field.validate(trigger: .manual)

    #expect(field.isValid)
    #expect(field.errorMessage.isEmpty)
}

@Test
@MainActor
func formCoordinatorExposesCanonicalCurrencyValue() {
    let field = FormField(
        configuration: CurrencyFieldConfiguration(format: .usd)
    )
    let form = FormCoordinator(fields: [field])

    field.updateDisplayValue("4000")

    #expect(form.currentFieldValues()["amount"] == "40.00")
}

@Test
@MainActor
func createsFormFieldTextFieldForLiveFormatting() {
    let field = FormField(
        configuration: CurrencyFieldConfiguration(format: .usd)
    )

    _ = FormFieldTextField("Amount", field: field)
}

@Test
@MainActor
func createsDebouncedFormFieldTextFieldForDelayedFormatting() {
    let field = FormField(
        configuration: CurrencyFieldConfiguration(format: .usd)
    )

    _ = DebouncedFormFieldTextField(
        "Amount",
        field: field,
        debounceDelay: 0.8
    )
}

private struct FormFieldFormattingModifierHarness: View {
    let field: FormField

    var body: some View {
        TextField("Amount", text: field.binding)
            .formFieldFormatting(
                field,
                mode: .debounced(delay: 0.8)
            )
    }
}

@Test
@MainActor
func createsFormFieldFormattingModifierForCustomTextFieldDesigns() {
    let field = FormField(
        configuration: CurrencyFieldConfiguration(format: .usd)
    )

    _ = FormFieldFormattingModifierHarness(field: field)
}
