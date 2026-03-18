//
//  PlantStoryUseCase.swift
//  Eco
//

import Foundation

protocol PlantStoryUseCaseProtocol {
    func execute(title: String, content: String, latitude: Double, longitude: Double) async throws
}
