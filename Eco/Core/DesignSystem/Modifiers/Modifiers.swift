//
//  Modifiers.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Created by Fernando Buenrostro on 19/03/26.
//

import Foundation
import SwiftUI
import UIKit

/// Cierre global del teclado (sin barra «Listo» encima del teclado).
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
            // Cursor / selección: evita heredar el accent del entorno (p. ej. sobre fondo verde).
            .tint(Color.theme.primaryText)
            // Color del texto que se ingresa
            .foregroundStyle(Color.theme.primaryText)
            .font(.poppins(.regular, size: 16))
            .padding()
            // El padding horizontal aquí añade espacio entre el texto y el borde del RoundedRectangle
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
