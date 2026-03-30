//
//  Modifiers.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Created by Fernando Buenrostro on 19/03/26.
//
//  Purpose: Reusable view helpers (e.g. global keyboard dismiss without an input accessory bar).
//

import Foundation
import SwiftUI
import UIKit

/// Dismisses the first responder / keyboard app-wide.
enum EcoKeyboard {
    static func dismiss() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }
}

struct EcoTextFieldModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            // Cursor / selection: avoid inheriting environment accent (e.g. on green background).
            .tint(Color.theme.primaryText)
            // Color del texto que se ingresa
            .foregroundStyle(Color.theme.primaryText)
            .font(.poppins(.regular, size: 16))
            .padding()
            // Horizontal padding between label text and the rounded rectangle edge
            .padding(.horizontal, 4)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(0.6), lineWidth: 1)
            )
    }
}
extension View {
    func ecoTextFieldStyle() -> some View {
        self.modifier(EcoTextFieldModifier())
    }
}
