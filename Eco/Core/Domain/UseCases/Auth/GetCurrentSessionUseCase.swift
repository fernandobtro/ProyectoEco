//
//  GetCurrentSessionUseCase.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Created by Fernando Buenrostro on 16/03/26.
//
//  Purpose: Domain use case contract `GetCurrentSessionUseCase` for Features - Data wiring.
//

import Foundation

/// Domain use case contract `GetCurrentSessionUseCase` for Features - Data wiring.
protocol GetCurrentSessionUseCaseProtocol {
    func execute() -> String?
    func getNickname() -> String?
}
