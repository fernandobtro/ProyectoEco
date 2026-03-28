//
//  SyncPullStoriesUseCaseImplTests.swift
//  EcoTests
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Purpose: Verify sync pull prefetches locals by remote id in batch instead of per-DTO lookup.
//
//  Responsibilities:
//  - Assert `fetchByRemoteIds` is invoked once with the union of remote ids for a pull batch.
//

import Foundation
import XCTest
@testable import Eco

final class SyncPullStoriesUseCaseImplTests: XCTestCase {

    private static let lastSyncKey = "SyncPullStoriesUseCase.lastUpdatedAt"

    private var local: FakeStoryLocalDataSource!
    private var remote: FakeFirestoreStoryDataSource!
    private var sut: SyncPullStoriesUseCaseImpl!

    override func setUp() {
        super.setUp()
        UserDefaults.standard.removeObject(forKey: Self.lastSyncKey)
        local = FakeStoryLocalDataSource()
        remote = FakeFirestoreStoryDataSource()
        sut = SyncPullStoriesUseCaseImpl(remoteDataSource: remote, localDataSource: local)
    }

    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: Self.lastSyncKey)
        sut = nil
        remote = nil
        local = nil
        super.tearDown()
    }

    func testExecute_prefetchesAllRemoteIdsInOneBatch() async throws {
        let older = Date(timeIntervalSince1970: 100)
        let newer = Date(timeIntervalSince1970: 200)
        remote.dtosToReturn = [
            RemoteStoryDTO(
                remoteId: "doc-a",
                title: "A",
                content: "a",
                authorId: "u1",
                latitude: 0,
                longitude: 0,
                updatedAt: older,
                deletedAt: nil
            ),
            RemoteStoryDTO(
                remoteId: "doc-b",
                title: "B",
                content: "b",
                authorId: "u1",
                latitude: 1,
                longitude: 1,
                updatedAt: newer,
                deletedAt: nil
            )
        ]

        try await sut.execute(since: nil)

        XCTAssertEqual(local.fetchByRemoteIdsInvocations.count, 1)
        let requested = Set(local.fetchByRemoteIdsInvocations[0])
        XCTAssertEqual(requested, Set(["doc-a", "doc-b"]))
        XCTAssertEqual(local.entities.count, 2)
    }
}
