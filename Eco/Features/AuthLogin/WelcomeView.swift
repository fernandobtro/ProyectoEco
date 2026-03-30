//
//  WelcomeView.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Created by Fernando Buenrostro on 17/03/26.
//
//  Purpose: First launch screen: welcome copy, terms acceptance, register vs login entry points.
//

import Foundation
import SwiftUI

/// Entry step before sign-up or sign-in, drives navigation via `onRegisterSelected` / `onLoginSelected`.
struct WelcomeView: View {
    @State private var termsAccepted = false
    var onRegisterSelected: () -> Void
    var onLoginSelected: () -> Void
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                VStack(spacing: 0) {
                    Color.theme.accent.frame(height: geometry.size.height * 0.45)
                    Color.theme.primaryComponent
                }
                .ignoresSafeArea()

                VStack(spacing: 25) {
                    Image("EcoTypo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150)
                        .padding(.top, 60)

                    Text("Bienvenido (a) al lugar donde las ciudades cuentan su historia.")
                        .font(.poppins(.bold, size: 22))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)

                    Spacer()

                    VStack(spacing: 20) {
                        Text("Al entrar aceptas que lo que escribas pertenece al lugar donde lo escribiste.")
                            .font(.poppins(.medium, size: 16))
                            .italic()
                            .foregroundColor(Color.theme.accent)
                            .multilineTextAlignment(.center)

                        Toggle(isOn: $termsAccepted) {
                            Text("Estoy de acuerdo con los Términos & condiciones de eco y confirmo que he leído su Política de privacidad.")
                                .font(.poppins(.regular, size: 12))
                                .foregroundColor(Color.theme.accent)
                        }
                        .toggleStyle(CheckboxStyle())

                        Button("Crea una cuenta") { onRegisterSelected() }
                            .buttonStyle(EcoButtonStyle(backgroundColor: Color.theme.accent, isEnabled: termsAccepted))
                            .disabled(!termsAccepted)

                        Button("Inicia sesión") { onLoginSelected() }
                            .font(.poppins(.semiBold, size: 16))
                            .foregroundColor(Color.theme.accent)
                            .opacity(termsAccepted ? 1 : 0.5)
                            .disabled(!termsAccepted)
                    }
                    .padding(30)
                }
            }
        }
    }
}

#Preview {
    WelcomeView(
        onRegisterSelected: {},
        onLoginSelected: {}
    )
}
