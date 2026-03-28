//
//  GetStoryDetailUseCaseImpl.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Created by Fernando Buenrostro on 16/03/26.
//
//  Purpose: Load one story for detail UI using the story repository.
//
//  Responsibilities:
//  - Call `StoryRepository.fetchStory(by:)` and return the result unchanged.
//

import Foundation

final class GetStoryDetailUseCaseImpl: GetStoryDetailUseCaseProtocol {
    // MARK: - Dependencies

    private let storyRepository: StoryRepositoryProtocol

    // MARK: - Init

    init(storyRepository: StoryRepositoryProtocol) {
        self.storyRepository = storyRepository
    }

    // MARK: - Public API
    /// Delegates to `storyRepository.fetchStory(by:)`. See protocol for nil semantics.
    func execute(id: UUID) async throws -> Story? {
        #if DEBUG
        print("[GetStoryDetailUseCase] execute id=\(id.uuidString)")
        #endif
        let story = try await storyRepository.fetchStory(by: id)
        #if DEBUG
        print("[GetStoryDetailUseCase] result exists=\(story != nil)")
        #endif
        return story
    }
}
