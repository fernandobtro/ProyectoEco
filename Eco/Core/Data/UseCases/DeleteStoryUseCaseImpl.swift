//
//  DeleteStoryUseCaseImpl.swift
//  Eco
//
//  Created by Fernando Buenrostro on 16/03/26.
//

import Foundation

final class DeleteStoryUseCaseImpl: DeleteStoryUseCaseProtocol {
    private let storyRepository: StoryRepositoryProtocol

    init(storyRepository: StoryRepositoryProtocol) {
        self.storyRepository = storyRepository
    }

    func execute(storyId: UUID) async throws {
        try await storyRepository.delete(storyID: storyId)
    }
}

