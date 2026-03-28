//
//  ColorTheme.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Created by Fernando Buenrostro on 16/03/26.
//

import Foundation
import SwiftUI

extension Color {
    static let theme = ColorTheme()
}

struct ColorTheme {
    // Colores en Assets (única fuente de verdad)
    let accent = Color("AccentColor")
    let primaryComponent = Color("primaryComponent")
    let primaryText = Color("primaryText")
    let secondaryText = Color("secondaryText")

    var mainBackground: Color {
        Color(UIColor.systemBackground)
    }

    /// Superficie secundaria (tinte suave a partir de `primaryComponent`).
    var secondaryBackground: Color {
        primaryComponent.opacity(0.2)
    }

    /// Fondo crema para listas tipo Explorar / Colección: mismo valor que `primaryText` en Assets.
    var exploreBackground: Color {
        primaryText
    }

    /// Tarjetas sobre fondo claro: tinte ligero desde `primaryComponent`.
    var exploreCardBackground: Color {
        secondaryBackground
    }

    /// Campos del perfil sobre fondo `accent`: solo `primaryComponent` con opacidad (sin hex nuevos).
    var profileFieldSurface: Color {
        primaryComponent.opacity(0.48)
    }

    /// Destructivo suave (cerrar sesión, errores de formulario); coherente con swipe eliminar.
    var profileDestructive: Color {
        Color.red.opacity(0.88)
    }
}
