//
//  RegisterUseCaseImpl.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Created by Fernando Buenrostro on 16/03/26.
//
//  Purpose: Domain-specific Use Case for onboarding new users.
//  Responsibilities:
//  - Interface with the Auth Repository to create a new unique identity.
//  - Provide the initial UID needed for local profile bootstrapping.

import Foundation

final class RegisterUseCaseImpl: RegisterUseCaseProtocol {
    private let repository: AuthRepositoryProtocol
    
    init(repository: AuthRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(email: String, password: String) async throws -> String {
        try await repository.register(email: email, password: password)
    }
}
