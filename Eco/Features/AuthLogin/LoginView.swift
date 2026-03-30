//
//  LoginView.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Created by Fernando Buenrostro on 16/03/26.
//
//  Purpose: Returning users: email/password plus social actions via ``SocialAuthViewModel``.
//

import Foundation
import SwiftUI

/// Email and social sign-in UI. Auth context: `docs/EcoCorePipelines.md` — **Email Login Pipeline** (and social entry).
struct LoginView: View {
    @Bindable var viewModel: LoginViewModel
    @Bindable var socialViewModel: SocialAuthViewModel
    let onRegisterTap: () -> Void

    var body: some View {
        ZStack {
            Color.theme.accent
                .ignoresSafeArea()
                .onTapGesture {
                    EcoKeyboard.dismiss()
                }

            VStack {
                Circle()
                    .fill(Color.theme.primaryText)
                    .frame(width: 450, height: 450)
                    .offset(y: -250)
                    .overlay(
                        Image("EcoLogoLightBack")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .offset(y: -90)
                    )
                Spacer()
            }
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    Spacer().frame(height: 220)

                    Text("Inicia sesión")
                        .font(.poppins(.bold, size: 26))
                        .foregroundStyle(Color.theme.primaryText)

                    VStack(spacing: 16) {
                        EcoTextField(
                            "Dirección de email",
                            text: $viewModel.email,
                            textInputAutocapitalization: .never,
                            textContentType: .emailAddress
                        )

                        EcoSecureField("Contraseña", text: $viewModel.password)
                    }

                    HStack {
                        Button("¿Olvidaste tu contraseña?") { }
                            .font(.poppins(.semiBold, size: 14))
                            .foregroundStyle(Color.theme.primaryText)
                            .underline()
                        Spacer()
                    }

                    Button("Inicia sesión con correo electrónico") {
                        viewModel.login()
                    }
                    .buttonStyle(EcoButtonStyle(backgroundColor: Color.theme.primaryComponent))
                    .padding(.top, 10)

                    HStack {
                        Rectangle().fill(Color.theme.primaryText.opacity(0.3)).frame(height: 1)
                        Text("o")
                            .foregroundStyle(Color.theme.primaryText)
                            .font(.poppins(.medium, size: 14))
                        Rectangle().fill(Color.theme.primaryText.opacity(0.3)).frame(height: 1)
                    }
                    .padding(.vertical, 10)

                    VStack(spacing: 12) {
                        Button {
                            Task { await socialViewModel.signInWithApple() }
                        } label: {
                            Label("Continuar con Apple", systemImage: "apple.logo")
                        }
                        .buttonStyle(SocialButtonStyle())
                        .disabled(socialViewModel.isLoading)

                        Button {
                            Task { await socialViewModel.signInWithGoogle() }
                        } label: {
                            HStack {
                                Image(systemName: "g.circle.fill")
                                Text("Continuar con Google")
                            }
                        }
                        .buttonStyle(SocialButtonStyle())
                        .disabled(socialViewModel.isLoading)
                    }

                    if socialViewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: Color.theme.primaryText))
                    }

                    if let error = socialViewModel.errorMessage {
                        Text(error)
                            .font(.poppins(.medium, size: 12))
                            .foregroundStyle(Color.theme.primaryText)
                            .multilineTextAlignment(.center)
                    }

                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 45)
            }
            .scrollDismissesKeyboard(.interactively)
        }
    }
}

private struct MockLoginUseCase: LoginUseCaseProtocol {
    func execute(email: String, password: String) async throws -> String {
        "mock-uid"
    }
}

private struct MockLoginWithAppleUseCaseForPreview: LoginWithAppleUseCaseProtocol {
    func execute(identityToken: Data, nonce: String, fullName: PersonNameComponents?) async throws -> String {
        "mock-uid"
    }
}

private struct MockLoginWithGoogleUseCaseForPreview: LoginWithGoogleUseCaseProtocol {
    func execute(idToken: String, accessToken: String) async throws -> String {
        "mock-uid"
    }
}

#Preview {
    let viewModel = LoginViewModel(loginUseCase: MockLoginUseCase())
    let social = SocialAuthViewModel(
        loginWithAppleUseCase: MockLoginWithAppleUseCaseForPreview(),
        loginWithGoogleUseCase: MockLoginWithGoogleUseCaseForPreview()
    )
    LoginView(viewModel: viewModel, socialViewModel: social, onRegisterTap: {})
}
