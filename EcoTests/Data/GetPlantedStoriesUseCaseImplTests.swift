//
//  GetPlantedStoriesUseCaseImplTests.swift
//  EcoTests
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Purpose: Unit tests for planted-story pagination (`StoriesPage`, `pageSize + 1`, stable ordering).
//

import Foundation
import XCTest
@testable import Eco

final class GetPlantedStoriesUseCaseImplTests: XCTestCase {

    private var stories: FakeStoryRepository!
    private var session: FakeSessionRepository!
    private var sut: GetPlantedStoriesUseCaseImpl!

    override func setUp() {
        super.setUp()
        stories = FakeStoryRepository()
        session = FakeSessionRepository()
        sut = GetPlantedStoriesUseCaseImpl(storyRepository: stories, sessionRepository: session)
    }

    override func tearDown() {
        sut = nil
        session = nil
        stories = nil
        super.tearDown()
    }

    func testExecute_hasMoreUsesPageSizePlusOne() async throws {
        let uid = "author-1"
        session.currentUserId = uid
        let base = Date(timeIntervalSince1970: 100)
        for index in 0..<6 {
            stories.stories.append(
                StoryBuilder.make(
                    id: UUID(),
                    title: "s\(index)",
                    authorID: uid,
                    updatedAt: base.addingTimeInterval(Double(index))
                )
            )
        }

        let page0 = try await sut.execute(page: 0, pageSize: 3)
        XCTAssertEqual(page0.items.count, 3)
        XCTAssertTrue(page0.hasMore)

        let page1 = try await sut.execute(page: 1, pageSize: 3)
        XCTAssertEqual(page1.items.count, 3)
        XCTAssertFalse(page1.hasMore)
    }

    func testExecute_noDuplicateIdsAcrossConsecutivePages() async throws {
        let uid = "author-1"
        session.currentUserId = uid
        let base = Date(timeIntervalSince1970: 200)
        for index in 0..<6 {
            stories.stories.append(
                StoryBuilder.make(
                    id: UUID(),
                    title: "s\(index)",
                    authorID: uid,
                    updatedAt: base.addingTimeInterval(Double(index))
                )
            )
        }

        let page0 = try await sut.execute(page: 0, pageSize: 3)
        let page1 = try await sut.execute(page: 1, pageSize: 3)
        let ids0 = Set(page0.items.map(\.id))
        let ids1 = Set(page1.items.map(\.id))
        XCTAssertTrue(ids0.isDisjoint(with: ids1))
    }

    func testExecute_sameUpdatedAt_differentIdsNoOverlapAcrossPages() async throws {
        let uid = "u"
        session.currentUserId = uid
        let same = Date(timeIntervalSince1970: 500)
        let idLow = UUID(uuidString: "00000000-0000-0000-0000-000000000001")
        let idHigh = UUID(uuidString: "00000000-0000-0000-0000-000000000002")
        XCTAssertNotNil(idLow)
        XCTAssertNotNil(idHigh)
        guard let idLow, let idHigh else { return }
        stories.stories = [
            StoryBuilder.make(id: idLow, title: "a", authorID: uid, updatedAt: same),
            StoryBuilder.make(id: idHigh, title: "b", authorID: uid, updatedAt: same)
        ]

        let page0 = try await sut.execute(page: 0, pageSize: 1)
        let page1 = try await sut.execute(page: 1, pageSize: 1)
        XCTAssertEqual(page0.items.count, 1)
        XCTAssertEqual(page1.items.count, 1)
        XCTAssertNotEqual(page0.items[0].id, page1.items[0].id)
    }

    func testExecute_invalidPageOrPageSize_returnsEmpty() async throws {
        let empty = try await sut.execute(page: -1, pageSize: 3)
        XCTAssertTrue(empty.items.isEmpty)
        XCTAssertFalse(empty.hasMore)

        let emptySize = try await sut.execute(page: 0, pageSize: 0)
        XCTAssertTrue(emptySize.items.isEmpty)
        XCTAssertFalse(emptySize.hasMore)
    }
}
