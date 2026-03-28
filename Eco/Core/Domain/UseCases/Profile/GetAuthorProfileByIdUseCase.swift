//
//  GetAuthorProfileByIdUseCase.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//

import Foundation

protocol GetAuthorProfileByIdUseCaseProtocol {
    func execute(authorId: String) async throws -> AuthorProfile?
}
