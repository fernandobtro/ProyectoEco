//
//  StoryPersistenceMapperTests.swift
//  EcoTests
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Created by Fernando Buenrostro on 26/03/26.
//
//  Purpose: Unit tests for `StoryPersistenceMapper` (SwiftData row ↔ domain `Story`).
//
//  Responsibilities:
//  - Cover `isSynced` derivation from `syncStatus` and `deletedAt`.
//  - Cover create vs update paths for `toEntity`, including pending update after a synced row changes.
//

import Foundation
import XCTest
@testable import Eco

final class StoryPersistenceMapperTests: XCTestCase {

    private let fixedDate = Date(timeIntervalSince1970: 1_700_000_000)

    // MARK: - toDomain

    func testToDomain_syncedWithoutDeletion_isSyncedTrue() {
        let entity = StoryEntity(
            id: UUID(),
            title: "T",
            content: "C",
            authorID: "a1",
            latitude: 1,
            longitude: 2,
            remoteId: "remote",
            syncStatus: SyncStatus.synced.rawValue,
            updatedAt: fixedDate,
            deletedAt: nil
        )

        let story = StoryPersistenceMapper.toDomain(entity)

        XCTAssertTrue(story.isSynced)
        XCTAssertEqual(story.updatedAt, fixedDate)
        XCTAssertEqual(story.title, "T")
    }

    func testToDomain_syncedWithDeletedAt_isSyncedFalse() {
        let entity = StoryEntity(
            id: UUID(),
            title: "T",
            content: "C",
            authorID: "a1",
            latitude: 0,
            longitude: 0,
            remoteId: "r",
            syncStatus: SyncStatus.synced.rawValue,
            updatedAt: fixedDate,
            deletedAt: fixedDate
        )

        let story = StoryPersistenceMapper.toDomain(entity)

        XCTAssertFalse(story.isSynced)
    }

    func testToDomain_pendingCreate_isSyncedFalse() {
        let entity = StoryEntity(
            id: UUID(),
            title: "T",
            content: "C",
            authorID: "a1",
            latitude: 0,
            longitude: 0,
            syncStatus: SyncStatus.pendingCreate.rawValue,
            updatedAt: fixedDate,
            deletedAt: nil
        )

        XCTAssertFalse(StoryPersistenceMapper.toDomain(entity).isSynced)
    }

    // MARK: - toEntity

    func testToEntity_withoutExisting_createsPendingCreateRow() {
        let id = UUID()
        let story = Story(
            id: id,
            title: "New",
            content: "Body",
            authorID: "auth",
            latitude: 3,
            longitude: 4,
            isSynced: true,
            updatedAt: fixedDate
        )

        let entity = StoryPersistenceMapper.toEntity(story, existing: nil)

        XCTAssertEqual(entity.id, id)
        XCTAssertEqual(entity.syncStatus, SyncStatus.pendingCreate.rawValue)
        XCTAssertNil(entity.remoteId)
        XCTAssertNil(entity.deletedAt)
        XCTAssertEqual(entity.title, "New")
        XCTAssertEqual(entity.updatedAt, fixedDate)
    }

    func testToEntity_withSyncedExisting_setsPendingUpdateAndCopiesFields() {
        let id = UUID()
        let existing = StoryEntity(
            id: id,
            title: "Old",
            content: "Old",
            authorID: "auth",
            latitude: 0,
            longitude: 0,
            remoteId: "remote-1",
            syncStatus: SyncStatus.synced.rawValue,
            updatedAt: Date(timeIntervalSince1970: 1),
            deletedAt: nil
        )

        let story = StoryBuilder.make(
            id: id,
            title: "Edited",
            content: "Edited body",
            latitude: 10,
            longitude: 20,
            updatedAt: fixedDate
        )

        let result = StoryPersistenceMapper.toEntity(story, existing: existing)

        XCTAssertTrue(result === existing)
        XCTAssertEqual(existing.syncStatus, SyncStatus.pendingUpdate.rawValue)
        XCTAssertEqual(existing.title, "Edited")
        XCTAssertEqual(existing.content, "Edited body")
        XCTAssertEqual(existing.latitude, 10)
        XCTAssertEqual(existing.longitude, 20)
        XCTAssertEqual(existing.updatedAt, fixedDate)
        XCTAssertEqual(existing.remoteId, "remote-1")
    }

    func testToEntity_withPendingCreateExisting_keepsPendingCreate() {
        let id = UUID()
        let existing = StoryEntity(
            id: id,
            title: "Old",
            content: "Old",
            authorID: "auth",
            latitude: 0,
            longitude: 0,
            syncStatus: SyncStatus.pendingCreate.rawValue,
            updatedAt: Date(timeIntervalSince1970: 1),
            deletedAt: nil
        )

        let story = StoryBuilder.make(id: id, title: "New title", updatedAt: fixedDate)
        _ = StoryPersistenceMapper.toEntity(story, existing: existing)

        XCTAssertEqual(existing.syncStatus, SyncStatus.pendingCreate.rawValue)
        XCTAssertEqual(existing.title, "New title")
    }
}
