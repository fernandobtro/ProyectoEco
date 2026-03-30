//
//  SocialRegisterView.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Created by Fernando Buenrostro on 17/03/26.
//
//  Purpose: Social-first sign-up screen with paths to email register and login.
//

import Foundation
import SwiftUI

/// Presents Apple/Google registration and fallbacks to email or existing-account login.
struct SocialRegisterView: View {
    @Bindable var viewModel: SocialAuthViewModel
    var onEmailTap: () -> Void
    var onLoginTap: () -> Void

    var body: some View {
        ZStack {
            Color.theme.accent.ignoresSafeArea()
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

            VStack(spacing: 30) {
                
                Text("Crea una cuenta")
                    .font(.poppins(.bold, size: 26))
                    .foregroundStyle(Color.theme.primaryText)
                
                VStack(spacing: 15) {
                    Button {
                        Task { await viewModel.signInWithApple() }
                    } label: {
                        Label("Continuar con Apple", systemImage: "apple.logo")
                    }
                    .buttonStyle(SocialButtonStyle())
                    .disabled(viewModel.isLoading)
                    
                    Button {
                        Task { await viewModel.signInWithGoogle() }
                    } label: {
                        HStack {
                            Image(systemName: "g.circle.fill")
                            Text("Continuar con Google")
                        }
                    }
                    .buttonStyle(SocialButtonStyle())
                    .disabled(viewModel.isLoading)
                    
                    Button(action: onEmailTap) {
                        Label("Continuar con el Correo", systemImage: "envelope.fill")
                    }
                    .buttonStyle(SocialButtonStyle())
                }
                .padding(.horizontal, 40)
                
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .primaryText))
                }
                
                if let error = viewModel.errorMessage {
                    Text(error)
                        .font(.poppins(.medium, size: 12))
                        .foregroundStyle(Color.theme.primaryText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                Button("¿Ya tienes una cuenta? Inicia sesión") { onLoginTap() }
                    .font(.poppins(.semiBold, size: 14))
                    .foregroundStyle(Color.theme.primaryText)
            }
            .padding(.horizontal, 5)
        }
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
    SocialRegisterView(
        viewModel: SocialAuthViewModel(
            loginWithAppleUseCase: MockLoginWithAppleUseCaseForPreview(),
            loginWithGoogleUseCase: MockLoginWithGoogleUseCaseForPreview()
        ),
        onEmailTap: {},
        onLoginTap: {}
    )
}
