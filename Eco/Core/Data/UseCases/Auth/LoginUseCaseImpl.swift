//
//  LoginUseCaseImpl.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Created by Fernando Buenrostro on 16/03/26.
//
//  Purpose: Domain-specific Use Case for authenticating a user.

import Foundation

/// Domain-specific Use Case for authenticating a user.
final class LoginUseCaseImpl: LoginUseCaseProtocol {
    private let repository: AuthRepositoryProtocol
    
    init(repository: AuthRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(email: String, password: String) async throws -> String {
        try await repository.login(email: email, password: password)
    }
}
