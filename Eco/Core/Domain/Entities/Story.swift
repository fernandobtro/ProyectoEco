//
//  Story.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Created by Fernando Buenrostro on 27/02/26.
//
//  Purpose: Domain entity `Story` (pure model, no framework UI).
//

import Foundation

/// Domain entity `Story` (pure model, no framework UI).
struct Story: Identifiable, Equatable {
    let id: UUID
    let title: String
    let content: String
    let authorID: String
    let latitude: Double
    let longitude: Double
    let isSynced: Bool
    /// Last modification time (ordering, sync conflicts, debugging).
    let updatedAt: Date
}
