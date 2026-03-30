//
//  SocialAuthViewModel.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Created by Fernando Buenrostro on 17/03/26.
//
//  Purpose: Apple and Google sign-in using domain use cases and ``AppleSignInHelper``.
//

import FirebaseCore
import Foundation
import GoogleSignIn
import Observation
import UIKit

/// Shared social auth state for login and registration screens.
///
/// Auth context: `docs/EcoCorePipelines.md` — **Email Login Pipeline** (social providers).
@Observable
@MainActor
final class SocialAuthViewModel {
    var isLoading = false
    var errorMessage: String?

    private let loginWithAppleUseCase: LoginWithAppleUseCaseProtocol
    private let loginWithGoogleUseCase: LoginWithGoogleUseCaseProtocol
    private let appleSignInHelper = AppleSignInHelper()

    init(
        loginWithAppleUseCase: LoginWithAppleUseCaseProtocol,
        loginWithGoogleUseCase: LoginWithGoogleUseCaseProtocol
    ) {
        self.loginWithAppleUseCase = loginWithAppleUseCase
        self.loginWithGoogleUseCase = loginWithGoogleUseCase
    }

    func signInWithApple() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let result = try await appleSignInHelper.signIn()
            _ = try await loginWithAppleUseCase.execute(
                identityToken: result.identityToken,
                nonce: result.nonce,
                fullName: result.fullName
            )
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func signInWithGoogle() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            guard let clientID = FirebaseCore.FirebaseApp.app()?.options.clientID else {
                errorMessage = "No se pudo obtener la configuración de Google."
                return
            }

            GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)

            guard let windowScene = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .first(where: { $0.activationState == .foregroundActive }),
                  let rootVC = windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController else {
                errorMessage = "No se pudo presentar el inicio de sesión."
                return
            }

            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootVC)

            guard let idToken = result.user.idToken?.tokenString else {
                errorMessage = "No se pudo obtener el token de Google."
                return
            }
            let accessToken = result.user.accessToken.tokenString

            _ = try await loginWithGoogleUseCase.execute(idToken: idToken, accessToken: accessToken)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
