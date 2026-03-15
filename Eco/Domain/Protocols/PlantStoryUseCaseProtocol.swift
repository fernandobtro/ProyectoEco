//
//  PlantStoryUseCaseProtocol.swift
//  Eco
//
//  Created by Fernando Buenrostro on 28/02/26.
//

import Foundation

protocol PlantStoryUseCaseProtocol {
    func execute(title: String, content: String, authorId: UUID, latitude: Double, longitude: Double) async throws
}
