//
//  UpdateStoryUseCaseImplTests.swift
//  EcoTests
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Created by Fernando Buenrostro on 27/03/26.
//
//  Purpose: Unit tests for `UpdateStoryUseCaseImpl` (author must match session).
//
//  Responsibilities:
//  - Verify authorization before delegating to `StoryRepositoryProtocol.updateStory`.
//

import Foundation
import XCTest
@testable import Eco

final class UpdateStoryUseCaseImplTests: XCTestCase {

    private var stories: FakeStoryRepository!
    private var session: FakeSessionRepository!
    private var sut: UpdateStoryUseCaseImpl!

    override func setUp() {
        super.setUp()
        stories = FakeStoryRepository()
        session = FakeSessionRepository()
        sut = UpdateStoryUseCaseImpl(storyRepository: stories, sessionRepository: session)
    }

    override func tearDown() {
        sut = nil
        session = nil
        stories = nil
        super.tearDown()
    }

    func testExecute_updatesRepositoryWhenAuthorMatchesSession() async throws {
        let id = UUID()
        session.currentUserId = "author-me"
        stories.stories = [StoryBuilder.make(id: id, title: "Old", authorID: "author-me")]
        let updated = StoryBuilder.make(id: id, title: "New title", content: "New body", authorID: "author-me")

        try await sut.execute(updated)

        XCTAssertEqual(stories.stories.count, 1)
        let persistedTitle = stories.stories[0].title
        let persistedContent = stories.stories[0].content
        XCTAssertEqual(persistedTitle, "New title")
        XCTAssertEqual(persistedContent, "New body")
    }

    func testExecute_throwsUnauthorizedWhenAuthorDiffersFromSession() async throws {
        session.currentUserId = "me"
        let story = StoryBuilder.make(authorID: "other")

        do {
            try await sut.execute(story)
            XCTFail("Expected EcoError.unauthorizedAction")
        } catch EcoError.unauthorizedAction {
            // expected
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}
