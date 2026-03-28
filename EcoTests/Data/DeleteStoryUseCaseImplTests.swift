//
//  DeleteStoryUseCaseImplTests.swift
//  EcoTests
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Created by Fernando Buenrostro on 27/03/26.
//
//  Purpose: Unit tests for `DeleteStoryUseCaseImpl` with in-memory repositories.
//
//  Responsibilities:
//  - Verify authorization and existence rules before calling delete on the story repository.
//

import Foundation
import XCTest
@testable import Eco

final class DeleteStoryUseCaseImplTests: XCTestCase {

    private var stories: FakeStoryRepository!
    private var session: FakeSessionRepository!
    private var sut: DeleteStoryUseCaseImpl!

    override func setUp() {
        super.setUp()
        stories = FakeStoryRepository()
        session = FakeSessionRepository()
        sut = DeleteStoryUseCaseImpl(storyRepository: stories, sessionRepository: session)
    }

    override func tearDown() {
        sut = nil
        session = nil
        stories = nil
        super.tearDown()
    }

    func testExecute_removesStoryWhenCurrentUserIsAuthor() async throws {
        let id = UUID()
        session.currentUserId = "author-1"
        let story = StoryBuilder.make(id: id, authorID: "author-1")
        stories.stories = [story]

        try await sut.execute(storyId: id)

        XCTAssertTrue(stories.stories.isEmpty)
    }

    func testExecute_throwsStoryNotFoundWhenMissing() async throws {
        let id = UUID()
        session.currentUserId = "author-1"

        do {
            try await sut.execute(storyId: id)
            XCTFail("Expected EcoError.storyNotFound")
        } catch EcoError.storyNotFound {
            // expected
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testExecute_throwsUnauthorizedWhenAuthorDiffersFromSession() async throws {
        let id = UUID()
        session.currentUserId = "me"
        stories.stories = [StoryBuilder.make(id: id, authorID: "someone-else")]

        do {
            try await sut.execute(storyId: id)
            XCTFail("Expected EcoError.unauthorizedAction")
        } catch EcoError.unauthorizedAction {
            // expected
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}
