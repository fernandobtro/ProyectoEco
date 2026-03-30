//
//  AlwaysLocationUpgradeView.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Purpose: Compact card nudging “Always” location so geofence-driven alerts work in the background.
//

import SwiftUI

/// Shown when precise/always authorization is needed beyond “When In Use”, `onAllow` opens settings or continues upgrade flow.
///
/// Narrative: `docs/EcoCorePipelines.md` — **Cross-Cutting: Sync, Geofencing, Notifications** (background location).
struct AlwaysLocationUpgradeView: View {
    var onAllow: () -> Void
    var onSkip: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text("Recibe avisos aunque no tengas la app abierta")
                .font(.poppins(.bold, size: 18))
                .foregroundColor(Color.theme.secondaryText)
                .multilineTextAlignment(.center)

            Text("Activa la ubicación en \"Siempre\" para avisarte cuando estés cerca de un Eco, incluso en segundo plano.")
                .font(.poppins(.regular, size: 14))
                .foregroundColor(Color.theme.secondaryText)
                .multilineTextAlignment(.center)

            VStack(spacing: 10) {
                Button("Activar \"Siempre\"") {
                    onAllow()
                }
                .buttonStyle(EcoButtonStyle(backgroundColor: Color.theme.accent, isEnabled: true))

                Button("Ahora no") {
                    onSkip()
                }
                .font(.poppins(.semiBold, size: 15))
                .foregroundColor(Color.theme.accent)
            }
        }
        .padding(20)
        .background(Color.theme.primaryComponent)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
        .padding(.horizontal, 20)
    }
}

#Preview {
    ZStack {
        Color.theme.accent.ignoresSafeArea()
        AlwaysLocationUpgradeView(
            onAllow: {},
            onSkip: {}
        )
    }
}
