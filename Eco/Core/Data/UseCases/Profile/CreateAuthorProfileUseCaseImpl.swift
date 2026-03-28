//
//  CreateAuthorProfileUseCaseImpl.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Created by Fernando Buenrostro on 16/03/26.
//

import Foundation

final class CreateAuthorProfileUseCaseImpl: CreateAuthorProfileUseCase {
    private let repository: AuthorProfileRepositoryProtocol

    init(repository: AuthorProfileRepositoryProtocol) {
        self.repository = repository
    }

    func execute(profile: AuthorProfile) async throws {
        try await repository.create(profile: profile)
    }
}
