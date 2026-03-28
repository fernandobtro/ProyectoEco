//
//  FirestoreStoryDataSource.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Created by Fernando Buenrostro on 17/03/26.
//
//  Purpose: Remote story persistence and reads against the Firestore "stories" collection.
//
//  Responsibilities:
//  - Create, update, and soft-delete story documents by remote id.
//  - Fetch changed or all story DTOs for sync pull using "updatedAt" boundaries.
//

import Foundation
import FirebaseFirestore

final class FirestoreStoryDataSource: FirestoreStoryDataSourceProtocol {

    // MARK: - Dependencies

    private let dataBase = Firestore.firestore()

    // MARK: - Public API

    /// Sends a new story to the global `stories` collection in Firestore.
    ///
    /// - Parameter payload: Raw fields to write to the remote document.
    /// - Returns: The Firebase-generated `documentID` to persist locally as `remoteId`.
    /// - Throws: Network errors, permission failures, or Firestore security rule denials.
    func create(payload: FirestoreStoryPayload) async throws -> String {
        let ref = dataBase.collection("stories").document()

        let data: [String: Any] = [
            "title": payload.title,
            "content": payload.content,
            "authorId": payload.authorID,
            "latitude": payload.latitude,
            "longitude": payload.longitude,
            "updatedAt": Timestamp(date: payload.updatedAt)
        ]

        try await ref.setData(data)

        return ref.documentID
    }

    /// Merges the payload into the document identified by `payload.remoteId`.
    ///
    /// - Parameter payload: Must include a non-nil `remoteId` for the document to update.
    /// - Throws: A local error when `remoteId` is missing, or Firestore/network errors for the write.
    func update(payload: FirestoreStoryPayload) async throws {
        guard let remoteId = payload.remoteId else {
            throw NSError(
                domain: "FirestoreStoryDataSource",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Missing remoteId for update"]
            )
        }

        let ref = dataBase.collection("stories").document(remoteId)

        let data: [String: Any] = [
            "title": payload.title,
            "content": payload.content,
            "authorId": payload.authorID,
            "latitude": payload.latitude,
            "longitude": payload.longitude,
            "updatedAt": Timestamp(date: payload.updatedAt)
        ]

        try await ref.setData(data, merge: true)
    }

    /// Soft-deletes a story by merging `deletedAt` on the remote document.
    ///
    /// - Parameter remoteId: Firestore document id of the story to mark deleted.
    /// - Throws: Network errors, permission failures, or Firestore security rule denials.
    func softDelete(remoteId: String) async throws {
        let ref = dataBase.collection("stories").document(remoteId)
        let data: [String: Any] = [
            "deletedAt": Timestamp(date: Date())
        ]
        try await ref.setData(data, merge: true)
    }

    /// Delta sync: fetches stories modified after a given timestamp when possible.
    ///
    /// - Important: Filtering by `updatedAt` may require a composite index in the Firebase console
    ///   for this `stories` query shape.
    /// - Parameter since: Timestamp of the last successful sync. Pass `nil` to fetch every document.
    /// - Returns: DTOs built from each document snapshot.
    /// - Throws: Network errors, permission failures, or Firestore security rule denials.
    func fetchStoriesUpdated(since: Date?) async throws -> [RemoteStoryDTO] {
        var query: Query = dataBase.collection("stories")

        if let since {
            query = query.whereField("updatedAt", isGreaterThan: Timestamp(date: since))
        }

        let snapshot = try await query.getDocuments()

        return snapshot.documents.compactMap { doc in
            RemoteStoryDTO(document: doc)
        }
    }
}
