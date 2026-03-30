//
//  FakeStoryRepository.swift
//  EcoTests
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Created by Fernando Buenrostro on 27/03/26.
//
//  Purpose: In-memory `StoryRepositoryProtocol` for unit tests.
//
//  Responsibilities:
//  - Store stories in RAM and satisfy the full protocol surface with Combine publisher.
//

import Combine
import Foundation
@testable import Eco

final class FakeStoryRepository: StoryRepositoryProtocol {
    private let updatesSubject = PassthroughSubject<Void, Never>()

    var storiesUpdatePublisher: AnyPublisher<Void, Never> {
        updatesSubject.eraseToAnyPublisher()
    }

    /// Mutable backing store, tests may seed or inspect directly.
    var stories: [Story] = []

    func notifyStoriesUpdated() {
        updatesSubject.send(())
    }

    func fetchAllStories() async throws -> [Story] {
        stories
    }

    func fetchAllStoriesSortedByUpdatedAtDesc() async throws -> [Story] {
        stories.sorted { lhs, rhs in
            if lhs.updatedAt != rhs.updatedAt { return lhs.updatedAt > rhs.updatedAt }
            return lhs.id.uuidString > rhs.id.uuidString
        }
    }

    func fetchPlantedStories(authorID: String, limit: Int, offset: Int) async throws -> [Story] {
        let sorted = stories
            .filter { $0.authorID == authorID }
            .sorted { lhs, rhs in
                if lhs.updatedAt != rhs.updatedAt { return lhs.updatedAt > rhs.updatedAt }
                return lhs.id.uuidString > rhs.id.uuidString
            }
        guard offset < sorted.count else { return [] }
        return Array(sorted.dropFirst(offset).prefix(max(0, limit)))
    }

    func fetchActiveStoriesInBoundingBox(
        minLatitude: Double,
        maxLatitude: Double,
        minLongitude: Double,
        maxLongitude: Double
    ) async throws -> [Story] {
        stories.filter { story in
            story.latitude >= minLatitude && story.latitude <= maxLatitude
                && story.longitude >= minLongitude && story.longitude <= maxLongitude
        }
    }

    func fetchStory(by id: UUID) async throws -> Story? {
        stories.first { $0.id == id }
    }

    func createStory(_ story: Story) async throws {
        stories.append(story)
    }

    func updateStory(_ story: Story) async throws {
        guard let index = stories.firstIndex(where: { $0.id == story.id }) else { return }
        stories[index] = story
    }

    func delete(storyID: UUID) async throws {
        stories.removeAll { $0.id == storyID }
    }
}
