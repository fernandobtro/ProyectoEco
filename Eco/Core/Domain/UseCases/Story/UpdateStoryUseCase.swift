//
//  UpdateStoryUseCase.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Created by Fernando Buenrostro on 17/03/26.
//

import Foundation

protocol UpdateStoryUseCaseProtocol {
    func execute(_ story: Story) async throws
}
