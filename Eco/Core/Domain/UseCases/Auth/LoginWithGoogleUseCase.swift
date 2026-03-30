//
//  LoginWithGoogleUseCase.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Created by Fernando Buenrostro on 17/03/26.
//
//  Purpose: Domain use case contract `LoginWithGoogleUseCase` for Features - Data wiring.
//

import Foundation

/// Domain use case contract `LoginWithGoogleUseCase` for Features - Data wiring.
protocol LoginWithGoogleUseCaseProtocol {
    func execute(idToken: String, accessToken: String) async throws -> String
}
