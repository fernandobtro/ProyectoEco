//
//  GetCurrentSessionUseCaseImpl.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Created by Fernando Buenrostro on 16/03/26.
//
//  Purpose: Accessor for the active identity and session metadata.
//  Responsibilities:
//  - Provide synchronous access to the current UID and cached nickname.
//  - Act as a light gatekeeper for UI-level session checks.

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
