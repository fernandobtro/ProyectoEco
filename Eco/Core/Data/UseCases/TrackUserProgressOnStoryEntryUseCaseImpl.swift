//
//  TrackUserProgressOnStoryEntryUseCaseImpl.swift
//  Eco
//
//  Created by Fernando Buenrostro on 03/03/26.
//

import Foundation

final class TrackUserProgressOnStoryEntryUseCaseImpl: TrackUserProgressOnStoryEntryUseCaseProtocol {
    private let userRepository: UserRepositoryProtocol
    private let storyRepository: StoryRepositoryProtocol

    init(userRepository: UserRepositoryProtocol, storyRepository: StoryRepositoryProtocol) {
        self.userRepository = userRepository
        self.storyRepository = storyRepository
    }

    func execute(storyId: UUID) async {
        do {
            guard let user = try await userRepository.getCurrentUser(),
                  let story = try await storyRepository.fetchStory(by: storyId) else { return }
            try await userRepository.updateUserProgress(userId: user.id, storyId: story.id)
        } catch {
            // Política de errores: por ahora silencioso
        }
    }
}
