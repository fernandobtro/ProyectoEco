//
//  StoryViewData.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Purpose: Immutable row/card payload derived from ``Story`` in feature view models (lists and map explore).
//

import Foundation

/// Pre-formatted strings and flags for ``StoryListRowView``, ``StoryCardView``, and ``CollectionStoryCardRow``.
struct StoryViewData: Identifiable, Equatable {
    let id: UUID
    let title: String
    let subtitle: String
    let isSynced: Bool
    let showMineBadge: Bool
    let footnote: String?
    let footnoteIncludesDistance: Bool
    /// Explore mode: show a “very close” pill when location is known and distance is under 10 m.
    let showNearbyPill: Bool
}
