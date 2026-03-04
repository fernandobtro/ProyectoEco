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
        
        return entities.map { entity in
            Story(id: entity.id,
                  title: entity.title,
                  content: entity.content,
                  authorID: entity.authorID,
                  latitude: entity.latitude,
                  longitude: entity.longitude
            )
        }
    }
    
    func fetchStory(by id: UUID) async throws -> Story? {
        guard let entity = try await storyLocalDataSource.fetch(by: id) else { return nil }
        
        return Story(id: entity.id,
                     title: entity.title,
                     content: entity.content,
                     authorID: entity.authorID,
                     latitude: entity.latitude,
                     longitude: entity.longitude
                )
    }
    
    func save(story: Story) async throws {
        let entity = StoryEntity(id: story.id, title: story.title, content: story.content, authorID: story.authorID, latitude: story.latitude, longitude: story.longitude)
        
        try await storyLocalDataSource.save(story: entity)
        updatesSubject.send(())
    }
    
    func delete(storyID: UUID) async throws {
        try await storyLocalDataSource.delete(id: storyID)
        updatesSubject.send(())
    }
}
