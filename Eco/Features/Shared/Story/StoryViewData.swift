//
//  StoryViewData.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Datos listos para UI (tarjetas y filas): el ViewModel mapea desde `Story`.
//

import Foundation

struct StoryViewData: Identifiable, Equatable {
    let id: UUID
    let title: String
    let subtitle: String
    let isSynced: Bool
    let showMineBadge: Bool
    let footnote: String?
    let footnoteIncludesDistance: Bool
    /// Solo Explorar: píldora «Muy cerca» cuando hay ubicación y distancia &lt; 10 m.
    let showNearbyPill: Bool
}
