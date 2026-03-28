//
//  FirestoreStoryDataSourceProtocol.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Created by Fernando Buenrostro on 17/03/26.
//
//  Purpose: Remote story persistence and reads against the Firestore `stories` collection.
//
//  Responsibilities:
//  - Create, update, and soft-delete story documents by remote id.
//  - Fetch changed or all story DTOs for sync pull using `updatedAt` boundaries.
//

import Foundation

protocol FirestoreStoryDataSourceProtocol: AnyObject {
    // MARK: - Public API

    /// Sends a new story to the global `stories` collection in Firestore.
    ///
    /// - Parameter payload: Raw fields to write to the remote document.
    /// - Returns: The Firebase-generated `documentID` to persist locally as `remoteId`.
    /// - Throws: Network errors, permission failures, or Firestore security rule denials.
    func create(payload: FirestoreStoryPayload) async throws -> String

    /// Merges the payload into the document identified by `payload.remoteId`.
    ///
    /// - Parameter payload: Must include a non-nil `remoteId` for the document to update.
    /// - Throws: A local error when `remoteId` is missing, or Firestore/network errors for the write.
    func update(payload: FirestoreStoryPayload) async throws

    /// Soft-deletes a story by merging `deletedAt` on the remote document.
    ///
    /// - Parameter remoteId: Firestore document id of the story to mark deleted.
    /// - Throws: Network errors, permission failures, or Firestore security rule denials.
    func softDelete(remoteId: String) async throws

    /// Delta sync: fetches stories modified after a given timestamp when possible.
    ///
    /// - Important: Filtering by `updatedAt` may require a composite index in the Firebase console
    ///   for this `stories` query shape.
    /// - Parameter since: Timestamp of the last successful sync. Pass `nil` to fetch every document.
    /// - Returns: DTOs built from each document snapshot.
    /// - Throws: Network errors, permission failures, or Firestore security rule denials.
    func fetchStoriesUpdated(since: Date?) async throws -> [RemoteStoryDTO]
}
