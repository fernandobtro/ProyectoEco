//
//  PlantStoryUseCaseImpl.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Created by Fernando Buenrostro on 28/02/26.
//

import Foundation

final class PlantStoryUseCaseImpl: PlantStoryUseCaseProtocol {
    private let storyRepository: StoryRepositoryProtocol
    private let userRepository: UserRepositoryProtocol
    private let sessionRepository: SessionRepositoryProtocol

    init(storyRepository: StoryRepositoryProtocol, userRepository: UserRepositoryProtocol, sessionRepository: SessionRepositoryProtocol) {
        self.storyRepository = storyRepository
        self.userRepository = userRepository
        self.sessionRepository = sessionRepository
    }

    func execute(title: String, content: String, latitude: Double, longitude: Double) async throws -> UUID {
        let currentUserId = try sessionRepository.getCurrentUserId()
        let newStoryId = UUID()
        
        let newStory = Story(
            id: newStoryId,
            title: title,
            content: content,
            authorID: currentUserId,
            latitude: latitude,
            longitude: longitude,
            isSynced: false,
            updatedAt: Date()
        )
        try await storyRepository.createStory(newStory)
        Task {
            try? await userRepository.syncWithCloud()
        }
        return newStoryId
    }
}
