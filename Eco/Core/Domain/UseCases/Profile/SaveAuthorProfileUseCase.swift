//
//  SaveAuthorProfileUseCase.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Created by Fernando Buenrostro on 16/03/26.
//
//  Purpose: Domain use case contract `SaveAuthorProfileUseCase` for Features - Data wiring.
//

import Foundation

/// Domain use case contract `SaveAuthorProfileUseCase` for Features - Data wiring.
protocol SaveAuthorProfileUseCase {
    func execute(_ profile: AuthorProfile) async throws
}
