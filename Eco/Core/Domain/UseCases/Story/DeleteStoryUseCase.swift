//
//  DeleteStoryUseCase.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Created by Fernando Buenrostro on 16/03/26.
//

import Foundation

protocol DeleteStoryUseCaseProtocol {
    func execute(storyId: UUID) async throws
}
