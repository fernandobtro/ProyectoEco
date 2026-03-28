//
//  GetAuthorProfileUseCaseImpl.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Created by Fernando Buenrostro on 17/03/26.
//

import Foundation

final class GetAuthorProfileUseCaseImpl: GetAuthorProfileUseCase {
    private let repository: AuthorProfileRepositoryProtocol

    init(repository: AuthorProfileRepositoryProtocol) {
        self.repository = repository
    }

    func execute() async throws -> AuthorProfile? {
        try await repository.getCurrent()
    }
}
