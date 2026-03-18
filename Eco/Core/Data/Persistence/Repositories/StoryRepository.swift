//
//  StoryRepository.swift
//  Eco
//
//  Created by Fernando Buenrostro on 02/03/26.
//

import Combine
import Foundation

struct StoryRepository: StoryRepositoryProtocol {
    
    private let storyLocalDataSource: StoryLocalDataSourceProtocol
    
    private let updatesSubject = PassthroughSubject<Void, Never>()
    
    var storiesUpdatePublisher: AnyPublisher<Void, Never> {
        updatesSubject.eraseToAnyPublisher()
    }
    
    init(storyLocalDataSource: StoryLocalDataSourceProtocol) {
        self.storyLocalDataSource = storyLocalDataSource
    }
    
    // MARK: - Protocol Methods
    
    func fetchAllStories() async throws -> [Story] {
        let entities = try await storyLocalDataSource.fetchAll()
            .filter { $0.deletedAt == nil }
        return entities.map(StoryPersistenceMapper.toDomain)
    }
    
    func fetchStory(by id: UUID) async throws -> Story? {
        guard let entity = try await storyLocalDataSource.fetch(by: id),
              entity.deletedAt == nil else { return nil }
        return StoryPersistenceMapper.toDomain(entity)
    }
    
    func save(story: Story) async throws {
        let existing = try await storyLocalDataSource.fetch(by: story.id)
        let entity = StoryPersistenceMapper.toEntity(story, existing: existing)
        try await storyLocalDataSource.save(story: entity)
        updatesSubject.send(())
    }
    
    func delete(storyID: UUID) async throws {
        guard let entity = try await storyLocalDataSource.fetch(by: storyID) else { return }
        entity.deletedAt = Date()
        entity.syncStatus = "pendingDelete"
        try await storyLocalDataSource.saveChanges()
        updatesSubject.send(())
    }
}
