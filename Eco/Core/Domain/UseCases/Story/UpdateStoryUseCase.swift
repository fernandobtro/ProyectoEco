//
//  UpdateStoryUseCase.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Created by Fernando Buenrostro on 17/03/26.
//
//  Purpose: Domain use case contract `UpdateStoryUseCase` for Features - Data wiring.
//

import Foundation

/// Domain use case contract `UpdateStoryUseCase` for Features - Data wiring.
protocol UpdateStoryUseCaseProtocol {
    func execute(_ story: Story) async throws
}
