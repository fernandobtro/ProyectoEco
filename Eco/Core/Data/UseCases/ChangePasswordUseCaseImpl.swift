//
//  ChangePasswordUseCaseImpl.swift
//  Eco
//
//  Created by Fernando Buenrostro on 16/03/26.
//

import Foundation

final class ChangePasswordUseCaseImpl: ChangePasswordUseCaseProtocol {
    private let repository: AuthRepositoryProtocol
    
    init(repository: AuthRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(newPassword: String) async throws {
        try await repository.changePassword(newPassword: newPassword)
    }
}
