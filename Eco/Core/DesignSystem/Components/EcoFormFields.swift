//
//  EcoFormFields.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Campos de formulario reutilizables: placeholder legible sobre fondo accent y texto con primaryText.
//

import SwiftUI
import UIKit

enum EcoFormFieldMetrics {
    /// Placeholder con primaryText semitransparente para que no se confunda con el verde del fondo.
    static let placeholderOpacity: Double = 0.55
}

/// Campo de texto con estilo Eco y `prompt` estilizado (evita el tint accent en el placeholder).
struct EcoTextField: View {
    private var placeholder: LocalizedStringKey
    private var accessibilityLabelKey: LocalizedStringKey?
    @Binding private var text: String
    private var textInputAutocapitalization: TextInputAutocapitalization
    /// No nombrar `keyboardType`: choca con el modificador `View.keyboardType`.
    private var uiKeyboardType: UIKeyboardType
    /// No nombrar `textContentType`: choca con el modificador `View.textContentType`.
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

/// Campo seguro con el mismo criterio de placeholder que `EcoTextField`.
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
