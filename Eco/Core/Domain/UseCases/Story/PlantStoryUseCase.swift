//
//  PlantStoryUseCase.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Purpose: Domain use case contract `PlantStoryUseCase` for Features - Data wiring.
//

import Foundation

/// Domain use case contract `PlantStoryUseCase` for Features - Data wiring.
protocol PlantStoryUseCaseProtocol {
    /// Returns the id of the newly created story.
    func execute(title: String, content: String, latitude: Double, longitude: Double) async throws -> UUID
}
