//
//  LoginWithAppleUseCase.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Created by Fernando Buenrostro on 17/03/26.
//
//  Purpose: Domain use case contract `LoginWithAppleUseCase` for Features - Data wiring.
//

import Foundation

/// Domain use case contract `LoginWithAppleUseCase` for Features - Data wiring.
protocol LoginWithAppleUseCaseProtocol {
    func execute(identityToken: Data, nonce: String, fullName: PersonNameComponents?) async throws -> String
}
