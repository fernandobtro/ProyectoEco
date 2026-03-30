//
//  LocationOnboardingView.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Purpose: First-run explanation for location access before the system permission prompt (map discovery and planting).
//

import SwiftUI

/// Marketing-style screen, `onContinue` should trigger the actual authorization flow (e.g. from ``AuthGateView`` / root shell).
///
/// Narrative: `docs/EcoCorePipelines.md` — **Map Story Discovery Pipeline** (location permission).
struct LocationOnboardingView: View {
    var onContinue: () -> Void

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

                    Text("Descubre historias a tu alrededor")
                        .font(.poppins(.bold, size: 22))
                        .foregroundStyle(Color.theme.primaryText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)

                    VStack(alignment: .leading, spacing: 12) {
                        bullet("Verás Ecos cercanos en el mapa.")
                        bullet("Podrás plantar historias justo donde ocurrieron.")
                        bullet("Tu ubicación no se comparte con otros usuarios.")
                                                }
                    .padding(.horizontal, 32)
                    .padding(.top, 8)

                    Spacer()

                    Button("Permitir ubicación") {
                        onContinue()
                    }
                    .buttonStyle(EcoButtonStyle(backgroundColor: Color.theme.accent, isEnabled: true))
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
                .foregroundStyle(Color.theme.primaryText)
        }
    }
}

#Preview {
    LocationOnboardingView(onContinue: {})
}
