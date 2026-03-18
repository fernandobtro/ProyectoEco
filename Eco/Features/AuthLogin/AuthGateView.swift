//
//  AuthGateView.swift
//  Eco
//
//  Created by Fernando Buenrostro on 16/03/26.
//

import Foundation
import SwiftUI

struct AuthGateView: View {
    let container: AppDIContainer
    @Bindable var viewModel: AuthGateViewModel
    
    @State private var isRegistering = false
    @State private var hasStartedAuth = false // Para controlar la Página 2

    var body: some View {
        Group {
            switch viewModel.state {
            case .checking:
                // PÁGINA 1: Splash con el eslogan "La ciudad tiene memoria."
                SplashView()

            case .authenticated:
                RootView(container: container)

            case .needsNickname:
                // PÁGINA 5: "¿Cómo te llaman por aquí?"
                OnboardingNicknameView(
                    onFinished: { viewModel.checkSession() } // Re-evalúa el estado al terminar
                )

            case .unauthenticated:
                if hasStartedAuth {
                    // TUS FUNCIONALIDADES ACTUALES (Páginas 3 y 4)
                    if isRegistering {
                        RegisterView(
                            viewModel: container.makeRegisterViewModel(),
                            onLoginTap: { isRegistering = false }
                        )
                    } else {
                        LoginView(
                            viewModel: container.makeLoginViewModel(),
                            onRegisterTap: { isRegistering = true }
                        )
                    }
                } else {
                    // PÁGINA 2: Pantalla de Bienvenida y Términos
                    WelcomeView(
                        onRegisterSelected: {
                            isRegistering = true
                            hasStartedAuth = true
                        },
                        onLoginSelected: {
                            isRegistering = false
                            hasStartedAuth = true
                        }
                    )
                }
            }
        }
        .animation(.default, value: viewModel.state)
    }
}

#Preview {
    let container = AppDIContainer()
    let viewModel = container.makeAuthGateViewModel()
    AuthGateView(container: container, viewModel: viewModel)
}
