//
//  GetStoryDetailUseCase.swift
//  Eco
//
//  Created by Fernando Buenrostro on 16/03/26.
//

import Foundation

protocol GetStoryDetailUseCaseProtocol {
    func execute(id: UUID) async throws -> Story?
}

