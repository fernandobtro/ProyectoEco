//
//  GetPlantedStoriesUseCase.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Created by Fernando Buenrostro on 16/03/26.
//
//  Purpose: Domain use case contract `GetPlantedStoriesUseCase` for Features - Data wiring.
//

import Foundation

/// Loads planted stories for the current user in pages for the Collection tab.
///
/// Narrative: `docs/EcoCorePipelines.md` — **Collection (Planted / Discovered) Pipeline**.
protocol GetPlantedStoriesUseCaseProtocol {
    /// Returns one page of planted stories for the signed-in user.
    ///
    /// - Note: The implementation fetches `pageSize + 1` rows to detect a next page, the view model only passes `page` and `pageSize`.
    func execute(page: Int, pageSize: Int) async throws -> StoriesPage
}
