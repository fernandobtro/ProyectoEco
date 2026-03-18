//
//  GetPlantedStoriesUseCase.swift
//  Eco
//
//  Created by Fernando Buenrostro on 16/03/26.
//

import Foundation

protocol GetPlantedStoriesUseCaseProtocol {
    func execute() async throws -> [Story]
}
