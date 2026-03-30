//
//  LoginWithAppleUseCaseImpl.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Created by Fernando Buenrostro on 17/03/26.
//
//  Purpose: Domain-specific Use Case for authenticating a user via Apple.

import Foundation

/// Domain-specific Use Case for authenticating a user via Apple.
final class LoginWithAppleUseCaseImpl: LoginWithAppleUseCaseProtocol {
    private let repository: AuthRepositoryProtocol

    init(repository: AuthRepositoryProtocol) {
        self.repository = repository
    }

    func execute(identityToken: Data, nonce: String, fullName: PersonNameComponents?) async throws -> String {
        try await repository.loginWithApple(identityToken: identityToken, nonce: nonce, fullName: fullName)
    }
}
