//
//  StoriesPage.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Purpose: One page of stories for paginated list flows (e.g. Collection planted tab).
//

import Foundation

/// A single page of ``Story`` values plus whether more pages exist (see `GetPlantedStoriesUseCase`).
struct StoriesPage: Equatable {
    let items: [Story]
    let hasMore: Bool
}
