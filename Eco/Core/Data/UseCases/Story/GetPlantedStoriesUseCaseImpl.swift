//
//  GetPlantedStoriesUseCaseImpl.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Created by Fernando Buenrostro on 16/03/26.
//

import Foundation

final class GetPlantedStoriesUseCaseImpl: GetPlantedStoriesUseCaseProtocol {
    private let storyRepository: StoryRepositoryProtocol
    private let sessionRepository: SessionRepositoryProtocol
    
    init(storyRepository: StoryRepositoryProtocol, sessionRepository: SessionRepositoryProtocol) {
        self.storyRepository = storyRepository
        self.sessionRepository = sessionRepository
    }
    
    func execute() async throws -> [Story] {
        let currenUserId = try sessionRepository.getCurrentUserId()
        let all = try await storyRepository.fetchAllStories()
        return all.filter { $0.authorID == currenUserId }
    }
}
