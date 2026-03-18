//
//  AuthorProfileRepository.swift
//  Eco
//
//  Created by Cursor on 17/03/26.
//

import Foundation

final class AuthorProfileRepository: AuthorProfileRepositoryProtocol {
    private let dataSource: FirebaseAuthorProfileDataSource

    init(dataSource: FirebaseAuthorProfileDataSource) {
        self.dataSource = dataSource
    }

    func create(profile: AuthorProfile) async throws {
        try await dataSource.create(profile: profile)
    }

    func get(by id: String) async throws -> AuthorProfile {
        try await dataSource.get(by: id)
    }

    func getCurrent() async throws -> AuthorProfile? {
        try await dataSource.getCurrent()
    }

    func save(_ profile: AuthorProfile) async throws {
        try await dataSource.save(profile)
    }
}

