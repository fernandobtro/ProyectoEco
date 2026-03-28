//
//  MapCoordinateRegion+VisibleBounds.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//

import MapKit

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
