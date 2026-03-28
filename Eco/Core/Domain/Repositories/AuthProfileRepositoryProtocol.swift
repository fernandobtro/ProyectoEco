//
//  AuthProfileRepositoryProtocol.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Created by Fernando Buenrostro on 16/03/26.
//

import Foundation

protocol AuthProfileRepositoryProtocol {
    func fetchAuthorProfile(userId: String) async throws -> AuthorProfile?
    func saveAuthorProfile(_ profile: AuthorProfile) async throws
}
