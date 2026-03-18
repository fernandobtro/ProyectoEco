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
    private let localNotificationService: LocalNotificationServiceProtocol

    init(
        userRepository: UserRepositoryProtocol,
        storyRepository: StoryRepositoryProtocol,
        localNotificationService: LocalNotificationServiceProtocol
    ) {
        self.userRepository = userRepository
        self.storyRepository = storyRepository
        self.localNotificationService = localNotificationService
    }

    func execute(storyId: UUID) async {
        do {
            guard let user = try await userRepository.getCurrentUser(),
                  let story = try await storyRepository.fetchStory(by: storyId) else { return }
            let isNewlyDiscovered = try await userRepository.updateUserProgress(userId: user.id, storyId: story.id)
            if isNewlyDiscovered {
                await localNotificationService.scheduleStoryUnlockedNotification(storyTitle: story.title)
            }
        } catch {
            // Política de errores: por ahora silencioso
        }
    }
}
