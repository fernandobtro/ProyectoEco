//
//  AuthorProfileRepository.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Purpose: Firebase-backed implementation of author profile storage.
//

import Foundation

/// Firebase-backed implementation of author profile storage.
final class AuthorProfileRepository: AuthorProfileRepositoryProtocol {
    // MARK: - Dependencies
    private let dataSource: FirebaseAuthorProfileDataSource

    // MARK: - Init
    init(dataSource: FirebaseAuthorProfileDataSource) {
        self.dataSource = dataSource
    }

    // MARK: - Public API
    func get(by id: String) async throws -> AuthorProfile {
        try await dataSource.get(by: id)
    }

    func getCurrent() async throws -> AuthorProfile? {
        try await dataSource.getCurrent()
    }

    func create(profile: AuthorProfile) async throws {
        try await dataSource.create(profile: profile)
    }

    func save(_ profile: AuthorProfile) async throws {
        try await dataSource.save(profile)
    }
}
