//
//  GetDiscoveredStoriesUseCase.swift
//  Eco
//
//  Created by Fernando Buenrostro on 16/03/26.
//

import Foundation

protocol GetDiscoveredStoriesUseCaseProtocol {
    func execute() async throws -> [Story]
}
