//
//  MapDiscoveryModels.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Purpose: Map discovery mode and visible lat/lon bounds (Domain only, no MapKit types).
//

import Foundation

/// Product mode: follow user vs pan-to-explore visible area.
enum MapDiscoveryMode: String, Sendable {
    case nearUser
    case exploring
}

/// Axis-aligned bounds for queries (mirrors visible map region without importing MapKit).
struct MapVisibleBounds: Equatable, Sendable {
    var minLatitude: Double
    var maxLatitude: Double
    var minLongitude: Double
    var maxLongitude: Double
}
