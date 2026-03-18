//
//  FirebaseAuthorProfileDataSource.swift
//  Eco
//
//  Created by Fernando Buenrostro on 16/03/26.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

final class FirebaseAuthorProfileDataSource {
    private let collectionName = "authorProfiles"

    func create(profile: AuthorProfile) async throws {
        let db = Firestore.firestore()
        try await db
            .collection(collectionName)
            .document(profile.id)
            .setData(encode(profile), merge: false)
    }

    func get(by id: String) async throws -> AuthorProfile {
        let db = Firestore.firestore()
        let snapshot = try await db
            .collection(collectionName)
            .document(id)
            .getDocument()

        guard let data = snapshot.data() else {
            throw NSError(
                domain: "FirebaseAuthorProfileDataSource",
                code: 404,
                userInfo: [NSLocalizedDescriptionKey: "Author profile not found"]
            )
        }

        return try decode(id: snapshot.documentID, data: data)
    }

    func getCurrent() async throws -> AuthorProfile? {
        guard let uid = Auth.auth().currentUser?.uid else {
            return nil
        }
        // Si no existe el documento, devolvemos nil en lugar de lanzar error
        do {
            return try await get(by: uid)
        } catch {
            let nsError = error as NSError
            if nsError.code == 404 {
                return nil
            }
            throw error
        }
    }

    func save(_ profile: AuthorProfile) async throws {
        let db = Firestore.firestore()
        try await db
            .collection(collectionName)
            .document(profile.id)
            .setData(encode(profile), merge: true)
    }

    // MARK: - Mapping helpers

    private func encode(_ profile: AuthorProfile) -> [String: Any] {
        [
            "email": profile.email,
            "nickname": profile.nickname,
            "createdAt": Timestamp(date: profile.createdAt)
        ]
    }

    private func decode(id: String, data: [String: Any]) throws -> AuthorProfile {
        guard
            let email = data["email"] as? String,
            let nickname = data["nickname"] as? String,
            let createdAtTimestamp = data["createdAt"] as? Timestamp
        else {
            throw NSError(
                domain: "FirebaseAuthorProfileDataSource",
                code: -2,
                userInfo: [NSLocalizedDescriptionKey: "Invalid author profile data"]
            )
        }

        return AuthorProfile(
            id: id,
            email: email,
            nickname: nickname,
            createdAt: createdAtTimestamp.dateValue()
        )
    }
}

