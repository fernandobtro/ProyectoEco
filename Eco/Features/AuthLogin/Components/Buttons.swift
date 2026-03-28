//
//  Buttons.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Created by Fernando Buenrostro on 17/03/26.
//
//  Purpose: Centralized UI styles for buttons and toggles to ensure visual consistency.
//
//  Responsibilities:
//  - Define the primary "Eco" branding for actionable items.
//  - Provide specialized styles for social authentication and form inputs.
//  - Handle interaction states (pressed, disabled) and typography.

import SwiftUI

// MARK: - Primary Button Styles

/// The standard button style for Eco, used for primary actions like "Plant" or "Login".
///
/// Features a solid background, rounded corners, and a slight scale effect when pressed.
/// - Note: Supports a disabled state via the `isEnabled` property.
struct EcoButtonStyle: ButtonStyle {
    let backgroundColor: Color
    var isEnabled: Bool = true
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.poppins(.semiBold, size: 16))
            // Cambiado a primaryText para que sea el color crema
            .foregroundColor(Color.theme.primaryText)
            .frame(maxWidth: .infinity)
            .padding()
            .background(backgroundColor.opacity(isEnabled ? 1.0 : 0.5))
            .cornerRadius(12)
            // Margen lateral para que no toque los bordes de la pantalla
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
    }
}

/// A secondary button style used for social authentication providers (Google, Apple).
///
/// Characterized by a transparent background and a capsule-shaped border.
struct SocialButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.poppins(.medium, size: 16))
            // Cambiado a primaryText
            .foregroundColor(Color.theme.primaryText)
            .frame(maxWidth: .infinity)
            .padding()
            .overlay(
                Capsule().stroke(Color.theme.primaryText.opacity(0.8), lineWidth: 1)
            )
            // Margen lateral coherente con el otro botón
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
    }
}

// MARK: - Form Component Styles

/// A custom toggle style that renders as a checkbox, optimized for forms and terms of service.
struct CheckboxStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button {
            configuration.isOn.toggle()
        } label: {
            // Alineación centrada suele verse mejor en formularios
            HStack(alignment: .center, spacing: 12) {
                Image(systemName: configuration.isOn ? "checkmark.square.fill" : "square")
                    // Cambiado a primaryText para visibilidad sobre el fondo verde
                    .foregroundColor(Color.theme.primaryText)
                
                configuration.label
                    .font(.poppins(.regular, size: 14))
                    .foregroundColor(Color.theme.primaryText)
            }
        }
        .buttonStyle(.plain)
    }
}
