//
//  FirestoreStoryDataSource.swift
//  Eco
//
//  Created by Fernando Buenrostro on 17/03/26.
//

import Foundation
import FirebaseFirestore

final class FirestoreStoryDataSource {
    private let db = Firestore.firestore()
    
    func create(story: StoryEntity) async throws -> String {
        let ref = db.collection("stories").document()
        
        let data: [String: Any] = [
            "title": story.title,
            "content": story.content,
            // Firestore no soporta UUID directamente, lo mandamos como String
            "authorId": story.authorID.uuidString,
            "latitude": story.latitude,
            "longitude": story.longitude,
            "updatedAt": Timestamp(date: story.updatedAt)
        ]
        
        try await ref.setData(data)
        
        return ref.documentID
    }

    func update(story: StoryEntity) async throws {
        guard let remoteId = story.remoteId else {
            throw NSError(
                domain: "FirestoreStoryDataSource",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Missing remoteId for update"]
            )
        }

        let ref = db.collection("stories").document(remoteId)

        let data: [String: Any] = [
            "title": story.title,
            "content": story.content,
            "authorId": story.authorID.uuidString,
            "latitude": story.latitude,
            "longitude": story.longitude,
            "updatedAt": Timestamp(date: story.updatedAt)
        ]

        try await ref.setData(data, merge: true)
    }

    func softDelete(remoteId: String) async throws {
        let ref = db.collection("stories").document(remoteId)
        let data: [String: Any] = [
            "deletedAt": Timestamp(date: Date())
        ]
        try await ref.setData(data, merge: true)
    }
    
    func fetchStoriesUpdated(since: Date?) async throws -> [RemoteStoryDTO] {
        var query: Query = db.collection("stories")
        
        if let since {
            query = query.whereField("updatedAt", isGreaterThan: Timestamp(date: since))
        }
        
        let snapshot = try await query.getDocuments()
        
        return snapshot.documents.compactMap { doc in
            RemoteStoryDTO(document: doc)
        }
    }
}
