//
//  DeleteStoryUseCase.swift
//  Eco
//
//  Created by Fernando Buenrostro on 16/03/26.
//

import Foundation

protocol DeleteStoryUseCaseProtocol {
    func execute(storyId: UUID) async throws
}
