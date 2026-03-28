//
//  DeleteStoryUseCaseImpl.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Created by Fernando Buenrostro on 16/03/26.
//

import Foundation

final class DeleteStoryUseCaseImpl: DeleteStoryUseCaseProtocol {
    private let storyRepository: StoryRepositoryProtocol
    private let sessionRepository: SessionRepositoryProtocol

    init(storyRepository: StoryRepositoryProtocol, sessionRepository: SessionRepositoryProtocol) {
        self.storyRepository = storyRepository
        self.sessionRepository = sessionRepository
    }

    func execute(storyId: UUID) async throws {
        let currentUserId = try sessionRepository.getCurrentUserId()
        guard let story = try await storyRepository.fetchStory(by: storyId) else {
            throw EcoError.storyNotFound
        }
        guard story.authorID == currentUserId else {
            throw EcoError.unauthorizedAction
        }
        print("🧵 [DELETE] story: \(storyId)")
        try await storyRepository.delete(storyID: storyId)
    }
}
