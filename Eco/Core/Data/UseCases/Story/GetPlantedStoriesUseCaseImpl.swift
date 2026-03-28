//
//  GetPlantedStoriesUseCaseImpl.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Created by Fernando Buenrostro on 16/03/26.
//
//  Purpose: Load paginated “planted” stories for the current user; maps `page` → `offset` and uses `pageSize + 1` for `hasMore`.
//

import Foundation

final class GetPlantedStoriesUseCaseImpl: GetPlantedStoriesUseCaseProtocol {
    private let storyRepository: StoryRepositoryProtocol
    private let sessionRepository: SessionRepositoryProtocol

    init(storyRepository: StoryRepositoryProtocol, sessionRepository: SessionRepositoryProtocol) {
        self.storyRepository = storyRepository
        self.sessionRepository = sessionRepository
    }

    func execute(page: Int, pageSize: Int) async throws -> StoriesPage {
        let userId = try sessionRepository.getCurrentUserId()
        guard page >= 0, pageSize > 0 else {
            return StoriesPage(items: [], hasMore: false)
        }
        let offset = page * pageSize
        let fetchLimit = pageSize + 1
        let rows = try await storyRepository.fetchPlantedStories(authorID: userId, limit: fetchLimit, offset: offset)
        let hasMore = rows.count > pageSize
        let items = Array(rows.prefix(pageSize))
        return StoriesPage(items: items, hasMore: hasMore)
    }
}
