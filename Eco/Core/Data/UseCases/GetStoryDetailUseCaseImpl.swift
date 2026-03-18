//
//  GetStoryDetailUseCaseImpl.swift
//  Eco
//
//  Created by Fernando Buenrostro on 16/03/26.
//

import Foundation

final class GetStoryDetailUseCaseImpl: GetStoryDetailUseCaseProtocol {
    private let storyRepository: StoryRepositoryProtocol

    init(storyRepository: StoryRepositoryProtocol) {
        self.storyRepository = storyRepository
    }

    func execute(id: UUID) async throws -> Story? {
        try await storyRepository.fetchStory(by: id)
    }
}

