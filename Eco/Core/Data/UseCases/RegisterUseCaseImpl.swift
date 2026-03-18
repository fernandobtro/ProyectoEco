//
//  RegisterUseCaseImpl.swift
//  Eco
//
//  Created by Fernando Buenrostro on 16/03/26.
//

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
