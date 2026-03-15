//
//  PlantStoryUseCase.swift
//  Eco
//

import Foundation

protocol PlantStoryUseCaseProtocol {
    func execute(title: String, content: String, authorId: UUID, latitude: Double, longitude: Double) async throws
}
