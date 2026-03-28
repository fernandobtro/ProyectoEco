//
//  GetPlantedStoriesUseCase.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Created by Fernando Buenrostro on 16/03/26.
//

import Foundation

protocol GetPlantedStoriesUseCaseProtocol {
    func execute() async throws -> [Story]
}
