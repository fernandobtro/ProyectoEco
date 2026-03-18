//
//  WelcomeView.swift
//  Eco
//
//  Created by Fernando Buenrostro on 17/03/26.
//

import Foundation
import SwiftUI

struct WelcomeView: View {
    @State private var termsAccepted = false
    var onRegisterSelected: () -> Void
    var onLoginSelected: () -> Void

    var body: some View {
        VStack(spacing: 30) {
            Text("Bienvenido (a) al lugar donde las ciudades cuentan su historia.")
                .font(.title2.bold())
                .multilineTextAlignment(.center)

            Text("Al entrar aceptas que lo que escribas pertenece al lugar donde lo escribiste.")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)

            Toggle(isOn: $termsAccepted) {
                Text("Estoy de acuerdo con los Términos & condiciones de eco y confirmo que he leído su Política de privacidad.")
                    .font(.caption)
            }
            // Estilo por defecto para compatibilidad con todas las versiones soportadas

            VStack(spacing: 16) {
                Button("Crea una cuenta") { onRegisterSelected() }
                    .buttonStyle(.borderedProminent)
                    .disabled(!termsAccepted)

                Button("Inicia sesión") { onLoginSelected() }
                    .buttonStyle(.bordered)
                    .disabled(!termsAccepted)
            }
        }
        .padding(30)
    }
}

#Preview {
    WelcomeView(
        onRegisterSelected: {},
        onLoginSelected: {}
    )
}
