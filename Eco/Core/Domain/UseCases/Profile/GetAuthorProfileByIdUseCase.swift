//
//  GetAuthorProfileByIdUseCase.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Purpose: Domain use case contract `GetAuthorProfileByIdUseCase` for Features - Data wiring.
//

import Foundation

/// Domain use case contract `GetAuthorProfileByIdUseCase` for Features - Data wiring.
protocol GetAuthorProfileByIdUseCaseProtocol {
    func execute(authorId: String) async throws -> AuthorProfile?
}
