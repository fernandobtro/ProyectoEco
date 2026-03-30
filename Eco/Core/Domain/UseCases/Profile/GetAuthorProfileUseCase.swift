//
//  GetAuthorProfileUseCase.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Created by Fernando Buenrostro on 16/03/26.
//
//  Purpose: Domain use case contract `GetAuthorProfileUseCase` for Features - Data wiring.
//

import Foundation

/// Domain use case contract `GetAuthorProfileUseCase` for Features - Data wiring.
protocol GetAuthorProfileUseCase {
    func execute() async throws -> AuthorProfile?
}
