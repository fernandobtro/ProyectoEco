//
//  GetCurrentSessionUseCaseImpl.swift
//  Eco
//
//  Created by Fernando Buenrostro on 16/03/26.
//

import Foundation

final class GetCurrentSessionUseCaseImpl: GetCurrentSessionUseCaseProtocol {
    private let repository: AuthRepositoryProtocol
    
    init(repository: AuthRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute() -> String? {
        repository.currentUserId()
    }
}
