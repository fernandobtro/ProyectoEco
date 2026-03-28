//
//  LoginWithGoogleUseCaseImpl.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Created by Fernando Buenrostro on 17/03/26.
//
//  Purpose: Domain-specific Use Case for authenticating a user via Google.
//  Responsibilities:
//  - Execute identity verification through the Auth Repository.
//  - Return the unique User ID (UID) upon success to drive the app session.

import Foundation

final class LoginWithGoogleUseCaseImpl: LoginWithGoogleUseCaseProtocol {
    private let repository: AuthRepositoryProtocol

    init(repository: AuthRepositoryProtocol) {
        self.repository = repository
    }

    func execute(idToken: String, accessToken: String) async throws -> String {
        try await repository.loginWithGoogle(idToken: idToken, accessToken: accessToken)
    }
}
