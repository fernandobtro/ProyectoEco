//
//  AuthorProfileRepositoryProtocol.swift
//  Eco
//
//  Created by Fernando Buenrostro on 16/03/26.
//

import Foundation

protocol AuthorProfileRepositoryProtocol {
    func create(profile: AuthorProfile) async throws
    func get(by id: String) async throws -> AuthorProfile
    func getCurrent() async throws -> AuthorProfile?
    func save(_ profile: AuthorProfile) async throws
}
