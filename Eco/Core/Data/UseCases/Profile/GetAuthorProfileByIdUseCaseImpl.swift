//
//  GetAuthorProfileByIdUseCaseImpl.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//

import Foundation

final class GetAuthorProfileByIdUseCaseImpl: GetAuthorProfileByIdUseCaseProtocol {
    private let repository: AuthorProfileRepositoryProtocol

    init(repository: AuthorProfileRepositoryProtocol) {
        self.repository = repository
    }

    func execute(authorId: String) async throws -> AuthorProfile? {
        try await repository.get(by: authorId)
    }
}
