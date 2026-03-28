//
//  GeographicBounds.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Purpose: Approximate lat/lon bounding boxes from a center point and radius in meters.
//
//  Responsibilities:
//  - Provide conservative rectangles for SwiftData predicates before precise distance filters.
//

import Foundation

/// Inclusive lat/lon rectangle used for SwiftData queries and map prefetch.
struct GeographicBoundingBox: Equatable {
    var minLatitude: Double
    var maxLatitude: Double
    var minLongitude: Double
    var maxLongitude: Double
}

enum GeographicBounds {

    /// Returns a geographic rectangle that fully contains a circle of `radiusMeters` around the center.
    /// Uses a spherical approximation; not exact at poles but sufficient for Eco’s latitudes.
    static func boundingBox(
        centerLatitude: Double,
        centerLongitude: Double,
        radiusMeters: Double
    ) -> GeographicBoundingBox {
        let metersPerDegreeLatitude = 111_320.0
        let deltaLatitude = radiusMeters / metersPerDegreeLatitude
        let cosLatitude = cos(centerLatitude * .pi / 180.0)
        let metersPerDegreeLongitude = max(metersPerDegreeLatitude * cosLatitude, 1.0)
        let deltaLongitude = radiusMeters / metersPerDegreeLongitude
        return GeographicBoundingBox(
            minLatitude: centerLatitude - deltaLatitude,
            maxLatitude: centerLatitude + deltaLatitude,
            minLongitude: centerLongitude - deltaLongitude,
            maxLongitude: centerLongitude + deltaLongitude
        )
    }
}
