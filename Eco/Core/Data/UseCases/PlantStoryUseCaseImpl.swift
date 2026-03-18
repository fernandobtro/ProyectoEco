//
//  PlantStoryUseCaseImpl.swift
//  Eco
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

    func execute(title: String, content: String, latitude: Double, longitude: Double) async throws {
        let currentUserId = sessionRepository.getCurrentUserId()
        
        let newStory = Story(
            id: UUID(),
            title: title,
            content: content,
            authorID: currentUserId,
            latitude: latitude,
            longitude: longitude,
            isSynced: false
        )
        try await storyRepository.save(story: newStory)
        Task {
            try? await userRepository.syncWithCloud()
        }
    }
}
