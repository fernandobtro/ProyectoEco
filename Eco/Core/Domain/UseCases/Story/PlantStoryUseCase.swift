//
//  PlantStoryUseCase.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//

import Foundation

protocol PlantStoryUseCaseProtocol {
    /// Devuelve el UUID del Eco recién plantado.
    func execute(title: String, content: String, latitude: Double, longitude: Double) async throws -> UUID
}
