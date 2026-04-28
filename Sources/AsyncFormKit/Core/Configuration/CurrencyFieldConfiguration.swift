//
//  CurrencyFieldConfiguration.swift
//  AsyncFormKit
//
//  Created by Carlos Alvarez on 28/4/26.
//

import Foundation
import UIKit

public struct CurrencyFormat: Sendable, Equatable {
    public let symbol: String
    public let decimalSeparator: String
    public let groupingSeparator: String
    public let fractionDigits: Int

    public init(
        symbol: String,
        decimalSeparator: String,
        groupingSeparator: String,
        fractionDigits: Int = 2
    ) {
        self.symbol = symbol
        self.decimalSeparator = decimalSeparator
        self.groupingSeparator = groupingSeparator
        self.fractionDigits = max(0, fractionDigits)
    }

    public static let usd = CurrencyFormat(
        symbol: "$",
        decimalSeparator: ".",
        groupingSeparator: ","
    )

    public static let crc = CurrencyFormat(
        symbol: "₡",
        decimalSeparator: ",",
        groupingSeparator: "."
    )
}

public struct CurrencyFieldConfiguration: FieldConfiguration {
    public let id: String
    public let title: String
    public let rules: [any ValidationRule]
    public let keyboardType: UIKeyboardType
    public let errorPresentationMode: ErrorPresentationMode
    public let validationPolicy: ValidationPolicy
    public let format: CurrencyFormat

    public init(
        id: String = "amount",
        title: String = "Amount",
        format: CurrencyFormat = .usd,
        rules: [any ValidationRule] = [],
        errorPresentationMode: ErrorPresentationMode = .joinAll(),
        validationPolicy: ValidationPolicy = .onChange
    ) {
        self.id = id
        self.title = title
        self.format = format
        self.rules = rules
        self.keyboardType = .numberPad
        self.errorPresentationMode = errorPresentationMode
        self.validationPolicy = validationPolicy
    }

    public func normalize(_ text: String) -> String {
        format.canonicalValue(fromMajorUnitText: text)
    }

    public func normalizeDisplayText(_ text: String) -> String {
        format.canonicalValue(fromMinorUnitText: text)
    }

    public func displayText(for value: String) -> String {
        format.displayText(for: value)
    }
}

private extension CurrencyFormat {
    func canonicalValue(fromMinorUnitText text: String) -> String {
        let digits = decimalDigits(in: text)
        guard !digits.isEmpty else { return "" }

        if fractionDigits == 0 {
            return normalizedInteger(digits)
        }

        let minimumLength = fractionDigits + 1
        let paddingCount = max(0, minimumLength - digits.count)
        let paddedDigits = String(repeating: "0", count: paddingCount) + digits
        let splitIndex = paddedDigits.index(
            paddedDigits.endIndex,
            offsetBy: -fractionDigits
        )
        let integer = normalizedInteger(String(paddedDigits[..<splitIndex]))
        let fraction = String(paddedDigits[splitIndex...])

        return "\(integer).\(fraction)"
    }

    func canonicalValue(fromMajorUnitText text: String) -> String {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return "" }

        let separator = resolvedDecimalSeparator(in: trimmed)
        let integerText: String
        let fractionText: String

        if let separator,
           let separatorIndex = trimmed.lastIndex(of: separator) {
            integerText = String(trimmed[..<separatorIndex])
            fractionText = String(trimmed[trimmed.index(after: separatorIndex)...])
        } else {
            integerText = trimmed
            fractionText = ""
        }

        let integerDigits = decimalDigits(in: integerText)
        let fractionDigitsText = decimalDigits(in: fractionText)

        guard !integerDigits.isEmpty || !fractionDigitsText.isEmpty else {
            return ""
        }

        let integer = normalizedInteger(integerDigits)
        guard fractionDigits > 0 else { return integer }

        return "\(integer).\(normalizedFraction(fractionDigitsText))"
    }

    func displayText(for value: String) -> String {
        let canonicalValue = canonicalValue(fromMajorUnitText: value)
        guard !canonicalValue.isEmpty else { return "" }

        let components = canonicalValue.split(
            separator: ".",
            maxSplits: 1,
            omittingEmptySubsequences: false
        )
        let integer = components.first.map(String.init) ?? "0"
        let groupedInteger = groupedInteger(integer)

        guard fractionDigits > 0 else {
            return "\(symbol) \(groupedInteger)"
        }

        let fraction = components.count > 1
            ? String(components[1])
            : String(repeating: "0", count: fractionDigits)

        return "\(symbol) \(groupedInteger)\(decimalSeparator)\(fraction)"
    }

    func resolvedDecimalSeparator(in text: String) -> Character? {
        if let configuredSeparator = decimalSeparator.first,
           text.contains(configuredSeparator) {
            return configuredSeparator
        }

        guard decimalSeparator != ".",
              let dotIndex = text.lastIndex(of: ".") else {
            return nil
        }

        let textAfterDot = String(text[text.index(after: dotIndex)...])
        let trailingDigitCount = decimalDigits(in: textAfterDot).count

        if trailingDigitCount > 0 && trailingDigitCount <= fractionDigits {
            return "."
        }

        return nil
    }

    func decimalDigits(in text: String) -> String {
        var digits = ""

        for character in text {
            if let wholeNumberValue = character.wholeNumberValue {
                digits += String(wholeNumberValue)
            }
        }

        return digits
    }

    func normalizedInteger(_ digits: String) -> String {
        let strippedDigits = digits.drop(while: { $0 == "0" })
        return strippedDigits.isEmpty ? "0" : String(strippedDigits)
    }

    func normalizedFraction(_ digits: String) -> String {
        let paddingCount = max(0, fractionDigits - digits.count)
        let paddedDigits = digits + String(repeating: "0", count: paddingCount)
        return String(paddedDigits.prefix(fractionDigits))
    }

    func groupedInteger(_ integer: String) -> String {
        guard !groupingSeparator.isEmpty else { return integer }

        var grouped = ""
        var digitCount = 0

        for digit in integer.reversed() {
            if digitCount > 0 && digitCount.isMultiple(of: 3) {
                grouped.insert(contentsOf: groupingSeparator, at: grouped.startIndex)
            }

            grouped.insert(digit, at: grouped.startIndex)
            digitCount += 1
        }

        return grouped
    }
}
