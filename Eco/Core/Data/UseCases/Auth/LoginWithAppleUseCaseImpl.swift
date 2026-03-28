//
//  LoginWithAppleUseCaseImpl.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Created by Fernando Buenrostro on 17/03/26.
//
//  Purpose: Domain-specific Use Case for authenticating a user via Apple.
//  Responsibilities:
//  - Execute identity verification through the Auth Repository.
//  - Return the unique User ID (UID) upon success to drive the app session.

import Foundation

final class LoginWithAppleUseCaseImpl: LoginWithAppleUseCaseProtocol {
    private let repository: AuthRepositoryProtocol

    init(repository: AuthRepositoryProtocol) {
        self.repository = repository
    }

    func execute(identityToken: Data, nonce: String, fullName: PersonNameComponents?) async throws -> String {
        try await repository.loginWithApple(identityToken: identityToken, nonce: nonce, fullName: fullName)
    }
}
