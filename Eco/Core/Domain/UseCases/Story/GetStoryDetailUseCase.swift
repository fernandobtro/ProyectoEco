//
//  GetStoryDetailUseCase.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Created by Fernando Buenrostro on 16/03/26.
//
//  Purpose: Resolve a single story by id for detail flows.
//

import Foundation

/// Resolve a single story by id for detail flows.
protocol GetStoryDetailUseCaseProtocol {
    // MARK: - Public API

    /// Resolves the story for `id`, or `nil` when the row is missing or soft-deleted.
    func execute(id: UUID) async throws -> Story?
}
