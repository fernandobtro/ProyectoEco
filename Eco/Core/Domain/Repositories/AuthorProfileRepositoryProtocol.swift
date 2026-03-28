//
//  AuthorProfileRepositoryProtocol.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Purpose: Author profile persistence and lookup for the signed-in user and by id.
//
//  Responsibilities:
//  - Create and save profiles; fetch by id or the current session's profile.
//

import Foundation

protocol AuthorProfileRepositoryProtocol {
    // MARK: - Reads
    func get(by id: String) async throws -> AuthorProfile
    func getCurrent() async throws -> AuthorProfile?

    // MARK: - Writes
    func create(profile: AuthorProfile) async throws
    func save(_ profile: AuthorProfile) async throws
}
