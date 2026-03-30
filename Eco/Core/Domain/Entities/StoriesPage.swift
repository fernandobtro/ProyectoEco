//
//  StoriesPage.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Purpose: Paginated slice of stories plus continuation flag.
//

import Foundation

/// One page of ``Story`` values and whether another page exists after this slice.
///
/// Produced by ``GetPlantedStoriesUseCaseProtocol``, context in `docs/EcoCorePipelines.md` — **Collection** pipeline.
struct StoriesPage: Equatable {
    let items: [Story]
    let hasMore: Bool
}
