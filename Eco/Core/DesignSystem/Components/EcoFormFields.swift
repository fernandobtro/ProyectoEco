//
//  EcoFormFields.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Purpose: Reusable form fields: readable placeholder on accent backgrounds, text uses `primaryText`.
//

import SwiftUI
import UIKit

/// Opacity for prompt text so it reads clearly on green accent without using the accent tint.
enum EcoFormFieldMetrics {
    /// Semi-transparent `primaryText` for placeholders (distinct from the accent fill).
    static let placeholderOpacity: Double = 0.55
}

/// Styled `TextField` with a custom `prompt` (avoids system accent tint on placeholder text).
struct EcoTextField: View {
    private var placeholder: LocalizedStringKey
    private var accessibilityLabelKey: LocalizedStringKey?
    @Binding private var text: String
    private var textInputAutocapitalization: TextInputAutocapitalization
    /// Named `uiKeyboardType` to avoid clashing with `View.keyboardType`.
    private var uiKeyboardType: UIKeyboardType
    /// Named `uiTextContentType` to avoid clashing with `View.textContentType`.
    private var uiTextContentType: UITextContentType?

    init(
        _ placeholder: LocalizedStringKey,
        text: Binding<String>,
        accessibilityLabel: LocalizedStringKey? = nil,
        textInputAutocapitalization: TextInputAutocapitalization = .sentences,
        keyboardType: UIKeyboardType = .default,
        textContentType: UITextContentType? = nil
    ) {
        self.placeholder = placeholder
        self._text = text
        self.accessibilityLabelKey = accessibilityLabel
        self.textInputAutocapitalization = textInputAutocapitalization
        self.uiKeyboardType = keyboardType
        self.uiTextContentType = textContentType
    }

    var body: some View {
        TextField("", text: $text, prompt: prompt)
            .ecoTextFieldStyle()
            .textInputAutocapitalization(textInputAutocapitalization)
            .keyboardType(uiKeyboardType)
            .modifier(OptionalUITextContentTypeModifier(uiTextContentType: uiTextContentType))
            .accessibilityLabel(accessibilityLabelKey ?? placeholder)
    }

    private var prompt: Text {
        Text(placeholder)
            .foregroundStyle(Color.theme.primaryText.opacity(EcoFormFieldMetrics.placeholderOpacity))
    }
}

/// Secure field using the same placeholder styling as ``EcoTextField``.
struct EcoSecureField: View {
    private var placeholder: LocalizedStringKey
    private var accessibilityLabelKey: LocalizedStringKey?
    @Binding private var text: String
    private var uiTextContentType: UITextContentType?

    init(
        _ placeholder: LocalizedStringKey,
        text: Binding<String>,
        accessibilityLabel: LocalizedStringKey? = nil,
        textContentType: UITextContentType? = .password
    ) {
        self.placeholder = placeholder
        self._text = text
        self.accessibilityLabelKey = accessibilityLabel
        self.uiTextContentType = textContentType
    }

    var body: some View {
        SecureField("", text: $text, prompt: prompt)
            .ecoTextFieldStyle()
            .modifier(OptionalUITextContentTypeModifier(uiTextContentType: uiTextContentType))
            .accessibilityLabel(accessibilityLabelKey ?? placeholder)
    }

    private var prompt: Text {
        Text(placeholder)
            .foregroundStyle(Color.theme.primaryText.opacity(EcoFormFieldMetrics.placeholderOpacity))
    }
}

private struct OptionalUITextContentTypeModifier: ViewModifier {
    var uiTextContentType: UITextContentType?

    @ViewBuilder
    func body(content: Content) -> some View {
        if let type = uiTextContentType {
            content.textContentType(type)
        } else {
            content
        }
    }
}
