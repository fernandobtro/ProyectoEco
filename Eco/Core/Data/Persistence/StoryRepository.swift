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
        return entities.map(StoryPersistenceMapper.toDomain)
    }
    
    func fetchStory(by id: UUID) async throws -> Story? {
        guard let entity = try await storyLocalDataSource.fetch(by: id) else { return nil }
        return StoryPersistenceMapper.toDomain(entity)
    }
    
    func save(story: Story) async throws {
        let entity = StoryPersistenceMapper.toEntity(story)
        try await storyLocalDataSource.save(story: entity)
        updatesSubject.send(())
    }
    
    func delete(storyID: UUID) async throws {
        try await storyLocalDataSource.delete(id: storyID)
        updatesSubject.send(())
    }
}
