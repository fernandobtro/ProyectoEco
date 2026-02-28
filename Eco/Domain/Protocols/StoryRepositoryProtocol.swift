//
//  StoryRepositoryProtocol.swift
//  Eco
//
//  Created by Fernando Buenrostro on 27/02/26.
//

import Foundation

protocol StoryRepositoryProtocol {
    func fetchAllStories() async throws -> [Story]
    func save(story: Story) async throws
    func delete(storyID: UUID) async throws
}
