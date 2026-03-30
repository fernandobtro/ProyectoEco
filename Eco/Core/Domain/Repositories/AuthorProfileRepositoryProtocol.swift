//
//  AuthorProfileRepositoryProtocol.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Purpose: Author profile persistence and lookup for the signed-in user and by id.
//

import Foundation

/// Author profile persistence and lookup for the signed-in user and by id.
protocol AuthorProfileRepositoryProtocol {
    // MARK: - Reads
    func get(by id: String) async throws -> AuthorProfile
    func getCurrent() async throws -> AuthorProfile?

    // MARK: - Writes
    func create(profile: AuthorProfile) async throws
    func save(_ profile: AuthorProfile) async throws
}
