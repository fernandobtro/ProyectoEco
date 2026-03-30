//
//  Buttons.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Created by Fernando Buenrostro on 17/03/26.
//
//  Purpose: Shared `ButtonStyle` and `ToggleStyle` types for auth screens and branded forms.
//

import SwiftUI

// MARK: - Primary Button Styles

/// Primary Eco action: filled background, rounded corners, press scale, optional disabled dimming via `isEnabled`.
struct EcoButtonStyle: ButtonStyle {
    let backgroundColor: Color
    var isEnabled: Bool = true
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.poppins(.semiBold, size: 16))
            .foregroundColor(Color.theme.primaryText)
            .frame(maxWidth: .infinity)
            .padding()
            .background(backgroundColor.opacity(isEnabled ? 1.0 : 0.5))
            .cornerRadius(12)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
    }
}

/// Social providers: transparent fill with a capsule stroke (Apple/Google).
struct SocialButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.poppins(.medium, size: 16))
            .foregroundColor(Color.theme.primaryText)
            .frame(maxWidth: .infinity)
            .padding()
            .overlay(
                Capsule().stroke(Color.theme.primaryText.opacity(0.8), lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
    }
}

// MARK: - Form Component Styles

/// Renders a toggle as a checkbox (e.g. terms acceptance).
struct CheckboxStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button {
            configuration.isOn.toggle()
        } label: {
            HStack(alignment: .center, spacing: 12) {
                Image(systemName: configuration.isOn ? "checkmark.square.fill" : "square")
                    .foregroundColor(Color.theme.primaryText)
                
                configuration.label
                    .font(.poppins(.regular, size: 14))
                    .foregroundColor(Color.theme.primaryText)
            }
        }
        .buttonStyle(.plain)
    }
}
