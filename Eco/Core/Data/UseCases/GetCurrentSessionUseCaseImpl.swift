//
//  GetCurrentSessionUseCaseImpl.swift
//  Eco
//
//  Created by Fernando Buenrostro on 16/03/26.
//

import Foundation

final class GetCurrentSessionUseCaseImpl: GetCurrentSessionUseCaseProtocol {
    private let authRepository: AuthRepositoryProtocol
    private let sessionRepository: SessionRepositoryProtocol
    
    init(repository: AuthRepositoryProtocol, sessionRepository: SessionRepositoryProtocol) {
        self.authRepository = repository
        self.sessionRepository = sessionRepository
    }
    
    func execute() -> String? {
        authRepository.currentUserId()
    }
    
    func getNickname() -> String? {
        sessionRepository.getNickname()
    }
}
