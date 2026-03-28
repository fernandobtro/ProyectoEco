//
//  LogoutUseCaseImpl.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Created by Fernando Buenrostro on 16/03/26.
//
//  Purpose: Domain-specific Use Case for account management actions.
//  Responsibilities:
//  - Trigger secure credential updates or session termination in the Auth Repository.

import Foundation

final class LogoutUseCaseImpl: LogoutUseCaseProtocol {
    private let repository: AuthRepositoryProtocol
    
    init(repository: AuthRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute() throws {
        try repository.logout()
    }
}
