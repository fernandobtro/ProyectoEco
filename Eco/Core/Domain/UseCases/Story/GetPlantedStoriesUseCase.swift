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
    /// Loads one page of stories planted by the current user. Pagination (`page`, `pageSize + 1`, `hasMore`) is resolved in the implementation, not in the view model.
    func execute(page: Int, pageSize: Int) async throws -> StoriesPage
}
