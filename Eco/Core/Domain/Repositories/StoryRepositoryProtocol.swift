//
//  StoryRepositoryProtocol.swift
//  Eco
//
//  Created by Fernando Buenrostro on 27/02/26.
//

import Combine
import Foundation

protocol StoryRepositoryProtocol {
    /// Emite cuando se guarda o borra una historia para que el mapa pueda refrescarse.
    var storiesUpdatePublisher: AnyPublisher<Void, Never> { get }
    
    func fetchAllStories() async throws -> [Story]
    func fetchStory(by id: UUID) async throws -> Story?
    func save(story: Story) async throws
    func delete(storyID: UUID) async throws
}
