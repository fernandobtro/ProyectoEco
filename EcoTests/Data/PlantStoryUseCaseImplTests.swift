//
//  PlantStoryUseCaseImplTests.swift
//  EcoTests
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Created by Fernando Buenrostro on 27/03/26.
//
//  Purpose: Unit tests for `PlantStoryUseCaseImpl` (create story + fire-and-forget cloud sync).
//
//  Responsibilities:
//  - Assert persisted story fields and session-bound author id.
//  - Optionally await the background `syncWithCloud` task via a hook.
//

import Foundation
import XCTest
@testable import Eco

@MainActor
final class PlantStoryUseCaseImplTests: XCTestCase {

    private var stories: FakeStoryRepository!
    private var users: FakeUserRepository!
    private var session: FakeSessionRepository!
    private var sut: PlantStoryUseCaseImpl!

    override func setUp() {
        super.setUp()
        stories = FakeStoryRepository()
        users = FakeUserRepository()
        session = FakeSessionRepository()
        sut = PlantStoryUseCaseImpl(
            storyRepository: stories,
            userRepository: users,
            sessionRepository: session
        )
    }

    override func tearDown() {
        sut = nil
        session = nil
        users = nil
        stories = nil
        super.tearDown()
    }

    func testExecute_createsStoryWithSessionAuthorAndCoordinates() async throws {
        session.currentUserId = "firebase-uid-99"

        let id = try await sut.execute(
            title: "Hola",
            content: "Mundo",
            latitude: 40.5,
            longitude: -3.7
        )

        XCTAssertEqual(stories.stories.count, 1)
        let created = try XCTUnwrap(stories.stories.first)
        XCTAssertEqual(created.id, id)
        XCTAssertEqual(created.title, "Hola")
        XCTAssertEqual(created.content, "Mundo")
        XCTAssertEqual(created.authorID, "firebase-uid-99")
        XCTAssertEqual(created.latitude, 40.5)
        XCTAssertEqual(created.longitude, -3.7)
        XCTAssertFalse(created.isSynced)
    }

    func testExecute_triggersSyncWithCloudInBackground() async throws {
        let exp = expectation(description: "syncWithCloud")
        users.onSyncWithCloud = {
            exp.fulfill()
        }

        _ = try await sut.execute(title: "T", content: "C", latitude: 0, longitude: 0)

        await fulfillment(of: [exp], timeout: 3.0)
        XCTAssertEqual(users.syncWithCloudCallCount, 1)
    }
}
