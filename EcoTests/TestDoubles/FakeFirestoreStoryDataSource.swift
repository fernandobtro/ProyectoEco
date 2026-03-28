//
//  FakeFirestoreStoryDataSource.swift
//  EcoTests
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Purpose: Test double for `FirestoreStoryDataSourceProtocol` (pull-focused).
//

import Foundation
@testable import Eco

final class FakeFirestoreStoryDataSource: FirestoreStoryDataSourceProtocol {
    var dtosToReturn: [RemoteStoryDTO] = []

    func create(payload: FirestoreStoryPayload) async throws -> String {
        fatalError("FakeFirestoreStoryDataSource: create not implemented")
    }

    func update(payload: FirestoreStoryPayload) async throws {
        fatalError("FakeFirestoreStoryDataSource: update not implemented")
    }

    func softDelete(remoteId: String) async throws {
        fatalError("FakeFirestoreStoryDataSource: softDelete not implemented")
    }

    func fetchStoriesUpdated(since: Date?) async throws -> [RemoteStoryDTO] {
        dtosToReturn
    }
}
