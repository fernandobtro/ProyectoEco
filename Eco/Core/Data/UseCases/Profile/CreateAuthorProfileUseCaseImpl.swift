//
//  CreateAuthorProfileUseCaseImpl.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Created by Fernando Buenrostro on 16/03/26.
//
//  Purpose: Implements `CreateAuthorProfileUseCase` using repositories and async side effects.
//

import Foundation

/// Implements `CreateAuthorProfileUseCase` using repositories and async side effects.
final class CreateAuthorProfileUseCaseImpl: CreateAuthorProfileUseCase {
    private let repository: AuthorProfileRepositoryProtocol

    init(repository: AuthorProfileRepositoryProtocol) {
        self.repository = repository
    }

    func execute(profile: AuthorProfile) async throws {
        try await repository.create(profile: profile)
    }
}
