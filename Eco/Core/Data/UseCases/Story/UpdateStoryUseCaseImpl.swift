//
//  UpdateStoryUseCaseImpl.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Created by Fernando Buenrostro on 17/03/26.
//

import Foundation

final class UpdateStoryUseCaseImpl: UpdateStoryUseCaseProtocol {
    private let storyRepository: StoryRepositoryProtocol
    private let sessionRepository: SessionRepositoryProtocol

    init(storyRepository: StoryRepositoryProtocol, sessionRepository: SessionRepositoryProtocol) {
        self.storyRepository = storyRepository
        self.sessionRepository = sessionRepository
    }

    func execute(_ story: Story) async throws {
        let currentUserId = try sessionRepository.getCurrentUserId()
        guard story.authorID == currentUserId else {
            throw EcoError.unauthorizedAction
        }
        try await storyRepository.updateStory(story)
    }
}
