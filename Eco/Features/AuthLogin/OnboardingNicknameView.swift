//
//  OnboardingNicknameView.swift
//  Eco
//
//  Created by Fernando Buenrostro on 17/03/26.
//

import Foundation
import SwiftUI

struct OnboardingNicknameView: View {
    @State private var nickname: String = ""
    var onFinished: () -> Void
    // Aquí inyectarías tu repositorio o use case para guardar el nombre

    var body: some View {
        VStack(spacing: 40) {
            Text("¿Cómo te llaman\n por aquí?")
                .font(.largeTitle.bold())
                .multilineTextAlignment(.center)

            TextField("Tu nombre o apodo...", text: $nickname)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal, 40)

            Button("Entrar al mapa") {
                // 1. Guardar en LocalSessionRepository
                // 2. (Opcional) Guardar en Firestore para el perfil remoto
                onFinished()
            }
            .buttonStyle(.borderedProminent)
            .disabled(nickname.count < 3)
        }
    }
}

#Preview {
    OnboardingNicknameView(onFinished: {})
}
