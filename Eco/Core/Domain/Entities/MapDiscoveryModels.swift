//
//  MapDiscoveryModels.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//

import Foundation

/// Modo de descubrimiento en mapa (producto: «cerca de mí» vs «explorar»).
enum MapDiscoveryMode: String, Sendable {
    case nearUser
    case exploring
}

/// Rectángulo geográfico visible (sin MapKit en Domain).
struct MapVisibleBounds: Equatable, Sendable {
    var minLatitude: Double
    var maxLatitude: Double
    var minLongitude: Double
    var maxLongitude: Double
}
