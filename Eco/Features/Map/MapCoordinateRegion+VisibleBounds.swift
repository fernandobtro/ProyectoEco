//
//  MapCoordinateRegion+VisibleBounds.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Purpose: Converts `MKCoordinateRegion` to ``MapVisibleBounds`` for bounded story queries.
//

import MapKit

/// Bridge from MapKit region to domain ``MapVisibleBounds`` (explore/discover fetches).
extension MKCoordinateRegion {
    func toVisibleBounds() -> MapVisibleBounds {
        MapVisibleBounds(
            minLatitude: center.latitude - span.latitudeDelta / 2,
            maxLatitude: center.latitude + span.latitudeDelta / 2,
            minLongitude: center.longitude - span.longitudeDelta / 2,
            maxLongitude: center.longitude + span.longitudeDelta / 2
        )
    }
}
