//
//  LoginWithGoogleUseCaseImpl.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Created by Fernando Buenrostro on 17/03/26.
//
//  Purpose: Domain-specific Use Case for authenticating a user via Google.

import Foundation

/// Domain-specific Use Case for authenticating a user via Google.
final class LoginWithGoogleUseCaseImpl: LoginWithGoogleUseCaseProtocol {
    private let repository: AuthRepositoryProtocol

    init(repository: AuthRepositoryProtocol) {
        self.repository = repository
    }

    func execute(idToken: String, accessToken: String) async throws -> String {
        try await repository.loginWithGoogle(idToken: idToken, accessToken: accessToken)
    }
}
