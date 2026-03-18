//
//  ColorTheme.swift
//  Eco
//
//  Created by Fernando Buenrostro on 16/03/26.
//

import Foundation
import SwiftUI

extension Color {
    static let theme = ColorTheme()
}

struct ColorTheme {
    // Colores que ya tienes en Assets
    let accent = Color("AccentColor")
    let primaryComponent = Color("primaryComponent")
    let primaryText = Color("primaryText")
    
    // Colores semánticos (mapeados a los anteriores o al sistema)
    // Esto te permite cambiar el estilo de toda la app desde aquí
    var mainBackground: Color {
        // Usamos el color de fondo del sistema o uno personalizado
        Color(UIColor.systemBackground)
    }
    
    var secondaryBackground: Color {
        // Ideal para las tarjetas (Cards) de las citas
        primaryComponent.opacity(0.2)
    }
}
