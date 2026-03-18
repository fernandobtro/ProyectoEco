//
//  SaveAuthorProfileUseCaseImpl.swift
//  Eco
//
//  Created by Cursor on 17/03/26.
//

import Foundation

final class SaveAuthorProfileUseCaseImpl: SaveAuthorProfileUseCase {
    private let repository: AuthorProfileRepositoryProtocol

    init(repository: AuthorProfileRepositoryProtocol) {
        self.repository = repository
    }

    func execute(_ profile: AuthorProfile) async throws {
        try await repository.save(profile)
    }
}

