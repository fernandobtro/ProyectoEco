//
//  ColorTheme.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Created by Fernando Buenrostro on 16/03/26.
//
//  Purpose: Asset-backed semantic colors and `Color.theme` entry point for SwiftUI.
//

import Foundation
import SwiftUI

/// Namespace hook used as `Color.theme` across the app.
extension Color {
    static let theme = ColorTheme()
}

/// Eco palette tokens mapped from the asset catalog (accent, cream text, components).
struct ColorTheme {
    // Asset catalog is the single source of truth for named colors below.
    let accent = Color("AccentColor")
    let primaryComponent = Color("primaryComponent")
    let primaryText = Color("primaryText")
    let secondaryText = Color("secondaryText")

    var mainBackground: Color {
        Color(UIColor.systemBackground)
    }

    /// Soft wash derived from `primaryComponent`.
    var secondaryBackground: Color {
        primaryComponent.opacity(0.2)
    }

    /// Cream list background for explore/collection, same asset token as `primaryText`.
    var exploreBackground: Color {
        primaryText
    }

    /// Card fill on light backgrounds (light tint from `primaryComponent`).
    var exploreCardBackground: Color {
        secondaryBackground
    }

    /// Profile fields on `accent`: `primaryComponent` at fixed opacity (no extra hex values).
    var profileFieldSurface: Color {
        primaryComponent.opacity(0.48)
    }

    /// Muted destructive (logout, form errors), aligned with swipe-to-delete tone.
    var profileDestructive: Color {
        Color.red.opacity(0.88)
    }
}
