//
//  LoginUseCase.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Created by Fernando Buenrostro on 16/03/26.
//
//  Purpose: Domain use case contract `LoginUseCase` for Features - Data wiring.
//

import Foundation

/// Domain use case contract `LoginUseCase` for Features - Data wiring.
protocol LoginUseCaseProtocol {
    func execute(email: String, password: String) async throws -> String
}
