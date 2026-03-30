//
//  NotificationsOnboardingView.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Purpose: Explains local notifications for proximity / unlock before requesting system notification permission.
//

import SwiftUI

/// `onAllow` / `onSkip` wire to permission request or deferred opt-out.
///
/// Narrative: `docs/EcoCorePipelines.md` — **Cross-Cutting: Sync, Geofencing, Notifications**.
struct NotificationsOnboardingView: View {
    var onAllow: () -> Void
    var onSkip: () -> Void

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                VStack(spacing: 0) {
                    Color.theme.accent.frame(height: geometry.size.height * 0.75)
                    Color.theme.primaryComponent
                }
                .ignoresSafeArea()

                VStack(spacing: 24) {
                    Image("EcoTypo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150)
                        .padding(.top, 60)

                    Text("¿Quieres recibir avisos de Ecos?")
                        .font(.poppins(.bold, size: 22))
                        .foregroundStyle(Color.theme.primaryText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)

                    VStack(alignment: .leading, spacing: 12) {
                        bullet("Te avisaremos cuando estés cerca de una historia.")
                        bullet("Te avisaremos cuando desbloquees un Eco.")
                    }
                    .padding(.horizontal, 32)
                    .padding(.top, 8)

                    Spacer()

                    VStack(spacing: 12) {
                        Button("Activar notificaciones") {
                            onAllow()
                        }
                        .buttonStyle(EcoButtonStyle(backgroundColor: Color.theme.accent, isEnabled: true))

                        Button("Ahora no") {
                            onSkip()
                        }
                        .font(.poppins(.semiBold, size: 16))
                        .foregroundStyle(Color.theme.accent)
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 40)
                }
            }
        }
    }

    private func bullet(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Circle()
                .fill(Color.theme.primaryComponent)
                .frame(width: 8, height: 8)
                .padding(.top, 5)
            Text(text)
                .font(.poppins(.regular, size: 14))
                .foregroundColor(Color.theme.primaryText)
        }
    }
}

#Preview {
    NotificationsOnboardingView(
        onAllow: {},
        onSkip: {}
    )
}
